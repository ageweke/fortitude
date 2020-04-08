module Fortitude
  module MethodOverriding
    class << self
      # This is Fortitude’s way of maintaining compatibility both with Ruby < 2.0 (no support for Module#prepend)
      # and Ruby 2.0 and later (alias_method_chain is deprecated). Here’s how it works:
      #
      # * For a method 'foo' that you want to override using a 'feature name' of bar, you define a method called
      #   'foo_uniwith_bar' -- but not in the target module or class (containing the method to be overridden); rather,
      #   it must be in a separate Module, and, importantly, not one that you have already Module#include'd into the
      #   target module or class. This method has the same signature as the original, except that it also takes, as a first
      #   parameter, a #call'able object (typically a Proc or lambda) that represents the original, un-overridden
      #   method. You use this, instead of calling 'foo_without_bar' or 'super', in order to invoke the original
      #   method.
      # * You then call Fortitude::MethodOverriding.override_methods. +target_module+ is the module containing the
      #   method you want to override, +override_methods_module+ is the module containing your overriding method
      #   ('foo_uniwith_bar'), +feature_name+ is the name of the feature you're using ('bar'), and +method_names+
      #   is an Array of Symbols, each of which is the name of a method you want to override (_e.g._, 'foo').
      #
      # This class then performs the appropriate logic to use 'alias_method_chain' or Module#prepend appropriately.
      #
      # One exception: using Module#prepend seems to cause Fortitude all kinds of problems with JRuby 9.1.5.0 (as of
      # this writing, the latest version of JRuby). In particular, you get things like a java.lang.BootstrapMethodError
      # at "require at org/jruby/RubyKernel.java:956", and various java.lang.StackOverflowErrors that seem to make no
      # sense at all -- and if you use alias_method_chain instead, everything seems to work perfectly. As a result,
      # we currently fall back to using alias_method_chain on JRuby. (You only get deprecation warnings with this
      # when running with Rails 5, which is not yet supported by JRuby anyway, at least as of this writing.)
      def override_methods(target_module, override_methods_module, feature_name, method_names)
        override_methods_using_prepend(target_module, override_methods_module, feature_name, method_names)
      end

      private
      def override_methods_using_prepend(target_module, override_methods_module, feature_name, method_names)
        method_names.each do |method_name|
          universal_name = universal_method_name(method_name, feature_name)

          override_methods_module.class_eval <<-EOS
  def #{method_name}(*args, &block)
    original_method = Proc.new { |*args, &block| super(*args, &block) }
    #{universal_name}(original_method, *args, &block)
  end
EOS
        end

        target_module.send(:prepend, override_methods_module)
      end

      def suffix_method_name(method_name, suffix)
        if method_name.to_s =~ /^(.*?)([\?\_\!]+)$/i
          "#{$1}#{suffix}#{$2}"
        else
          "#{method_name}#{suffix}"
        end
      end

      def with_feature_name(method_name, feature_name)
        suffix_method_name(method_name, "_with_#{feature_name}")
      end

      def without_feature_name(method_name, feature_name)
        suffix_method_name(method_name, "_without_#{feature_name}")
      end

      def universal_method_name(method_name, feature_name)
        suffix_method_name(method_name, "_uniwith_#{feature_name}")
      end
    end
  end
end
