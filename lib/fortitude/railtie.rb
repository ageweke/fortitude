if defined?(ActiveSupport)
  ActiveSupport.on_load(:before_initialize) do
    ActiveSupport.on_load(:action_view) do
      require "fortitude/rails/template_handler"
    end
  end
end

module Fortitude
  class Railtie < ::Rails::Railtie
    initializer :fortitude, :before => :set_autoload_paths do |app|
      views_root = File.expand_path(File.join(::Rails.root, 'app', 'views'))

      ::ActiveSupport::Dependencies.module_eval do
        @@_fortitude_views_root = views_root

        def loadable_constants_for_path_with_fortitude(path, bases = autoload_paths)
          path = $` if path =~ /\.rb\z/
          expanded_path = File.expand_path(path)

          if %r{\A#{Regexp.escape(@@_fortitude_views_root)}(/|\\)} =~ expanded_path
            nesting = "views" + expanded_path[(@@_fortitude_views_root.size)..-1]
            [ nesting.camelize ]
          else
            loadable_constants_for_path_without_fortitude(path, bases)
          end
        end

        alias_method_chain :loadable_constants_for_path, :fortitude

        def autoloadable_module_with_fortitude?(path_suffix)
          if path_suffix =~ %r{^views(/.*)?$}i
            subpath = $1

            out = if subpath && subpath.length > 0
              File.join(@@_fortitude_views_root, subpath)
            else
              @@_fortitude_views_root
            end
            out
          else
            autoloadable_module_without_fortitude?(path_suffix)
          end
        end

        alias_method_chain :autoloadable_module?, :fortitude
      end


      require "fortitude/rails/template_handler"
    end
  end
end
