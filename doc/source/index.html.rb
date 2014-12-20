class Views::Index < ::Views::Shared::Base
  css %{
    @at-root \#{&} { padding-left: 0; padding-right: 0; }

    .highlighted {
      background-color: $background-color;
      padding-bottom: 60px;
    }

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
      color: $highlight-color;
    }

    .what-is {
      text-align: left;
      margin-top: 30px;
      h3 {
        padding-left: 10px;
      }
      p {
        color: $highlight-color;
        font-size: 130%;
        padding-left: 10%;
        padding-right: 10%;
      }
    }

    .praise-quotes {
      padding-left: 30px;
      padding-right: 30px;
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

    .nav-links {
      margin-top: 30px;
      padding-left: 15px;
      padding-right: 15px;
    }

    .nav-link-button {
      h3 {
        padding-top: 15px;
        padding-bottom: 15px;
      }

      a {
        h3 {
          font-weight: 400;
          background-color: $bold-translucent;
          text-align: center;
        }
      }
    }

    .offsite-links {
      padding-left: 30px;
      padding-right: 30px;
      padding-top: 15px;
      padding-bottom: 50px;

      font-family: $heading-font;
      font-weight: 300;
      a { color: black; }
      color: black;
    }
  }

  def content
    fluid_container {
      div(:class => :highlighted) {
        jumbotron {
          h1 "Fortitude"
          h2 "Beautifully-factored HTML views for your Ruby or Rails application.", :class => :subhead
        }

        row(:class => 'praise-quotes') {
          praise_quote "Quin H.", %{At first, I was skeptical. But after writing views in Fortitude for a couple of weeks,
  I realized I could never go back to anything else. It really is that good.}
          praise_quote "Oleksiy K.", %{I’ve been doing Rails (95% backend) for 8 years now...and today, after hearing about Fortitude
  and Parcels, was the first time ever that I wanted to actually try to do some user-facing feature development.}
        }

        row(:class => 'what-is') {
          columns(:medium => 12) {
            # h3 "What is Fortitude?", :class => 'what-is'
            p %{Fortitude is a templating engine for Ruby, with or without Rails, that gives you all the power of
  Ruby to factor your views. Using Fortitude, you'll build dramatically better-factored, readable,
  maintainable views.}
          }
        }

        row(:class => 'nav-links') {
          big_nav_link "Why use Fortitude?", "/why"
          big_nav_link "Getting Started", "/getting-started"
          big_nav_link "Reference", "/reference"
        }
      }

      row(:class => 'offsite-links') {
        columns(:medium => 3) {
          a("Fortitude on GitHub", :href => 'https://github.com/ageweke/fortitude')
        }
        columns(:medium => 3) {
          a("Fortitude on Travis CI", :href => 'https://travis-ci.org/ageweke/fortitude')
        }
        columns(:medium => 3) {
          a("Fortitude on Google Groups", :href => 'https://groups.google.com/forum/#!forum/fortitude-ruby')
        }
      }
    }
  end

  def big_nav_link(text, to_where)
    columns(:small => 4, :class => 'nav-link-button') {
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
