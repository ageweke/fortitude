require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module HelpersIncludeAllOffSystemSpec
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Rails 3.0.x doesn't support config.action_controller.include_all_helpers=; as a result, we skip that call in
    # config/application.rb, and use "clear_helpers; helper :application" in the actual
    # HelpersIncludeAllOffSystemSpecController to simulate that behavior.
    config.action_controller.include_all_helpers = false if config.action_controller.respond_to?(:include_all_helpers=)
  end
end
