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

            if subpath.blank? || File.directory?(File.join(@@_fortitude_views_root, subpath))
              log "autoloadable_module_with_fortitude?(#{path_suffix.inspect}) WITH -> #{@@_fortitude_views_root}"
              return @@_fortitude_views_root
            end
          end

          out = autoloadable_module_without_fortitude?(path_suffix)
          log "autoloadable_module_without_fortitude?(#{path_suffix.inspect}) -> #{out.inspect}"
          out
        end

        alias_method_chain :autoloadable_module?, :fortitude

        def search_for_file_with_fortitude(path_suffix)
          path_suffix = path_suffix.sub(/(\.rb)?$/, ".rb")

          if path_suffix =~ %r{^views(/.*)$}i
            path = File.join(@@_fortitude_views_root, $1)
            return path if File.file?(path)
          end

          return search_for_file_without_fortitude(path_suffix)
        end

        alias_method_chain :search_for_file, :fortitude
      end

      ::ActiveSupport::Dependencies.autoload_paths << views_root

      ::ActionView::PathResolver.class_eval do
        def find_templates_with_fortitude(name, prefix, partial, details)
          templates = find_templates_without_fortitude(name, prefix, partial, details)
          if partial && templates.empty? && details[:handlers] && details[:handlers].include?(:rb)
            templates = find_templates_without_fortitude(name, prefix, false, details.merge(:handlers => [ :rb ]))
          end
          templates
        end

        alias_method_chain :find_templates, :fortitude
      end


      require "fortitude/rails/template_handler"
    end
  end
end
