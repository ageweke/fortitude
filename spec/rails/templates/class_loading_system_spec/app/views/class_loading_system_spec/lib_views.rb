require 'views/class_loading_system_spec/lib_views_helper'

class Views::ClassLoadingSystemSpec::LibViews < Fortitude::Widget::Html5
  def content
    data = Views::ClassLoadingSystemSpec::LibViewsHelper.new.data
    p "hello: #{data}"
  end
end
