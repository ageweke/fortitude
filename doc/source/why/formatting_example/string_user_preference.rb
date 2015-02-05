module Views
  module Admin
    module Users
      class StringUserPreference < Views::Shared::Base
        needs :user, :name, :display, :hint

        disable_parcels!

        def content
          div(:class => [ :input, :string, :optional, :field_with_hint ]) {
            label(:class => "string optional control-label", :for => "user_preferences_#{name}") {
              text display
            }
            input :class => [ :string, :optional ], :id => "user_preferences_#{name}", :name => "user_preferences_#{name}",
              :size => 50, :style => 'width: 1070px', :type => :text, :value => ""
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
