class ClassLoadingSystemSpecController < ApplicationController
  def the_class_should_not_load
    render :text => ClassLoadingSystemSpec::ClassShouldNotLoad.name
  end
end
