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
      require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'fortitude_native_ext'))
    end

    native_loaded = true
  rescue LoadError => le
    $stderr.puts <<-EOM
WARNING: The Fortitude gem cannot load its native extensions. Performance may be reduced by a factor of 3-5x!
         Load path:
            #{$:.join("\n            ")}
         Error: #{le.message} (#{le.class})
EOM
    native_loaded = false
  end
end

unless native_loaded
  require 'fortitude/extensions/fortitude_ruby_ext'
end

require 'active_support'

::ActiveSupport::SafeBuffer.class_eval { public :original_concat } if defined?(::ActiveSupport::SafeBuffer)
