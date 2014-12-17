class Views::Layout < Views::Shared::Base
  def content
    doctype!

    html {
      head {
        meta :charset => 'utf-8'
        meta :content => "IE=edge,chrome=1", :'http-equiv' => "X-UA-Compatible"

        render_title

        stylesheet_link_tag 'all'
        javascript_include_tag 'all'
      }

      body(:class => page_classes) {
        rawtext(yield)
      }
    }
  end

  def render_title
    title(current_page.data.title || "The Middleman")
  end
end
