module Views
  module Shared
    class Base < Fortitude::Widget
      doctype :html5

      format_output                 true
      start_and_end_comments        true
      debug                         true
      enforce_element_nesting_rules true
      enforce_attribute_rules       true
      enforce_id_uniqueness         true

      enable_parcels!
    end
  end
end
