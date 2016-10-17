describe "Rails generator support", :type => :rails do
  # We use development mode so that we don't have to bounce the Rails server every time we
  # generate something new.
  uses_rails_with_template :generators_system_spec, :rails_env => :development

  it "should be able to generate a controller action that creates a Fortitude view" do
    rails_server.run_command_in_rails_root!("rails generate controller gen_con1 act_ion1 -e fortitude")

    view_file_path = File.join(rails_server.rails_root, 'app', 'views', 'gen_con1', 'act_ion1.html.rb')
    expect(File.exist?(view_file_path)).to be_truthy
    expect(File.read(view_file_path)).to match(/Views::GenCon1::ActIon1\s*<\s*Views::Base/)

    expect(rails_server.get("gen_con1/act_ion1")).to match(%r{<h1>\s*GenCon1#act_ion1\s*</h1>\s*<p>\s*Find me in app/views/gen_con1/act_ion1.html.rb\s*</p>}mi)
  end

  it "should generate a Views::Base file" do
    rails_server.run_command_in_rails_root!("rails generate controller gencon2 action2 -e fortitude")

    views_base_path = File.join(rails_server.rails_root, 'app', 'views', 'base.rb')
    expect(File.exist?(views_base_path)).to be_truthy

    contents = File.read(views_base_path)
    expect(contents).to match(/Views::Base\s*<\s*Fortitude::Widget\s*\n/)
    expect(contents).to match(/doctype\s+:html5/)
  end

  it "should not overwrite an existing Views::Base file" do
    prior_contents = "class Views::Base < Fortitude::Widget\n  doctype :html5\n  def something\n  end\nend"
    views_base_path = File.join(rails_server.rails_root, 'app', 'views', 'base.rb')
    File.open(views_base_path, 'w') { |f| f.puts prior_contents }

    rails_server.run_command_in_rails_root!("rails generate controller gencon3 action3 -e fortitude")

    expect(File.exist?(views_base_path)).to be_truthy
    expect(File.read(views_base_path).strip).to eq(prior_contents.strip)
  end
end
