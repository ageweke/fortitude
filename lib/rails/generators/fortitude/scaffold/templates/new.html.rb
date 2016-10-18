class Views::<%= plural_table_name.camelize %>::New < Views::Base
  needs :<%= singular_table_name %> => nil

  def content
    h1 "New <%= singular_table_name.titleize %>"

    widget Views::<%= plural_table_name.camelize %>::Form, :<%= singular_table_name %> => <%= singular_table_name %>

    link_to 'Back', <%= index_helper %>_path
  end
end
