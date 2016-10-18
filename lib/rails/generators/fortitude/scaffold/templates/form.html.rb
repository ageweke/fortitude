class Views::<%= plural_table_name.camelize %>::Form < Views::Base
  needs :<%= singular_table_name %>

  def content
    form_for(<%= singular_table_name %>) do |f|
      if <%= singular_table_name %>.errors.any?
        div(:id => :error_explanation) {
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
<% if attribute.respond_to?(:password_digest?) && attribute.password_digest? -%>
      div(:class => :field) {
        f.label :password
        f.password_field :password
      }

      div(:class => :field) {
        f.label :password_confirmation
        f.password_field :password_confirmation
      }
<% else -%>
<% name = if attribute.respond_to?(:column_name) then attribute.column_name else attribute.name end -%>
      div(:class => :field) {
        f.label :<%= name %>
        f.<%= attribute.field_type %> :<%= name %>
      }
<% end -%>
<% end -%>

      div(:class => :actions) { f.submit }
    end
  end
end
