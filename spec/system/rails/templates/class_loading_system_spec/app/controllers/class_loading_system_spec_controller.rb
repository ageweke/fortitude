class ClassLoadingSystemSpecController < ApplicationController
  def the_class_should_not_load
    render :text => ClassLoadingSystemSpec::ClassShouldNotLoad.name
  end

  def lib_views
    # nothing here
  end
end
