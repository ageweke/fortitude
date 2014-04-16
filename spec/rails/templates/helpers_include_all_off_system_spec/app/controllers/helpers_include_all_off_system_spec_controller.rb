class HelpersIncludeAllOffSystemSpecController < ApplicationController
  # Rails 3.0.x doesn't support config.action_controller.include_all_helpers=; as a result, we skip that call in
  # config/application.rb, and use "clear_helpers; helper :application" in the actual
  # HelpersIncludeAllOffSystemSpecController to simulate that behavior.
  unless Rails.application.config.action_controller.respond_to?(:include_all_helpers=)
    clear_helpers
    helper :application
  end

  def include_all_off
    # nothing here
  end
end
