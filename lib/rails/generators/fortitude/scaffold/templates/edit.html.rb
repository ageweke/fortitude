class Views::<%= plural_table_name.camelize %>::Edit < Views::Base
  needs :<%= singular_table_name %>

  def content
    h1 "Editing <%= singular_table_name.titleize %>"

    widget Views::<%= plural_table_name.camelize %>::Form, <%= singular_table_name %>: <%= singular_table_name %>

    link_to 'Show', <%= singular_table_name %>
    text " | "
    link_to 'Back', <%= index_helper %>_path
  end
end
