class Views::Test2 < ::Views::Shared::Base
  css %{
    p { color: green; }
    h3 { color: purple; }
  }

  def content
    h1 "hi hi, test2h!"

    div {
      p "this is a test"
    }

    section {
      h3 "ho ho ho!"
    }
  end
end
