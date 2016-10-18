<%
our_class_name = class_name.camelize
our_class_name += "Mailer" if @path =~ %r{_mailer/}
-%>
class Views::<%= our_class_name %>::<%= @action.camelize %> < Views::Base
  needs :greeting

  def content
    h1 "<%= class_name %>#<%= @action %>"
    p "#{greeting}, find me in <%= @path %>"
  end
end
