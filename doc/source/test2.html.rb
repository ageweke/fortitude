class Views::Test2 < ::Views::Shared::Base
  css %{
    p { color: green; }
  }

  def content
    h1 "hi hi, test2h!"

    div {
      p "this is a test"
    }
  end
end
