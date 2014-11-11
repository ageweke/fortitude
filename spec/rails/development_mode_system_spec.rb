describe "Rails development-mode support", :type => :rails do
  uses_rails_with_template :development_mode_system_spec, :rails_env => :development

  it "should automatically reload widgets if they change on disk" do
    expect_match("reload_widget", /before_reload/)
    # The sleep is unfortunate, but required: without it, Rails will not necessarily pick up our change,
    # especially if we run multiple tests back-to-back. (There's a maximum frequency at which Rails can
    # detect distinct file changes on disk, which on the order of 1 Hz -- i.e., once a second; any more
    # than this and it fails. This is irrelevant for human-centered development, but important for
    # tests like this.)
    sleep 1
    splat_new_widget!
    expect_match("reload_widget", /after_reload/)
  end

  it "should automatically reload widgets if related files change on disk, even if they're named '.html.rb' at the end" do
    expect_match("reload_widget_with_html_extension", /with_html_extension.*helper: yo/)
    sleep 1
    splat_new_module_for_reload_widget_failing!
    expect_exception("reload_widget_with_html_extension", NameError, "some_helper")
    sleep 1
    splat_new_module_for_reload_widget!
    expect_match("reload_widget_with_html_extension", /with_html_extension.*helper: yo/)
  end

  it "should let you change the controller, and that should work fine, too" do
    expect(rails_server.get("replaced/reload_widget")).to match(/datum\s+one\s+datum/)
    sleep 1
    splat_new_controller!
    expect(rails_server.get("replaced/reload_widget")).to match(/datum\s+two\s+datum/)
  end

  it "should, by default, format output" do
    expect_match("sample_output", %r{<section class="one">
  <p>hello, Jessica</p>
</section>}mi)
  end

  it "should, by default, output BEGIN/END debugging tags" do
    expect_match("sample_output", %r{<!-- BEGIN Views::DevelopmentModeSystemSpec::SampleOutput depth 0: :name => "Jessica" -->
.*
<!-- END Views::DevelopmentModeSystemSpec::SampleOutput depth 0 -->}mi)
  end

  it "should pick up changes to mailer views" do
    expect_match("mailer_view_test", /mail sent/i)
    mail = mail_sent_to('mailer_view_test@example.com')
    expect(mail[:body].strip).to match(%r{<p>this is the basic mail!</p>}mi)
    clear_mails!

    sleep 1
    splat_new_mailer_view!
    expect_match("mailer_view_test", /mail sent/i)
    mail = mail_sent_to('mailer_view_test@example.com')
    expect(mail[:body].strip).to match(%r{<p>this is the NEW basic mail!</p>}mi)
  end

  it "should pick up changes to mailer layouts" do
    expect_match("mailer_layout_test", /mail sent/i)
    mail = mail_sent_to('mailer_layout_test@example.com')
    expect(mail[:body].strip).to match(%r{this is the layout, before.*this is the basic mail!.*this is the layout, after}mi)
    clear_mails!

    sleep 1
    splat_new_mailer_layout!
    expect_match("mailer_layout_test", /mail sent/i)
    mail = mail_sent_to('mailer_layout_test@example.com')
    expect(mail[:body].strip).to match(%r{this is the NEW layout, before.*this is the basic mail!.*this is the NEW layout, after}mi)
  end

  it "should format output and output BEGIN/END debugging tags in mailers" do
    expect_match("mailer_formatting_test", /mail sent/i)
    mail = mail_sent_to('mailer_formatting_test@example.com')
    expect(mail[:body].strip).to eq(%{<!-- BEGIN Views::DevelopmentModeMailer::MailerFormattingTest depth 0 -->
<div>
  <p>this is the text!</p>
</div>
<!-- END Views::DevelopmentModeMailer::MailerFormattingTest depth 0 -->})
  end

  private
  def splat_new_widget!
    reload_file = File.join(rails_server.rails_root, 'app/views/development_mode_system_spec/reload_widget.rb')
    File.open(reload_file, 'w') do |f|
      f.puts <<-EOS
class Views::DevelopmentModeSystemSpec::ReloadWidget < Fortitude::Widgets::Html5
  needs :datum

  def content
    p "after_reload: datum \#{datum} datum"
  end
end
EOS
    end
  end

  def splat_new_module_for_reload_widget_failing!
    module_file = File.join(rails_server.rails_root, 'app/views/shared/some_module.rb')
    File.open(module_file, 'w') do |f|
      f.puts <<-EOS
module Views::Shared::SomeModule
end
EOS
    end
  end

  def splat_new_module_for_reload_widget!
    module_file = File.join(rails_server.rails_root, 'app/views/shared/some_module.rb')
    File.open(module_file, 'w') do |f|
      f.puts <<-EOS
module Views::Shared::SomeModule
  def some_helper
    "yo"
  end
end
EOS
    end
  end

  def splat_new_widget_with_html_extension_failing!
    reload_file = File.join(rails_server.rails_root, 'app/views/development_mode_system_spec/reload_widget_with_html_extension.html.rb')
    File.open(reload_file, 'w') do |f|
      f.puts <<-EOS
class Views::DevelopmentModeSystemSpec::ReloadWidgetWithHtmlExtension < Fortitude::Widgets::Html5
  needs :datum

  def content
    p "with_html_extension_after_reload: datum \#{datum} datum, helper: \#{some_helper}"
  end
end
EOS
    end
  end

  def splat_new_widget_with_html_extension!
    reload_file = File.join(rails_server.rails_root, 'app/views/development_mode_system_spec/reload_widget_with_html_extension.html.rb')
    File.open(reload_file, 'w') do |f|
      f.puts <<-EOS
class Views::DevelopmentModeSystemSpec::ReloadWidgetWithHtmlExtension < Fortitude::Widgets::Html5
  include Views::Shared::SomeModule
  needs :datum

  def content
    p "with_html_extension_after_reload: datum \#{datum} datum, helper: \#{some_helper}"
  end
end
EOS
    end
  end

  def splat_new_controller!
    controller_file = File.join(rails_server.rails_root, 'app/controllers/replaced_controller.rb')
    File.open(controller_file, 'w') do |f|
      f.puts <<-EOS
class ReplacedController < ApplicationController
  def reload_widget
    @datum = "two"
  end
end
EOS
    end
  end

  def splat_new_mailer_view!
    reload_file = File.join(rails_server.rails_root, 'app/views/development_mode_mailer/mailer_view_test.rb')
    File.open(reload_file, 'w') do |f|
      f.puts <<-EOS
class Views::DevelopmentModeMailer::MailerViewTest < Fortitude::Widgets::Html5
  def content
    p "this is the NEW basic mail!"
  end
end
EOS
    end
  end


  def splat_new_mailer_layout!
    reload_file = File.join(rails_server.rails_root, 'app/views/layouts/mail_layout.rb')
    File.open(reload_file, 'w') do |f|
      f.puts <<-EOS
class Views::Layouts::MailLayout < Fortitude::Widgets::Html5
  def content
    p "this is the NEW layout, before"
    yield
    p "this is the NEW layout, after"
  end
end
EOS
    end
  end
end
