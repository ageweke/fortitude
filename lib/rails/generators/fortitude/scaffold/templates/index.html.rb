class Views::<%= plural_table_name.camelize %>::Index < Views::Base
  needs :<%= plural_table_name %>, :notice => nil

  def content
    p notice, :id => :notice

    h1 "<%= plural_table_name.titleize %>"

    table {
      thead {
        tr {
          <% attributes.reject { |a| a.respond_to?(:password_digest?) && a.password_digest? }.each do |attribute| -%>
th "<%= attribute.human_name %>"
          <% end -%>
th
          th
          th
        }
      }

      tbody {
        <%= plural_table_name %>.each do |<%= singular_table_name %>|
          tr {
<% attributes.reject { |a| a.respond_to?(:password_digest?) && a.password_digest? }.each do |attribute| -%>
            td <%= singular_table_name %>.<%= attribute.name %>
<% end -%>
            td {
              link_to 'Show', <%= singular_table_name %>
            }
            td {
              link_to 'Edit', edit_<%= singular_table_name %>_path(<%= singular_table_name %>)
            }
            td {
              link_to 'Destroy', <%= singular_table_name %>, :method => :delete, :data => { :confirm => 'Are you sure?' }
            }
          }
        end
      }
    }

    br

    link_to 'New <%= singular_table_name.titleize %>', new_<%= singular_table_name %>_path
  end
end
