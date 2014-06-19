require "fortitude/version"

module Fortitude
  module Widgets
    autoload :Html5, 'fortitude/widgets/html5'
    autoload :Html4Strict, 'fortitude/widgets/html4_strict'
    autoload :Html4Transitional, 'fortitude/widgets/html4_transitional'
    autoload :Html4Frameset, 'fortitude/widgets/html4_frameset'
    autoload :Xhtml10Strict, 'fortitude/widgets/xhtml10_strict'
    autoload :Xhtml10Transitional, 'fortitude/widgets/xhtml10_transitional'
    autoload :Xhtml10Frameset, 'fortitude/widgets/xhtml10_frameset'
    autoload :Xhtml11, 'fortitude/widgets/xhtml11'
  end

  module Doctypes
    autoload :Base, 'fortitude/doctypes/base'
    autoload :Html4, 'fortitude/doctypes/html4'
    autoload :Html4Frameset, 'fortitude/doctypes/html4_frameset'
    autoload :Html4Strict, 'fortitude/doctypes/html4_strict'
    autoload :Html4Transitional, 'fortitude/doctypes/html4_transitional'
    autoload :Html5, 'fortitude/doctypes/html5'
    autoload :Xhtml10, 'fortitude/doctypes/xhtml10'
    autoload :Xhtml10Frameset, 'fortitude/doctypes/xhtml10_frameset'
    autoload :Xhtml10Strict, 'fortitude/doctypes/xhtml10_strict'
    autoload :Xhtml10Transitional, 'fortitude/doctypes/xhtml10_transitional'
    autoload :Xhtml11, 'fortitude/doctypes/xhtml11'
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
  ::String.class_eval do
    alias_method :original_concat, :concat
  end
end

require 'fortitude/widget'

native_loaded = false

if %w{false off 0}.include?((ENV['FORTITUDE_NATIVE_EXTENSIONS'] || '').strip.downcase)
  $stderr.puts <<-EOM
WARNING: Fortitude native extensions disabled via environment variable FORTITUDE_NATIVE_EXTENSIONS.
         Performance may be reduced by a factor of 3-5x!
EOM
else
  begin
    if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'
      require 'fortitude_jruby_native_ext.jar'
    else
      require File.join(File.dirname(__FILE__), 'fortitude_native_ext')
    end

    native_loaded = true
  rescue LoadError => le
    $stderr.puts <<-EOM
WARNING: The Fortitude gem cannot load its native extensions. Performance may be reduced by a factor of 3-5x!
         Load path: #{$:.inspect}
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

begin
  gem 'tilt'
rescue Gem::LoadError => le
  # ok
end

begin
  require 'tilt'
rescue LoadError => le
  # ok, whatever
end

if defined?(::Tilt)
  require 'fortitude/tilt/fortitude_template'

  Tilt.register(Fortitude::Tilt::FortitudeTemplate, 'rb')
end

require 'fortitude/rendering_context'
