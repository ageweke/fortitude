class HelpersUnrefinedSystemSpecController < ApplicationController
  # This works around a bug in Rails 3.0.x for image_tag and other asset_tag methods
  config.relative_url_root ||= ""

  def helpers_that_output_when_refined
  end
end
