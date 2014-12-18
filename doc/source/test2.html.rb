class Views::Test2 < ::Views::Shared::Base
  def content
    div(:class => 'container') {
      h1 "hi hi, test2h!"

      div {
        p "this is a test"
      }

      section {
        h3 "ho ho ho!"
      }
    }
  end
end
