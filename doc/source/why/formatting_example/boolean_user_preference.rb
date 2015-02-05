module Views
  module Why
    module FormattingExample
      class BooleanUserPreference < Views::Shared::Base
        needs :name, :display, :hint

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
