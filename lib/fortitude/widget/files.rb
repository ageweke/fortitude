require 'active_support'
require 'active_support/concern'

module Fortitude
  class Widget
    module Files
      extend ActiveSupport::Concern

      class CannotDetermineWidgetClassNameError < StandardError
        attr_reader :tried_class_names, :filename, :magic_comment_texts, :resulting_objects, :class_names_to_try

        def initialize(tried_class_names, options = { })
          options.assert_valid_keys(:filename, :magic_comment_texts, :resulting_objects, :class_names_to_try)

          @tried_class_names = tried_class_names
          @filename = options[:filename]
          @magic_comment_texts = options[:magic_comment_texts]
          @resulting_objects = options[:resulting_objects]
          @class_names_to_try = options[:class_names_to_try]
          from_what = filename ? "from the file '#{filename}'" : "from some Fortitude source code"

          super %{You asked for a Fortitude widget class #{from_what},
but we couldn't determine the class name of the widget that supposedly is inside.

We tried the following class names, in order:

#{tried_class_names.join("\n")}

...but none of them both existed and were a class that eventually inherits from
::Fortitude::Widget. (We got back resulting objects: #{resulting_objects.inspect})

You can either pass the class name into this method via the :class_names_to_try option
(we were passed #{class_names_to_try.inspect}),
or add a "magic comment" to the source code of this widget that looks like this:

#!<token>: <class_name>

...where <token> is one of: #{magic_comment_texts.join(", ")}}
        end
      end

      module ClassMethods
        def widget_class_from_file(filename, options = { })
          options.assert_valid_keys(:root_dirs, :class_names_to_try, :magic_comment_text, :valid_base_classes)
          filename = File.expand_path(filename)
          source = File.read(filename)

          class_names_to_try = Array(options[:class_names_to_try])
          root_dirs = Array(options[:root_dirs])

          root_dirs.each do |root_dir|
            root_dir = File.expand_path(root_dir)

            if filename[0..(root_dir.length - 1)].downcase == root_dir.downcase
              subpath = filename[(root_dir.length + 1)..-1]
              subpath = $1 if subpath =~ %r{^(.*?)\.[^/]+$}i # remove all extensions
              class_names_to_try << subpath.camelize if subpath && subpath.length > 1
            end
          end

          widget_class_from_source(source,
            :class_names_to_try => class_names_to_try, :magic_comment_text => options[:magic_comment_text],
            :filename => filename, :valid_base_classes => options[:valid_base_classes])
        end

        def widget_class_from_source(source, options = { })
          options.assert_valid_keys(:class_names_to_try, :magic_comment_text, :filename, :valid_base_classes)

          magic_comment_texts = Array(options[:magic_comment_text]) + DEFAULT_MAGIC_COMMENT_TEXTS
          all_class_names =
            magic_comment_class_from(source, magic_comment_texts) +
            Array(options[:class_names_to_try]) +
            scan_source_for_possible_class_names(source)

          out = widget_class_from_class_names(all_class_names, :valid_base_classes => options[:valid_base_classes])
          resulting_objects = out[:resulting_objects]

          unless out[:widget_class]
            if options[:filename]
              require options[:filename]
            else
              ::Object.class_eval(source)
            end

            out = widget_class_from_class_names(all_class_names, :valid_base_classes => options[:valid_base_classes])
            resulting_objects += out[:resulting_objects]
          end

          out[:widget_class] || (
            raise CannotDetermineWidgetClassNameError.new(all_class_names, :magic_comment_texts => magic_comment_texts,
              :filename => options[:filename], :resulting_objects => resulting_objects,
              :class_names_to_try => options[:class_names_to_try]))
        end

        private
        DEFAULT_MAGIC_COMMENT_TEXTS = %w{fortitude_class}

        def magic_comment_class_from(source, magic_comment_texts)
          magic_comment_texts = magic_comment_texts.map { |c| c.to_s.strip.downcase }.uniq

          out = [ ]
          source.scan(/^\s*\#\s*\!\s*(\S+)\s*:\s*([A-Za-z0-9_:]+)\s*$/) do |(comment_text, class_name)|
            out << class_name if magic_comment_texts.include?(comment_text.strip.downcase)
          end
          out
        end

        def scan_source_for_possible_class_names(source)
          out = [ ]
          module_nesting = [ ]

          source.scan(/\bmodule\s+([A-Za-z0-9_:]+)/) do |match_data|
            module_name = match_data[0]
            module_nesting << module_name
          end

          source.scan(/\bclass\s+([A-Za-z0-9_:]+)/) do |match_data|
            class_name = match_data[0]
            out << class_name
          end

          out.uniq!

          while module_nesting.length > 0
            possible_module_name = module_nesting.join("::")
            out.reverse.each do |class_name|
              out.push("#{possible_module_name}::#{class_name}")
            end
            out.push(possible_module_name)
            module_nesting.pop
          end

          out
        end

        def widget_class_from_class_names(class_names, options = { })
          options.assert_valid_keys(:valid_base_classes)

          out = {
            :widget_class      => nil,
            :resulting_objects => [ ]
          }

          class_names.each do |class_name|
            class_name = $1 if class_name =~ /^:+(.*)$/i
            klass = begin
              "::#{class_name}".constantize
            rescue NameError => ne
              nil
            end

            if is_widget_class?(klass, options)
              out[:widget_class] = klass
              break
            elsif klass
              out[:resulting_objects] << klass
            end
          end
          out
        end

        def is_widget_class?(klass, options = { })
          options.assert_valid_keys(:valid_base_classes)

          valid_base_classes = Array(options[:valid_base_classes] || ::Fortitude::Widget)

          if (! klass)
            false
          elsif (! klass.kind_of?(Class))
            false
          elsif valid_base_classes.include?(klass)
            true
          else
            is_widget_class?(klass.superclass, :valid_base_classes => valid_base_classes)
          end
        end
      end
    end
  end
end
