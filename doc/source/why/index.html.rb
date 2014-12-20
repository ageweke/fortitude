module Views
  module Why
    class Index < Views::Shared::Base
      def content
        h1 "hello"
      end
    end
  end
end
