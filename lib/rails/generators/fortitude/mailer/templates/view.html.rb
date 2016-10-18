class Views::<%= class_name.camelize %>Mailer::<%= @action.camelize %> < Views::Base
  needs :greeting

  def content
    h1 "<%= class_name %>#<%= @action %>"
    p "#{greeting}, find me in <%= @path %>"
  end
end
