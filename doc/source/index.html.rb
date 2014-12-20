class Views::Index < ::Views::Shared::Base
  css %{
    background-color: $background-color;
    padding-bottom: 120px;

    .jumbotron {
      color: $bold-color;
      text-align: center;
      padding-top: 120px;
      padding-bottom: 60px;
      background-color: $background-color;
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

    .nav-link-button {
      text-align: center;

      h3 {
        padding-top: 15px;
        padding-bottom: 15px;
      }

      a {
        color: $highlight-color;
        h3 { background-color: $bold-translucent; }
      }
    }
  }

  def content
    fluid_container {
      jumbotron {
        h1 "Fortitude"
        h2 "Beautifully-factored HTML views for your Ruby or Rails application.", :class => :subhead
      }

      row {
        big_nav_link "Why use Fortitude?", "/why"
        big_nav_link "Getting Started", "/getting-started"
        big_nav_link "Reference", "/reference"
      }
    }
  end

  def big_nav_link(text, to_where)
    columns(:medium => 4, :class => 'nav-link-button') {
      a(:href => to_where) {
        h3 text, :class => 'nav-link'
      }
    }
  end
end
