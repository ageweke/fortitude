module Views
  module DevelopmentModeSystemSpec
    class Form < Views::Base
      needs :label

      def content
        p(label)
      end
    end
  end
end
