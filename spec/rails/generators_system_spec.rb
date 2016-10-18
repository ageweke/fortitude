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
    views_base_path = File.join(rails_server.rails_root, 'app', 'views', 'base.rb')
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
      generate!("controller gen_con1 act_ion1 -e fortitude")
      ensure_file_matches!('app/views/gen_con1/act_ion1.html.rb', /Views::GenCon1::ActIon1\s*<\s*Views::Base/)
      ensure_action_matches!('gen_con1/act_ion1', %r{<h1>\s*GenCon1#act_ion1\s*</h1>\s*<p>\s*Find me in app/views/gen_con1/act_ion1.html.rb\s*</p>}mi)
    end

    it "should generate a Views::Base file" do
      clean_views_base!
      generate!("controller gencon2 action2 -e fortitude")
      ensure_views_base_is_correct!
    end

    it "should not overwrite an existing Views::Base file" do
      prior_contents = "class Views::Base < Fortitude::Widget\n  doctype :html5\n  def something\n  end\nend"
      File.open(views_base_path, 'w') { |f| f.puts prior_contents }

      generate!("controller gencon3 action3 -e fortitude")

      expect(File.exist?(views_base_path)).to be_truthy
      expect(File.read(views_base_path).strip).to eq(prior_contents.strip)
    end
  end

  describe "mailer generation" do
    it "should be able to generate a mailer that creates a Fortitude view and layout" do
      generate!("mailer gen1 act_ion1 -e fortitude")
      ensure_file_matches!('app/views/gen1_mailer/act_ion1.html.rb', /Views::Gen1Mailer::ActIon1\s*<\s*Views::Base/)
    end

    it "should generate a Views::Base file" do
      clean_views_base!
      generate!("mailer gen1 act_ion1 -e fortitude")
      ensure_views_base_is_correct!
    end

    it "should not overwrite an existing Views::Base file" do
      prior_contents = "class Views::Base < Fortitude::Widget\n  doctype :html5\n  def something\n  end\nend"
      File.open(views_base_path, 'w') { |f| f.puts prior_contents }

      generate!("mailer gen1 act_ion1 -e fortitude")

      expect(File.exist?(views_base_path)).to be_truthy
      expect(File.read(views_base_path).strip).to eq(prior_contents.strip)
    end
  end

  describe "scaffold generation" do
    it "should be able to generate a scaffold" do
      generate!("scaffold MyModel foo:string bar:integer -e fortitude")
    end
  end
end
