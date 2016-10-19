module Fortitude
  module Rails
    module Helpers
      class << self
        def helper(name, options = { })
          @helpers ||= { }
          @helpers[normalize_helper_name(name)] = options
        end

        def helper_options(name)
          @helpers[normalize_helper_name(name)]
        end

        def apply_refined_helpers_to!(o)
          @helpers.each do |name, options|
            o.helper(name, options)
          end

          url_helpers_module = ::Rails.application.routes.url_helpers

          test_base_class = Class.new
          test_base_instance = test_base_class.new

          test_class = Class.new
          test_class.send(:include, url_helpers_module)
          test_instance = test_class.new

          metaclass = o.instance_eval("class << self; self; end")

          metaclass.send(:define_method, :_fortitude_allow_helper_even_without_automatic_helper_access?) do |method_name|
            test_instance.respond_to?(method_name) && (! test_base_instance.respond_to?(method_name))
          end
        end

        ALL_BUILTIN_HELPER_MODULES = {
          ActionView::Helpers => %w{
            ActiveModelHelper
            ActiveModelInstanceTag
            AssetTagHelper
            AssetUrlHelper
            AtomFeedHelper
            CacheHelper
            CaptureHelper
            CsrfHelper
            DateHelper
            DebugHelper
            FormHelper
            FormOptionsHelper
            FormTagHelper
            JavaScriptHelper
            NumberHelper
            OutputSafetyHelper
            RecordTagHelper
            SanitizeHelper
            TagHelper
            TextHelper
            TranslationHelper
            UrlHelper
          }
        }

        # We could use the mechanism used above for the url_helpers_module, but this makes access to these helpers
        # much faster -- they end up with real methods defined for them, instead of using method_missing magic
        # every time. We don't necessarily want to do that for the url_helpers_module, because there can be tons and
        # tons of methods in there...and because we initialize early-enough on that methods aren't defined there yet,
        # anyway.
        def declare_all_builtin_rails_helpers!
          ALL_BUILTIN_HELPER_MODULES.each do |base_module, constant_names|
            constant_names.each do |constant_name|
              if base_module.const_defined?(constant_name)
                helper_module = base_module.const_get(constant_name)
                helper_module.public_instance_methods.each do |helper_method_name|
                  # This is because ActionView::Helpers::FormTagHelper exposes #embed_authenticity_token_in_remote_forms=
                  # as a public instance method. This seems like it should not be included as a helper.
                  # next if helper_method_name.to_s == 'embed_authenticity_token_in_remote_forms='
                  helper helper_method_name
                end
              end
            end
          end

          helper :default_url_options
        end

        private
        def normalize_helper_name(name)
          name.to_s.strip.downcase.to_sym
        end
      end

      # This gives us all built-in Rails helpers, whether they're refined or not; our re-declarations of helpers,
      # below, will override any of these. We need to grab all built-in Rails helpers because we want them all
      # formally declared -- that is, even if +automatic_helper_access+ is set to +false+, built-in Rails helpers
      # should still work properly.
      declare_all_builtin_rails_helpers!

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
      helper :csrf_meta_tag, :transform => :output_return_value

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
      FORM_FOR_YIELDED_METHODS_TO_OUTPUT =
        # Directly from form_helper
        %w{button check_box color_field date_field datetime_field datetime_local_field} +
        %w{email_field file_field hidden_field label month_field number_field password_field phone_field} +
        %w{radio_button range_field search_field submit telephone_field text_area text_field time_field url_field} +
        %w{week_field} +

        # From form_options_helper
        %w{select collection_select grouped_collection_select time_zone_select options_for_select} +
        %w{options_from_collection_for_select option_groups_from_collection_for_select grouped_options_for_select} +
        %w{time_zone_options_for_select collection_radio_buttons collection_check_boxes} +

        # And these can nest inside each other
        %w{form_for fields_for}

      helper :form_for, :transform => :output_return_value, :output_yielded_methods => FORM_FOR_YIELDED_METHODS_TO_OUTPUT
      helper :fields_for, :transform => :output_return_value, :output_yielded_methods => FORM_FOR_YIELDED_METHODS_TO_OUTPUT

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
