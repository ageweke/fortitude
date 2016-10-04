module Fortitude
  module MethodOverriding
    class << self
      def override_methods(target_module, override_methods_module, feature_name, method_names)
        if RUBY_VERSION =~ /^2\./
          override_methods_using_prepend(target_module, override_methods_module, feature_name, method_names)
        else
          override_methods_using_alias_method_chain(target_module, override_methods_module, feature_name, method_names)
        end
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

      def override_methods_using_alias_method_chain(target_module, override_methods_module, feature_name, method_names = nil)
        method_names.each do |method_name|
          universal_name = universal_method_name(method_name, feature_name)
          with_name = with_feature_name(method_name, feature_name)
          without_name = without_feature_name(method_name, feature_name)

          override_methods_module.class_eval <<-EOS
  def #{with_name}(*args, &block)
    original_method = Proc.new { |*args, &block| #{without_name}(*args, &block) }
    #{universal_name}(original_method, *args, &block)
  end
EOS

          target_module.send(:include, override_methods_module)
          target_module.send(:alias_method_chain, method_name, feature_name)
        end
      end

      def suffix_method_name(method_name, suffix)
        if method_name =~ /^(.*?)([\?\_\!]+)$/i
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
