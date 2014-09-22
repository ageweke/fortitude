class BasicRailsSystemSpecController < ApplicationController
  def trivial_widget
  end

  def double_render
    @rendered_string = render_to_string(:action => 'double_render_one', :layout => nil)
    render :action => 'double_render_two'
  end

  def the_class_should_not_load
    render :text => BasicRailsSystemSpec::ClassShouldNotLoad.new.to_s
  end
end
