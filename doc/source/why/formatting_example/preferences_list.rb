module Views
  module Why
    module FormattingExample
      class PreferencesList < Views::Shared::Base
        def content
          require 'source/why/formatting_example/boolean_user_preference'
          require 'source/why/formatting_example/string_user_preference'

          form {
            widget Views::Why::FormattingExample::BooleanUserPreference, :name => 'visible_to_public',
              :display => 'Visible to Public', :hint => 'Enable visiblity to public'
            widget Views::Why::FormattingExample::BooleanUserPreference, :name => 'email_over_sms',
              :display => 'Prefer email to SMS for communication', :hint => 'Prefer sending email to sending SMSes'
            widget Views::Why::FormattingExample::StringUserPreference, :name => 'name_override',
              :display => 'Show this name to public instead',
              :hint => "Specify custom name to be shown instead of user's actual name"

            input :name => :commit, :type => :submit, :value => 'Update User Preferences'
          }
        end
      end
    end
  end
end
