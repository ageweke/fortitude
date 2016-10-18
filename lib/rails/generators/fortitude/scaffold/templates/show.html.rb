class Views::<%= plural_table_name.camelize %>::Show < Views::Base
  needs :<%= singular_table_name %>, :notice => nil

  def content
    p notice, id: :notice

<% attributes.reject(&:password_digest?).each do |attribute| -%>
    p {
      strong "<%= attribute.human_name %>:"
      text <%= singular_table_name %>.<%= attribute.name %>
    }
<% end %>

    link_to 'Edit", edit_<%= singular_table_name %>_path(<%= singular_table_name %>)
    text " | "
    link_to 'Back', <%= index_helper %>_path
  end
end
