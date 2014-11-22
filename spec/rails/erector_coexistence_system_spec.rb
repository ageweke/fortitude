describe "Erector coexistence support", :type => :rails do
  uses_rails_with_template :erector_coexistence_system_spec, :additional_gemfile_lines => "gem 'erector'"

  begin
    gem 'erector'
  rescue Gem::LoadError => le
    # ok
  end

  begin
    require 'erector'
  rescue LoadError => le
    # ok
  end

  if defined?(::Erector::Widget)
    it "should be able to render a Fortitude widget in app/views" do
      expect_match("fortitude_widget_in_app_views", /this is Fortitude: foo = bar/)
    end

    it "should be able to render a Fortitude widget in app/v/views" do
      expect_match("fortitude_widget_in_app_v_views", /this is Fortitude: foo = marph/)
    end

    it "should be able to render an Erector widget in app/views" do
      expect_match("erector_widget_in_app_views", /<p\s+class\s*=\s*"some_class"\s*>this is Erector: foo = baz<\/p>/)
    end

    it "should be able to render an Erector widget in app/v/views" do
      expect_match("erector_widget_in_app_v_views", /<p\s+class\s*=\s*"some_class"\s*>this is Erector: foo = quux<\/p>/)
    end

    it "should be able to render a Fortitude widget using render :widget" do
      expect_match("render_widget_fortitude", /this is a Fortitude widget/)
    end

    it "should be able to render an Erector widget using render :widget" do
      expect_match("render_widget_erector", /this is an Erector widget/, :no_layout => true)
    end

    it "should be able to render a Fortitude widget with just a class using render :widget" do
      expect_match("render_widget_fortitude_class", /this is a Fortitude widget/)
    end

    it "should be able to render an Erector widget with just a class using render :widget" do
      expect_match("render_widget_erector_class", /this is an Erector widget/, :no_layout => true)
    end

    it "should be able to render an Erector widget from a Fortitude widget using just 'widget'" do
      expect_match("render_erector_widget_from_fortitude_widget",
        %r{before erector widget: this is my_helper\!\s*inside erector widget: this is my_helper\!, passed_foo\s*after erector widget: this is my_helper\!}mi)
    end

    it "should be able to render an Erector widget from a Fortitude widget using just 'widget' with an instantiated widget" do
      expect_match("render_erector_widget_from_fortitude_widget?instantiate_widget=true",
        %r{before erector widget: this is my_helper\!\s*inside erector widget: this is my_helper\!, passed_foo\s*after erector widget: this is my_helper\!}mi)
    end

    it "should be able to render a Fortitude widget from an Erector widget using just 'widget'" do
      expect_match("render_fortitude_widget_from_erector_widget",
        %r{before fortitude widget: this is my_helper\!\s*inside fortitude widget: this is my_helper\!, passed_foo\s*after fortitude widget: this is my_helper\!}mi)
    end

    it "should be able to render a Fortitude widget from an Erector widget using just 'widget' with an instantiated widget" do
      expect_match("render_fortitude_widget_from_erector_widget?instantiate_widget=true",
        %r{before fortitude widget: this is my_helper\!\s*inside fortitude widget: this is my_helper\!, passed_foo\s*after fortitude widget: this is my_helper\!}mi)
    end
  end
end
