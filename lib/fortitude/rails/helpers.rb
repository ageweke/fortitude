module Fortitude
  module Rails
    module Helpers
      class << self
        def helper(name, options = { })
          @helpers ||= { }
          @helpers[name] = options
        end

        def apply_refined_helpers_to!(o)
          @helpers.each do |name, options|
            o.helper(name, options)
          end
        end
      end

      # tags/
      # active_model_helper
      # asset_tag_helper
      helper :javascript_include_tag, :transform => :output_return_value
      helper :stylesheet_link_tag, :transform => :output_return_value
      helper :auto_discovery_link_tag, :transform => :output_return_value
      helper :favicon_link_tag, :transform => :output_return_value
      helper :image_tag, :transform => :output_return_value
      helper :video_tag, :transform => :output_return_value
      helper :audio_tag, :transform => :output_return_value

      # asset_url_helper
      # atom_feed_helper
      # cache_helper
      # capture_helper
      # controller_helper
      # csrf_helper
      helper :csrf_meta_tags, :transform => :output_return_value

      # date_helper
      helper :date_select, :transform => :output_return_value
      helper :time_select, :transform => :output_return_value
      helper :datetime_select, :transform => :output_return_value
      helper :select_datetime, :transform => :output_return_value
      helper :select_date, :transform => :output_return_value
      helper :select_time, :transform => :output_return_value
      helper :select_second, :transform => :output_return_value
      helper :select_minute, :transform => :output_return_value
      helper :select_hour, :transform => :output_return_value
      helper :select_day, :transform => :output_return_value
      helper :select_month, :transform => :output_return_value
      helper :select_year, :transform => :output_return_value
      helper :time_tag, :transform => :output_return_value

      # debug_helper
      helper :debug, :transform => :output_return_value

      # form_helper
      helper :form_for, :transform => :output_return_value,
        :output_yielded_methods => %w{check_box color_field date_field datetime_field datetime_local_field email_field} +
          %w{file_field hidden_field label month_field number_field password_field phone_field radio_button} +
          %w{range_field search_field telephone_field text_area text_field time_field url_field week_field}
      helper :fields_for, :transform => :output_return_value

      # form_options_helper
      # helper :select, :transform => :output_return_value # conflicts with HTML <select> tag
      helper :collection_select, :transform => :output_return_value
      helper :grouped_collection_select, :transform => :output_return_value
      helper :time_zone_select, :transform => :output_return_value
      helper :options_for_select, :transform => :output_return_value
      helper :options_from_collection_for_select, :transform => :output_return_value
      helper :option_groups_from_collection_for_select, :transform => :output_return_value
      helper :grouped_options_for_select, :transform => :output_return_value
      helper :time_zone_options_for_select, :transform => :output_return_value
      helper :collection_radio_buttons, :transform => :output_return_value
      helper :collection_check_boxes, :transform => :output_return_value

      # form_tag_helper
      helper :form_tag, :transform => :output_return_value
      helper :select_tag, :transform => :output_return_value
      helper :text_field_tag, :transform => :output_return_value
      helper :label_tag, :transform => :output_return_value
      helper :hidden_field_tag, :transform => :output_return_value
      helper :file_field_tag, :transform => :output_return_value
      helper :password_field_tag, :transform => :output_return_value
      helper :text_area_tag, :transform => :output_return_value
      helper :check_box_tag, :transform => :output_return_value
      helper :radio_button_tag, :transform => :output_return_value
      helper :submit_tag, :transform => :output_return_value
      helper :button_tag, :transform => :output_return_value
      helper :image_submit_tag, :transform => :output_return_value
      helper :field_set_tag, :transform => :output_return_value
      helper :color_field_tag, :transform => :output_return_value
      helper :search_field_tag, :transform => :output_return_value
      helper :telephone_field_tag, :transform => :output_return_value
      helper :phone_field_tag, :transform => :output_return_value
      helper :date_field_tag, :transform => :output_return_value
      helper :time_field_tag, :transform => :output_return_value
      helper :datetime_field_tag, :transform => :output_return_value
      helper :datetime_local_field_tag, :transform => :output_return_value
      helper :month_field_tag, :transform => :output_return_value
      helper :week_field_tag, :transform => :output_return_value
      helper :url_field_tag, :transform => :output_return_value
      helper :email_field_tag, :transform => :output_return_value
      helper :number_field_tag, :transform => :output_return_value
      helper :range_field_tag, :transform => :output_return_value
      helper :utf8_enforcer_tag, :transform => :output_return_value

      # javascript_helper
      helper :javascript_tag, :transform => :output_return_value
      helper :javascript_cdata_section, :transform => :output_return_value
      helper :button_to_function, :transform => :output_return_value
      helper :link_to_function, :transform => :output_return_value

      # number_helper
      # output_safety_helper
      # record_tag_helper
      helper :div_for, :transform => :output_return_value
      helper :content_tag_for, :transform => :output_return_value

      # rendering_helper
      # #render is special-cased; Widget implements it directly

      # sanitize_helper
      # tag_helper
      # #tag conflicts with Widget's #tag method, and probably isn't something you want anyway
      helper :content_tag, :transform => :output_return_value
      helper :cdata_section, :transform => :output_return_value

      # text_helper
      # translation_helper
      # url_helper
      helper :link_to, :transform => :output_return_value
      helper :button_to, :transform => :output_return_value
      helper :link_to_unless_current, :transform => :output_return_value
      helper :link_to_unless, :transform => :output_return_value
      helper :link_to_if, :transform => :output_return_value
      helper :mail_to, :transform => :output_return_value

      helper :capture
    end
  end
end
