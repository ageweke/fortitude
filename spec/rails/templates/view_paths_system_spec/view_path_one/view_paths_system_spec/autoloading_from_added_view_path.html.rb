class Views::ViewPathsSystemSpec::AutoloadingFromAddedViewPath < Views::Baseone::Basetwo::BaseClassOne
  def content
    p "helper method: #{base_class_one_method_one}: there it is!"
  end
end
