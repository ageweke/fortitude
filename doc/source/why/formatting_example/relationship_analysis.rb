module Views
  module Why
    module FormattingExample
      class RelationshipAnalysis < Views::Shared::Base
        def content
          h4 "Friend Relationship Analysis"

          a "View Relationship Analysis", :href => "/admin/relationships/4832424"
          br
          a "View Relationship Analysis as CSV", :href => "/admin/relationships/4832424.csv"
        end
      end
    end
  end
end
