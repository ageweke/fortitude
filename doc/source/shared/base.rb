require 'source/shared/common'
require 'source/portable/fortitude-bootstrap'
require 'source/portable/fortitude_retina_images'

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

      helper :stylesheet_link_tag, :transform => :output_return_value
      helper :javascript_include_tag, :transform => :output_return_value

      css_prefix %{
@import "#{File.expand_path(File.join(File.dirname(__FILE__), '..', 'stylesheets', '_shared_prefix.scss'))}";
}

      include ::FortitudeBootstrap
      include ::FortitudeRetinaImages
      include ::Views::Shared::Common

      retina_image_base_directory File.join(File.dirname(File.dirname(__FILE__)), 'images') => '/images'
    end
  end
end
