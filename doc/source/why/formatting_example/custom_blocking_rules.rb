module Views
  module Admin
    module Users
      class CustomBlockingRules < Views::Shared::Base
        needs :user

        disable_parcels!

        def content
          h4 "Custom Blocking Rules"

          table(:class => :readable) {
            thead {
              tr {
                th "type"
                th "pattern"
                th "rules"
                th "actions"
              }
            }
            tbody
          }
          a('create blocking patterns', :href => '/admin/users/4832424/blocking_rules/new')
        end
      end
    end
  end
end
