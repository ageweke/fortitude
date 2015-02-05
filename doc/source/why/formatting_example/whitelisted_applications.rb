module Views
  module Admin
    module Users
      class WhitelistedApplications < Views::Shared::Base
        needs :user

        disable_parcels!

        def content
          h4 "Whitelisted Applications"
        end
      end
    end
  end
end
