class ClassLoadingSystemSpecController < ApplicationController
  def the_class_should_not_load
    render :text => ::ClassLoadingSystemSpec::ClassShouldNotLoad.name
  end

  def lib_views
    # nothing here
  end

  def app_models
    # nothing here
  end

  def some_namespace
    render :text => ::SomeNamespace.name
  end

  def some_other_namespace
    render :text => ::SomeNamespace::SomeOtherNamespace.name
  end

  def views_some_namespace
    render :text => ::Views::SomeNamespace.name
  end

  def views_some_other_namespace
    render :text => ::Views::SomeNamespace::SomeOtherNamespace.name
  end
end
