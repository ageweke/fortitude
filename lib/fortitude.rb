require "fortitude/version"

module Fortitude
  module Widget
    autoload :Html5, 'fortitude/widget/html5'
    autoload :Html4Strict, 'fortitude/widget/html4_strict'
    autoload :Html4Transitional, 'fortitude/widget/html4_transitional'
    autoload :Html4Frameset, 'fortitude/widget/html4_frameset'
    autoload :Xhtml10Strict, 'fortitude/widget/xhtml10_strict'
    autoload :Xhtml10Transitional, 'fortitude/widget/xhtml10_transitional'
    autoload :Xhtml10Frameset, 'fortitude/widget/xhtml10_frameset'
    autoload :Xhtml11, 'fortitude/widget/xhtml11'
  end
end

# See if we can load Rails -- but don't fail if we can't; we'll just use this to decide whether we should
# load the Railtie or not.
begin
  gem 'rails'
rescue Gem::LoadError => le
  # ok
end

begin
  require 'rails'
rescue LoadError => le
  # ok
end

if defined?(::Rails)
  require 'action_view'

  require 'fortitude/rails/widget_methods'
  require 'fortitude/rails/renderer'
  require 'fortitude/rails/template_handler'
  require 'fortitude/railtie'
else
  require 'fortitude/non_rails_widget_methods'

  ::String.class_eval do
    alias_method :original_concat, :concat
  end
end

require 'fortitude/widget/base'

native_loaded = false

if %w{false off 0}.include?((ENV['FORTITUDE_NATIVE_EXTENSIONS'] || '').strip.downcase)
  $stderr.puts <<-EOM
WARNING: Fortitude native extensions disabled via environment variable FORTITUDE_NATIVE_EXTENSIONS.
         Performance may be significantly reduced.
EOM
else
  begin
    require File.join(File.dirname(__FILE__), 'fortitude_native_ext')
    native_loaded = true
  rescue LoadError => le
    $stderr.puts <<-EOM
WARNING: The Fortitude gem cannot load its native extensions. Performance may be significantly reduced.
         Error: #{le.message} (#{le.class})
EOM
    native_loaded = false
  end
end

unless native_loaded
  require 'fortitude/fortitude_ruby_ext'
end

if defined?(::ActiveSupport::SafeBuffer)
  ::ActiveSupport::SafeBuffer.class_eval do
    public :original_concat
  end
end
