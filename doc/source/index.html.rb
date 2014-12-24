class Views::Index < ::Views::Shared::Base
  def content
    fluid_container {
      div(:class => :highlighted) {
        jumbotron {
          h1 "Fortitude"
          h2 "Beautifully-factored HTML views for your Ruby or Rails application.", :class => :subhead
        }

        row(:class => 'praise-quotes') {
          praise_quote "Quin H.", %{At first, I was skeptical. But after writing views in Fortitude for a couple of weeks,
  I realized I could never go back to anything else. It makes that big a difference.}
          praise_quote "Oleksiy K.", %{I’ve been doing Rails (95% backend) for 8 years now...and today, after hearing about Fortitude
  and Parcels, was the first time ever that I wanted to actually try to do some user-facing feature development.}
        }

        row(:class => 'what-is') {
          columns(:medium => 12) {
            p %{Fortitude is a templating engine for Ruby, with or without Rails, that gives you all the power of
  Ruby to factor your views. Using Fortitude, you'll build dramatically better-factored, more readable,
  more maintainable views.}
          }
        }

        row(:class => 'nav-links') {
          big_nav_link "Why use Fortitude?", "/why"
          big_nav_link "Getting Started", "/getting-started"
          big_nav_link "Reference", "/reference"
        }
      }

      row(:class => 'offsite-links') {
        columns(:medium => 4) {
          a("Fortitude on GitHub", :href => 'https://github.com/ageweke/fortitude')
        }
        columns(:medium => 4) {
          a("Fortitude on Travis CI", :href => 'https://travis-ci.org/ageweke/fortitude')
        }
        columns(:medium => 4) {
          a("Fortitude on Google Groups", :href => 'https://groups.google.com/forum/#!forum/fortitude-ruby')
        }
      }
    }
  end

  def big_nav_link(text, to_where)
    columns(:small => 4) {
      div(:class => 'nav-link-button') {
        a(:href => to_where) {
          h3 text, :class => 'nav-link'
        }
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
