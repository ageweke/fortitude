class BasicRailsSystemSpecController < ApplicationController
  def trivial_widget
  end

  def the_class_should_not_load
    render :text => BasicRailsSystemSpec::ClassShouldNotLoad.new.to_s
  end
end
