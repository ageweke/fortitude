describe "Rails development-mode support", :type => :rails do
  uses_rails_with_template :development_mode_system_spec, :rails_env => :development

  it "should automatically reload widgets if they change on disk" do
    expect_match("reload_widget", /before_reload/)
    File.open(File.join(rails_server.rails_root, 'app/views/development_mode_system_spec/reload_widget.rb'), 'w') do |f|
      f.puts <<-EOS
class Views::BasicRailsSystemSpec::ReloadWidget < Fortitude::Widget
def content
  p "after_reload"
end
end
EOS
    end
    expect_match("reload_widget", /after_reload/)
  end
end
