describe "Rails generator support", :type => :rails do
  # We use development mode so that we don't have to bounce the Rails server every time we
  # generate something new.
  uses_rails_with_template :generators_system_spec, :rails_env => :development

  def views_base_path
    @views_base_path ||= File.join(rails_server.rails_root, 'app', 'views', 'base.rb')
  end

  def clean_views_base!
    File.delete(views_base_path) if File.exist?(views_base_path)
  end

  def ensure_views_base_is_correct!
    expect(File.exist?(views_base_path)).to be_truthy

    contents = File.read(views_base_path)
    expect(contents).to match(/Views::Base\s*<\s*Fortitude::Widget\s*\n/)
    expect(contents).to match(/doctype\s+:html5/)
  end

  def generate!(what)
    rails_server.run_command_in_rails_root!("rails generate #{what}")
  end

  def ensure_file_matches!(subpath, regexp)
    path = File.join(rails_server.rails_root, subpath)
    expect(File.exist?(path)).to be_truthy

    contents = File.read(path)
    expect(contents).to match(regexp)
  end

  def ensure_action_matches!(subpath, regexp)
    response = rails_server.get(subpath)
    expect(response).to match(regexp)
    response
  end

  describe "base view generation" do
    it "should be able to generate a Views::Base file" do
      clean_views_base!
      generate!("fortitude:base_view")
      ensure_views_base_is_correct!
    end
  end

  describe "controller generation" do
    it "should be able to generate a controller action that creates a Fortitude view" do
      generate!("controller gen_con1 act_ion1")
      ensure_file_matches!('app/views/gen_con1/act_ion1.html.rb', /Views::GenCon1::ActIon1\s*<\s*Views::Base/)
      ensure_action_matches!('gen_con1/act_ion1', %r{<h1>\s*GenCon1#act_ion1\s*</h1>\s*<p>\s*Find me in app/views/gen_con1/act_ion1.html.rb\s*</p>}mi)
    end

    it "should generate a Views::Base file" do
      clean_views_base!
      generate!("controller gencon2 action2")
      ensure_views_base_is_correct!
    end

    it "should not overwrite an existing Views::Base file" do
      prior_contents = "class Views::Base < Fortitude::Widget\n  doctype :html5\n  def something\n  end\nend"
      File.open(views_base_path, 'w') { |f| f.puts prior_contents }

      generate!("controller gencon3 action3")

      expect(File.exist?(views_base_path)).to be_truthy
      expect(File.read(views_base_path).strip).to eq(prior_contents.strip)
    end

    it "should allow switching back to ERb if desired" do
      generate!("controller gen_con4 act_ion1 -e erb")
      expect(File.exist?(File.join(rails_server.rails_root, 'app/views/gen_con4/act_ion1.html.rb'))).to be_falsey
      expect(File.exist?(File.join(rails_server.rails_root, 'app/views/gen_con4/act_ion1.html.erb'))).to be_truthy
    end
  end

  describe "mailer generation" do
    it "should be able to generate a mailer that creates a Fortitude view and layout" do
      generate!("mailer gen1 act_ion1")
      ensure_file_matches!('app/views/gen1_mailer/act_ion1.html.rb', /Views::Gen1Mailer::ActIon1\s*<\s*Views::Base/)
    end

    it "should generate a Views::Base file" do
      clean_views_base!
      generate!("mailer gen1 act_ion1")
      ensure_views_base_is_correct!
    end

    it "should not overwrite an existing Views::Base file" do
      prior_contents = "class Views::Base < Fortitude::Widget\n  doctype :html5\n  def something\n  end\nend"
      File.open(views_base_path, 'w') { |f| f.puts prior_contents }

      generate!("mailer gen1 act_ion1")

      expect(File.exist?(views_base_path)).to be_truthy
      expect(File.read(views_base_path).strip).to eq(prior_contents.strip)
    end
  end

  describe "scaffold generation" do
    it "should be able to generate a scaffold" do
      generate!("scaffold MyModel foo:string bar:integer")

      # We need to disable CSRF protection, since we're not using a session
      application_controller = File.join(rails_server.rails_root, 'app', 'controllers', 'application_controller.rb')
      application_controller_contents = File.read(application_controller)
      if (! application_controller_contents.gsub!(/^\s*protect_from_forgery.*$/, "protect_from_forgery :with => :null_session"))
        application_controller_contents.gsub!(/^end\Z/, "  protect_from_forgery :with => :null_session\nend\n")
      end
      File.open(application_controller, 'w') { |f| f.puts application_controller_contents }

      # Need this to create the table (which will be in SQLite by default, which is easy), or else
      # the controller actions will fail since there will be no such table.
      rails_server.run_command_in_rails_root!("rake db:migrate")

      ensure_file_matches!('app/views/my_models/index.html.rb', %r{class Views::MyModels::Index < Views::Base})
      ensure_file_matches!('app/views/my_models/show.html.rb', %r{class Views::MyModels::Show < Views::Base})
      ensure_file_matches!('app/views/my_models/edit.html.rb', %r{class Views::MyModels::Edit < Views::Base})
      ensure_file_matches!('app/views/my_models/new.html.rb', %r{class Views::MyModels::New < Views::Base})
      ensure_file_matches!('app/views/my_models/form.html.rb', %r{class Views::MyModels::Form < Views::Base})

      # Ruby 1.8.7 and Rails 3.0.x seems to have issues unless we do this, sadly...
      rails_server.stop!
      rails_server.start!

      # This won't check that the views all have the right HTML in them (that's nearly impossible without
      # just duplicating exactly what they're supposed to contain, right here), but it will check that they
      # compile and produce some kind of HTML output.
      ensure_action_matches!('my_models', %r{<h1>\s*My Models\s*</h1>}m)
      new_html = ensure_action_matches!('my_models/new', %r{<form.*action=["']/my_models["']}m)

      # Now, we try to create one
      response = rails_server.post('my_models', :post_variables => {
        'my_model[foo]' => 'foo1', 'my_model[bar]' => 23456, :commit => 'Create My model' },
        :ignore_status_code => true)

      new_url = if (300..399).include?(Integer(response.code))
        response['Location']
      else
        raise "Response didn't seem to give us a redirect: #{response.code.inspect} (from #{response.inspect})"
      end
      path = URI.parse(new_url).path

      ensure_action_matches!(path, %r{foo1.*23456}m)
      ensure_action_matches!("#{path}/edit", %r{Editing.*foo1.*23456}m)
      ensure_action_matches!("my_models", %r{<h1>\s*My Models\s*</h1>.*foo1.*23456}m)
    end
  end
end
