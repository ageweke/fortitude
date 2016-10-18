class Views::<%= plural_table_name.camelize %>::Form < Views::Base
  needs :<%= singular_table_name %>

  def content
    form_for(<%= singular_table_name %>) do |f|
      if <%= singular_table_name %>.errors.any?
        div(id: :error_explanation) {
          h2 {
            text pluralize(<%= singular_table_name %>.errors.count, "error")
            text " prohibited this <%= singular_table_name %> from being saved:"
          }

          ul {
            <%= singular_table_name %>.errors.full_messages.each do |message|
              li message
            end
          }
        }
      end

<% attributes.each do |attribute| -%>
<% if attribute.password_digest? -%>
      edit_field(f, :password_field, :password)
      edit_field(f, :password_field, :password_confirmation)
<% else -%>
      edit_field(f, :<%= attribute.field_type %>, :<%= attribute.column_name %>)
<% end -%>
<% end -%>

      div(class: :actions) { f.submit }
    end
  end

  def edit_field(form, field_type, column_name)
    div(class: :field) {
      form.label column_name
      form.send(field_type, column_name)
    }
  end
end
