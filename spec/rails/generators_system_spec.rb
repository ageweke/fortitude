describe "Rails generator support", :type => :rails do
  # We use development mode so that we don't have to bounce the Rails server every time we
  # generate something new.
  uses_rails_with_template :generators_system_spec, :rails_env => :development

  it "should be able to generate a controller action that creates a Fortitude view" do
    rails_server.run_command_in_rails_root!("rails generate controller gencon1 action1 -e fortitude")

    view_file_path = File.join(rails_server.rails_root, 'app', 'views', 'gencon1', 'action1.html.rb')
    expect(File.exist?(view_file_path)).to be_truthy
  end
end
