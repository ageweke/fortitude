module Views
  module Admin
    module Users
      class BooleanUserPreference < Views::Shared::Base
        needs :user, :name, :display, :hint

        disable_parcels!

        def content
          div(:class => [ :input, :boolean, :optional, :field_with_hint ]) {
            input :name => "user_preferences[#{name}]", :type => :hidden, :value => "0"
            label(:class => "boolean optional control-label checkbox", :for => "user_preferences_#{name}") {
              input :class => [ :boolean, :optional ], :id => "user_preferences_#{name}", :name => "user_preferences_#{name}",
                :type => :checkbox, :value => 1
              text display
            }
            span(hint, :class => :hint)
            div(:class => :input_error) {
              span(:class => :tooltip)
            }
          }
        end
      end
    end
  end
end
