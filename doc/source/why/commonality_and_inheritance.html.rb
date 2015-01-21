require 'source/why/example_page'

module Views
  module Why
    class CommonalityAndInheritance < Views::Why::ExamplePage
      def example_intro
        p {
          text "In our last example, we saw how Fortitude allows you to share code among methods in the same "
          text "view and how it lets you pass blocks to allow very flexible reuse and customization of that code."
        }

        p {
          text "Here, we’ll explore how Fortitude allows you to use Ruby’s inheritance mechanism to easily factor "
          text "out commonality among several related views. Using inheritance is one of the most powerful "
          text "features of Fortitude."
        }
      end

      def example_description
        p {
          text "Imagine we’re building the initial phases of a social network, and the time has come to create our "
          text "main social feed. This feed is going to list various events: friends who have accepted our friend "
          text "request, new posts in groups we follow, and even new features we’ve introduced to the site."
        }

        p {
          text "This presents an interesting challenge for building views. The views for these feed items are likely "
          text "to have quite a bit in common — yet almost all of it is going to be customized at "; em "some"
          text " point. Still, let’s start simply, with just the three feed items mentioned above."
        }

        p {
          text "First, the “accepted friend request” view:"
        }

        erb 'app/views/feed/items/accepted_friend_request.html.erb', <<-EOS
<div class="feed_item feed_item_accepted_friend_request" id="feed_item_<%= item.id %>">
  <div class="feed_item_header">
    <%= image_tag 'new_friend.png', :class => 'feed_item_image' %>
    <h5><strong><%= item.accepting_user.first_name %></strong> accepted your friend request!</h5>
  </div>

  <div class="feed_item_body">
    <p>
      <a href="<%= profile_url(item.accepting_user) %>">
        <img src="<%= item.accepting_user.profile_image %>">
        <strong><%= item.accepting_user.full_name %></strong> is now your friend!
      </a>
    </p>
    <p>You should say hello! It’s only <%= ((Time.now - item.accepting_user.date_of_birth) / 1.day) %> days until their birthday!</p>
  </div>

  <div class="feed_item_footer">Posted at <%= item.created_at %></div>
</div>
EOS

        p {
          text "Now, the “new posts in groups you follow” view:"
        }

        erb 'app/views/feed/items/new_group_posts.html.erb', <<-EOS
<div class="feed_item feed_item_new_posts" id="feed_item_<%= item.id %>">
  <div class="feed_item_header">
    <%= image_tag 'new_post.png', :class => 'feed_item_image' %>
    <h5>New posts in <%= item.new_groups.length %> groups!</h5>
  </div>

  <div class="feed_item_body">
    <p>There have been new posts in the following groups:
      <ul>
        <% item.new_groups.each do |group| %>
        <li><a href="<%= group_url(group) %>"><strong><%= group.title %></strong> (<%= group.new_posts %> new posts)</a></li>
        <% end %>
      </ul>
    </p>
  </div>

  <div class="feed_item_footer">Posted at <%= item.created_at %></div>
</div>
EOS

        p {
          text "And, finally, the “new feature” view:"
        }

        erb 'app/views/feed/items/new_feature.html.erb', <<-EOS
<div class="feed_item feed_item_new_feature" item="feed_item_<%= item.id %>">
  <div class="feed_item_header">
    <%= image_tag 'features/custom_groups.png', :class => 'feed_item_image' %>
    <h3>New features have launched!</h3>
  </div>

  <div class="feed_item_body">
    <h5>We’ve been improving the site for your benefit!</h5>
    <p>You can now create custom groups! We know you’ve all been asking for this feature for a while,
       and it’s now ready for your use! <a href="<%= custom_groups_url %>">Click here</a> to create one!</p>
  </div>

  <div class="feed_item_footer">Posted at <%= item.created_at %></div>
</div>
EOS

        p {
          text "(Please note that we’ve simplified a lot of these views for our example. For example, you’d never "
          text "want to show a user a raw Ruby "; code "Time"; text " value as we’ve done here.)"
        }

        p {
          text "We can easily notice a lot of commonality in the views above:"
        }

        ul {
          li {
            strong "Container"; text ": All the views have a similar surrounding "; code "div"; text " that contains "
            text "a per-view "; code "class"; text " and a per-feed-item "; code "id"; text "."
          }
          li {
            strong "Header"; text ": Each view has a header that’s surrounded by a "; code "div"; text " that contains "
            text "an image and some per-view HTML."
          }
          li {
            strong "Body"; text ": Each view has a body that’s surrounded by a "; code "div"; text " that contains "
            text "arbitrary HTML for that view — the real contents of our feed item."
          }
          li {
            strong "Footer"; text ": Each view also has a footer that’s identical for all views."
          }
        }
      end

      def using_standard_engines
        p {
          text "Using traditional templating engines, what can we do here? Well, have the same tools at our disposal "
          text "as always: partials and helpers. We can factor out commonality using these tools, "
          text "potentially using "; code "capture"; text " to allow us to write HTML we pass into a view using "
          text "ERb instead of Ruby string interpolation."
        }

        p {
          text "Let’s first see what this looks like without using "; code "capture"; text ", and then we’ll see how "
          text "or if using "; code "capture"; text " improves things."
        }

        h5 "Using Partials and Helpers"

        p {
          text "If we do our very best with this, here’s what we can end up with. We begin with a partial that "
          text "starts the header of our view:"
        }

        erb 'app/views/feed/items/_feed_item_header.html.erb', <<-EOS
<div class="feed_item feed_item_<%= outer_css_class %>" id="feed_item_<%= item.id %>">
  <div class="feed_item_header">
    <%= image_tag header_icon_image, :class => 'feed_item_image' %>
EOS

        p {
          text "We have a really awkward situation going on between the header and the body, where we need to "
          text "close the "; code "div"; text " we opened, then open another one. This seems a bit heavyweight for "
          text "a partial, so let’s use a helper:"
        }

        ruby 'app/helpers/feed_helper.rb', <<-EOS
  def feed_item_header_closer
    "</div><div class=\"feed_item_body\">"
  end
EOS

        p {
          text "Next, we have the body of the feed item, which we’ll leave to the individual view itself. Finally, "
          text "we have the rest of the item template:"
        }

        erb 'app/views/feed/items/_feed_item_footer.html.erb', <<-EOS
  </div>

  <div class="feed_item_footer">Posted at <%= item.created_at %></div>
</div>
EOS

        p {
          text "Given these partials and helpers, what do our views now look like? First, let’s look at the "
          text "“accepted friend request” view:"
        }

        erb 'app/views/feed/items/accepted_friend_request.html.erb', <<-EOS
<%= render :partial => 'feed_item_header',
      :locals => { :outer_css_class => 'accepted_friend_request',
                   :item => item, :header_icon_image => 'new_friend.png' } %>
      <h5><strong><%= item.accepting_user.first_name %></strong> accepted your friend request!</h5>
<%= feed_item_header_closer %>
    <p>
      <a href="<%= profile_url(item.accepting_user) %>">
        <img src="<%= item.accepting_user.profile_image %>">
        <strong><%= item.accepting_user.full_name %></strong> is now your friend!
      </a>
    </p>
    <p>You should say hello! It’s only <%= ((Time.now - item.accepting_user.date_of_birth) / 1.day) %> days until their birthday!</p>
<%= render :partial => 'feed_item_footer', :locals => { :item => item } %>
EOS

        p {
          text "This is our “new posts in groups you follow” view:"
        }

        erb 'app/views/feed/items/new_group_posts.html.erb', <<-EOS
<%= render :partial => 'feed_item_header',
      :locals => { :outer_css_class => 'new_posts',
                   :item => item, :header_icon_image => 'new_post.png' } %>
      <h5>New posts in <%= item.new_groups.length %> groups!</h5>
<%= feed_item_header_closer %>
    <p>There have been new posts in the following groups:
      <ul>
        <% item.new_groups.each do |group| %>
        <li><a href="<%= group_url(group) %>"><strong><%= group.title %></strong> (<%= group.new_posts %> new posts)</a></li>
        <% end %>
      </ul>
    </p>
<%= render :partial => 'feed_item_footer', :locals => { :item => item } %>
EOS

        p {
          text "And this is our “new feature” view:"
        }

        erb 'app/views/feed/items/new_feature.html.erb', <<-EOS
<%= render :partial => 'feed_item_header',
      :locals => { :outer_css_class => 'new_feature',
                   :item => item, :header_icon_image => 'custom_groups.png' } %>
      <h3>New features have launched!</h3>
<%= feed_item_header_closer %>
    <h5>We’ve been improving the site for your benefit!</h5>
    <p>You can now create custom groups! We know you’ve all been asking for this feature for a while,
       and it’s now ready for your use! <a href="<%= custom_groups_url %>">Click here</a> to create one!</p>
<%= render :partial => 'feed_item_footer', :locals => { :item => item } %>
EOS

        p {
          text "Is this an improvement? Yes — well, "; em "maybe"; text ". We’ve successfully removed some of the commonality, "
          text "although at the price of introducing a lot of verbosity. We’ve also added some serious weirdness, "
          text "like "; code "div"; text "s that get opened in one partial and closed in another — all of which is, "
          text "of course, added opportunity for error. All in all, it certainly isn’t clean or clear; once again, "
          text "extracting the commonality has come at a serious cost in comprehensibility and readability."
        }

        p {
          text "Let’s see if using "; code "capture"; text " makes this much better."
        }

        h5 {
          text "Using "; code "capture"
        }

        p {
          text "The "; code "capture"; text " method isn’t particularly common or elegant, but it can be useful in "
          text "situations like this to pass HTML into other views. If we use this, let’s see what our shared partial "
          text "looks like first:"
        }

        erb 'app/views/feed/items/_feed_item_base.html.erb', <<-EOS
<div class="feed_item feed_item_<%= outer_css_class %>" id="feed_item_<%= item.id %>">
  <div class="feed_item_header">
    <%= image_tag header_icon_image, :class => 'feed_item_image' %>
    <%= header_html %>
  </div>

  <div class="feed_item_body">
    <%= body_html %>
  </div>

  <div class="feed_item_footer">Posted at <%= item.created_at %></div>
</div>
EOS

        p {
          text "This certainly looks a lot better than our previous solution of two partials and a helper. It’s simpler, "
          text "and keeps the overall structure of the partial much clearer."
        }

        p {
          text "Given this, what do our actual feed items look like now?"
        }

        erb 'app/views/feed/items/accepted_friend_request.html.erb', <<-EOS
<% header_html = capture do %>
  <h5><strong><%= item.accepting_user.first_name %></strong> accepted your friend request!</h5>
<% end %>
<% body_html = capture do %>
    <p>
      <a href="<%= profile_url(item.accepting_user) %>">
        <img src="<%= item.accepting_user.profile_image %>">
        <strong><%= item.accepting_user.full_name %></strong> is now your friend!
      </a>
    </p>
<p>You should say hello! It’s only <%= ((Time.now - item.accepting_user.date_of_birth) / 1.day) %> days until their birthday!</p>
<% end %>
<%= render :partial => 'feed_item_base', :locals => {
      :outer_css_class => 'accepted_friend_request',
      :item => item,
      :header_icon_image => 'new_friend.png',
      :header_html => header_html,
      :body_html => body_html
} %>
EOS

        erb 'app/views/feed/items/new_group_posts.html.erb', <<-EOS
<% header_html = capture do %>
  <h5>New posts in <%= item.new_groups.length %> groups!</h5>
<% end %>
<% body_html = capture do %>
  <p>There have been new posts in the following groups:
    <ul>
      <% item.new_groups.each do |group| %>
      <li><a href="<%= group_url(group) %>"><strong><%= group.title %></strong> (<%= group.new_posts %> new posts)</a></li>
      <% end %>
    </ul>
  </p>
<% end %>
<%= render :partial => 'feed_item_base', :locals => {
      :outer_css_class => 'new_posts',
      :item => item,
      :header_icon_image => 'new_post.png',
      :header_html => header_html,
      :body_html => body_html
} %>
EOS

        erb 'app/views/feed/items/new_feature.html.erb', <<-EOS
<% header_html = capture do %>
  <h3>New features have launched!</h3>
<% end %>
<% body_html = capture do %>
  <h5>We’ve been improving the site for your benefit!</h5>
    <p>You can now create custom groups! We know you’ve all been asking for this feature for a while,
       and it’s now ready for your use! <a href="<%= custom_groups_url %>">Click here</a> to create one!</p>
<% end %>
<%= render :partial => 'feed_item_base', :locals => {
      :outer_css_class => 'new_feature',
      :item => item,
      :header_icon_image => 'custom_groups.png',
      :header_html => header_html,
      :body_html => body_html
} %>
EOS

        p {
          text "Alas, although we have a much nicer shared partial this time around, the views have become "
          text "really verbose and quite messy. The use of "; code "capture"; text " clutters up the code and causes a lot of "
          text "action-at-a-distance, and the shared partial takes enough inputs at this point that just calling it "
          text "requires passing many variables that create further visual clutter."
        }
      end

      def standard_engine_issues
        p {
          text "Hopefully it’s not an overstatement to say, simply: "; em "ugh"; text ". We have a lot of commonality "
          text "in the views we started with that it seems like we "; em "ought"; text " to be able to factor out well, "
          text "and yet both major options we have available don’t do a great job. The result feels messy and inelegant."
        }

        p {
          text "Let’s dive in deeper and look at some of the specific issues with the results:"
        }

        ul {
          li {
            strong "Disappearing Structure"; text ": In both refactorings, the overall structure of our views has "
            text "effectively vanished — when using partials and helpers, from the shared code; when using "
            code "capture"; text ", from the callers. This makes the code a lot harder to read, and, more importantly, "
            text "much harder to reason about: it’s all too easy to omit a closing tag, add an extra opening tag, or "
            text "just have a really hard time figuring out how and where to change something. If you wanted to create "
            text "a structure prone to generating lots of bugs, this is almost exactly what you’d do. "
          }
          li {
            strong "Verbosity"; text ": Our refactored code is almost as long as the code it replaces in both cases, "
            text "and a "; em "lot"; text " harder to read. Is this really an improvement?"
          }
          li {
            strong "Lack of Flexibility"; text ": Now consider in both cases what it would take to, for example, be "
            text "able to customize the footer — which is common to all views now, but which you can certainly imagine "
            text "being customized at some point in the near future. With partials and helpers, you suddenly have to "
            text "split the shared code into "; em "another"; text " partial; with "; code "capture"; text ", it’s "
            text "easier, but also involves a gross defaulting of HTML in the shared view and adds more verbosity "
            text "any place it’s customized."
          }
        }
      end

      def using_fortitude
        p {
          text "OK. So, how can Fortitude help? Because each Fortitude view or partial is simply a Ruby class, we can "
          text "define a base view class here outlining the general structure, and with simple method calls for "
          text "overridden or missing content:"
        }

        fortitude 'app/views/feed/items/feed_item.html.rb', <<-EOS
class Views::Feed::Items::FeedItem < Views::Base
  needs :item

  def content
    div(:class => [ "feed_item", "feed_item_\#{outer_css_class}" ], :id => "feed_item_\#{item.id}") {
      div(:class => 'feed_item_header') {
        image_tag header_icon_image, :class => 'feed_item_image'
        header_content
      }

      div(:class => 'feed_item_body') { body_content }

      div("Posted at \#{item.created_at}", :class => 'feed_item_footer')
    }
  end

  def header_content
    raise "You must implement this method in \#{self.class.name}"
  end

  def body_content
    raise "You must implement this method in \#{self.class.name}"
  end

  def outer_css_class
    self.class.name.demodulize.underscore
  end
end
EOS

        p {
          text "Our base class clearly defines the overall structure of all feed item views, and that it "
          code "need"; text "s an "; code "item"; text " in order to be rendered. The "; code "header_content"
          text " and "; code "body_content"; text " methods are left unimplemented, to be provided by subclasses."
        }

        p {
          text "We’ve also used a neat trick: because this is Ruby code, we’ve used a little bit of metaprogramming "
          text "convention-over-configuration to calculate the "; code "outer_css_class"; text ", instead of having "
          text "to pass it in. This both makes callers cleaner and eliminates a source of inconsistency or error, "
          text "because "; code "outer_css_class"; text " can no longer differ from the name of the view itself "
          text "at all. And yet, exactly because it’s a separate method, if a subclass needed to override this class, "
          text "it could, extremely easily."
        }

        p {
          text "Given this, what do these subclasses look like? We’ll start with the “accepted friend request” view, "
          text "which turns out to be the most complex one:"
        }

        fortitude 'app/views/feed/items/accepted_friend_request.html.rb', <<-EOS
class Views::Feed::Items::AcceptedFriendRequest < FeedItem
  def header_content
    h5 {
      strong item.accepting_user.first_name; text " accepted your friend request!"
    }
  end

  def body_content
    p {
      a(:href => profile_url(item.accepting_user)) {
        img(:src => item.accepting_user.profile_image)
        strong item.accepting_user.full_name; text " is now your friend!"
      }
    }
    p "You should say hello! It’s only \#{days_until_birthday} days until their birthday!"
  end

  private
  def days_until_birthday
    (Time.now - item.accepting_user.date_of_birth) / 1.day
  end
end
EOS

        p {
          text "From the view above, it’s hopefully immediately obvious what content "; code "AcceptedFriendRequest"
          text " supplies (its two public methods), and where it goes (since they have clear names). Further, we’ve "
          text "used Fortitude’s ability to add “helper methods” to just a single class to easily factor out the "
          code "days_until_birthday"; text " method."
        }

        p {
          text "Now, let’s look at the “new group posts” view:"
        }

        fortitude 'app/views/feed/items/new_group_posts.html.rb', <<-EOS
class Views::Feed::Items::NewGroupPosts < FeedItem
  def header_content
    h5 "New posts in \#{item.new_groups.length} groups!"
  end

  def body_content
    p {
      text "There have been new posts in the following groups:"
      ul {
        item.new_groups.each do |group|
          li {
            a(:href => group_url(group)) {
              strong group.title; text " (\#{group.new_posts} new posts)"
            }
          }
        end
      }
    }
  end
end
EOS

        p {
          text "And the “new feature” view:"
        }

        fortitude 'app/views/feed/items/new_feature.html.rb', <<-EOS
class Views::Feed::Items::NewFeature < FeedItem
  def header_content
    h3 "New features have launched!"
  end

  def body_content
    h5 "We’ve been improving the site for your benefit!"
    p {
      text "You can now create custom groups! We know you’ve all been asking for this feature for a while, "
      text "and it’s now ready for your use! "; a("Click here", :href => custom_groups_url); text " to create one!"
    }
  end
end
EOS

        p {
          text "At this point, these views almost seem positively boring — they each contain exactly what you’d "
          text "expect them to contain, with no surprises at all. Given that truly well-factored code often seems "
          text "boring because it’s so straightforward, we’ll take that as a good thing."
        }
      end

      def fortitude_benefits
        p {
          text "What have we done here? Put simply, we’ve leveraged Ruby’s built-in inheritance mechanism — "
          text "a mechanism every single Ruby programmer on your team already knows extremely well — to build views "
          text "that are far more comprehensible and maintainable than anything we could possibly have achieved "
          text "with traditional templating engines."
        }

        p {
          text "In many ways, the key behind Fortitude is exactly that it "; em "doesn’t"; text " invent some "
          text "brand-new paradigm for writing your view code. Instead, it allows you to leverage "
          text "all the techniques you already have for factoring the rest of your application, and simply lets you "
          text "apply them to your views."
        }

        p {
          text "Imagine, for example, that you finally "; em "do"; text " need to customize that shared footer "
          text "in at least one feed-item view. What do you do? Simple: extract it into a method in the base class, "
          text "and override it in whichever view you need to customize it in. You can even easily "
          text "call "; code "super"; text " (or not), either before, after, or in the middle of the overridden "
          text "method, and it behaves exactly how you’d expect, inserting the default footer contents at exactly "
          text "that point in your view."
        }

        p {
          text "Next, we’ll see how using Fortitude classes can allow us to create a contextual, elegant "
          text "“mini-language” for building complex views very easily."
        }
      end
    end
  end
end
