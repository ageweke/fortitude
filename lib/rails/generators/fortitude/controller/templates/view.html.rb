class Views::<%= class_name.camelize %>::<%= @action.camelize %> < Views::Base
  def content
    h1 "<%= class_name %>#<%= @action %>"
    p "Find me in <%= @path %>"
  end
end
