class BasicRailsSystemSpecController < ApplicationController
  def trivial_widget
  end

  def the_class_should_not_load
    render :text => BasicRailsSystemSpec::ClassShouldNotLoad.new.to_s
  end

  def passing_data_widget
    @foo = 'the_foo'
    @bar = 'and_bar'
  end

  def passing_locals_widget
    render :locals => { :foo => 'local_foo', :bar => 'local_bar' }
  end

  def passing_locals_and_controller_variables_widget
    @foo = "controller_foo"
    @baz = "controller_baz"

    render :locals => { :bar => 'local_bar', :baz => 'local_baz' }
  end

  def render_with_colon_action
    render :action => 'trivial_widget'
  end

  def render_with_colon_template
    render :template => 'basic_rails_system_spec/trivial_widget'
  end

  def omitted_variable
    @foo = 'the_foo'

    render :action => 'passing_data_widget'
  end

  def extra_variables
    @foo = 'the_foo'
    @bar = 'the_bar'

    render :locals => { :baz => 'the_baz' }
  end

  def erb_to_widget_with_render_partial
  end

  def prefers_erb_partial
  end

  def fortitude_partial_with_underscore
  end
end
