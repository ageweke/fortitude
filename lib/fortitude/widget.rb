require 'fortitude/widget/widget_class_inheritable_attributes'
require 'fortitude/widget/tags'
require 'fortitude/widget/needs'
require 'fortitude/widget/modules_and_subclasses'
require 'fortitude/widget/doctypes'
require 'fortitude/widget/start_and_end_comments'
require 'fortitude/widget/tag_like_methods'
require 'fortitude/widget/staticization'
require 'fortitude/widget/integration'
require 'fortitude/widget/content'
require 'fortitude/widget/around_content'
require 'fortitude/widget/localization'
require 'fortitude/widget/helpers'
require 'fortitude/widget/capturing'
require 'fortitude/widget/rendering'
require 'fortitude/widget/temporary_overrides'
require 'fortitude/widget/files'
require 'fortitude/widget/convenience'

require 'fortitude/doctypes'

module Fortitude
  # TODO: rename all non-interface methods as _fortitude_*
  # TODO: Make 'element' vs. 'tag' naming consistent
  # TODO: Make naming consistent across enforcement/validation/rules (tag nesting, attributes, ID uniqueness)
  class Widget
    include Fortitude::Widget::WidgetClassInheritableAttributes
    include Fortitude::Widget::Tags
    include Fortitude::Widget::Needs
    include Fortitude::Widget::ModulesAndSubclasses
    include Fortitude::Widget::Doctypes
    include Fortitude::Widget::StartAndEndComments
    include Fortitude::Widget::TagLikeMethods
    include Fortitude::Widget::Staticization
    include Fortitude::Widget::Integration
    include Fortitude::Widget::Content
    include Fortitude::Widget::AroundContent
    include Fortitude::Widget::Localization
    include Fortitude::Widget::Helpers
    include Fortitude::Widget::Capturing
    include Fortitude::Widget::Rendering
    include Fortitude::Widget::TemporaryOverrides
    include Fortitude::Widget::Files
    include Fortitude::Widget::Convenience

    if defined?(::Rails)
      require 'fortitude/rails/widget_methods'
      include Fortitude::Rails::WidgetMethods

      require 'fortitude/widget/caching'
      include Fortitude::Widget::Caching
    else
      require 'fortitude/widget/non_rails_widget_methods'
      include Fortitude::Widget::NonRailsWidgetMethods
    end

    rebuild_run_content!(:initial_setup)
    invalidate_needs!(:initial_setup)
    rebuild_text_methods!(:initial_setup)
  end
end
