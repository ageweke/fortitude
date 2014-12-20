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
      font-family: $body-font;
    }

    ul {
      text-align: center;
      list-style-type: none;
      padding-left: 0;

      margin-top: 100px;
      margin-left: auto;
      margin-right: -2%;

      li {
        width: 31%;
        float: left;
        margin-right: 2%;

        h3 {
          padding-top: 15px;
          padding-bottom: 15px;
        }

        a {
          color: $highlight-color;

          &:link h3 {
            background-color: $bold-translucent;
          }
        }
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
        big_nav_link "Why use Fortitude?", "/why"
        big_nav_link "Getting Started", "/getting-started"
        big_nav_link "Reference", "/reference"
      }
    }
  end

  def big_nav_link(text, to_where)
    li {
      a(:href => to_where) {
        h3 text, :class => 'nav-link'
      }
    }
  end
end
