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
      margin-left: auto;
      margin-right: auto;
      margin-top: 60px;
    }

    h3 {
      font-weight: 400;
      font-size: 200%;
    }

    ul {
      text-align: center;
      list-style-type: none;
      padding-left: 0;

      margin-top: 100px;
      margin-left: auto;
      margin-right: auto;

      li {
        width: 33%;
        float: left;
      }
    }

    padding-top: 120px;
    padding-bottom: 150px;
  }


  def content
    div(:class => :jumbotron) {
      h1 "Fortitude"
      h2 "Beautifully-factored HTML views for your Ruby or Rails application.", :class => :subhead

      ul {
        li {
          h3 "Why use Fortitude?"
        }
        li {
          h3 "Getting Started"
        }
        li {
          h3 "Reference"
        }
      }
    }
  end
end
