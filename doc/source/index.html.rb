class Views::Index < ::Views::Shared::Base
  css %{
    @at-root div\#{&} {
      background-color: $background-color;
      color: $bold-color;
      text-align: center;
    }

    h2 {
      font-family: $body-font;
      color: $highlight-color;
      width: 50%;
      margin-left: auto;
      margin-right: auto;
      margin-top: 60px;
    }

    padding-top: 120px;
    padding-bottom: 150px;
  }


  def content
    div(:class => :jumbotron) {
      h1 "Fortitude"

      h2 "Beautifully-factored HTML views for your Ruby or Rails application.", :class => :subhead
    }
  end
end
