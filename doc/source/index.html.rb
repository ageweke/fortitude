class Views::Index < ::Views::Shared::Base
  css %{
    background-color: $background-color;
    padding-bottom: 120px;

    .jumbotron {
      color: $bold-color;
      text-align: center;
      padding-top: 120px;
      padding-bottom: 20px;
      background-color: $background-color;
    }

    h2 {
      font-family: $body-font;
      font-weight: 400;
      color: $highlight-color;
      margin-left: auto;
      margin-right: auto;
      margin-top: 60px;
    }

    h3 {
      font-family: $body-font;
    }

    blockquote {
      .attribution {
        margin-top: 10px;
        text-align: right;
      }

      border: none;
      color: $highlight-color;
      font-style: italic;
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
        praise_quote "Quin H.", %{At first, I was skeptical. But after writing views in Fortitude for a couple of weeks,
I realized I could never go back to anything else. It really is that good.}
        praise_quote "Oleksiy K.", %{I’ve been doing Rails (95% backend) for 8 years now...and today, after hearing about Fortitude
and Parcels, was the first time ever that I wanted to actually try to do some user-facing feature development.}
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

  def praise_quote(attribution, quote)
    columns(:medium => 6) {
      blockquote {
        span(:class => 'quote') {
          text quote
        }
        div("— #{attribution}", :class => 'attribution')
      }
    }
  end
end
