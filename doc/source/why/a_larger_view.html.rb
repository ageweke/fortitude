require 'source/why/example_page'

module Views
  module Why
    class ALargerView < Views::Why::ExamplePage
      def example_intro
        p {
          text "Fortitude’s benefits become even more evident as your application scales. Next, we’ll take a look at "
          text "a much larger view and the ways Fortitude can improve code at scale."
        }
      end

      def example_description
        p {
          text "This view has been adapted from another real-world application. It’s a view from an administrative page "
          text "that shows a list of blocked users, reported users, and "; em "reporting"; text " users ("
          em "i.e."; text ", those who have reported other users)."
        }

        erb "/app/views/admin/users/user_reporting.html.erb", <<-EOS
<h1>Blocked users in the last <%= @time_span_days %> days:</h1>

<table class="blocked_users user_list">
  <thead>
    <tr>
      <th>User ID</th>
      <th>Username</th>
      <th>Email</th>
      <th>Last Login</th>
      <th>Blocked Because</th>
      <th>Blocked By</th>
    </tr>
  </thead>
  <tbody>
    <% @blocked_users.each do |blocked_user|
       blocked_details = @blocked_user_reasons[blocked_user.id] %>
      <tr>
        <td><%= blocked_user.id %></td>
        <td><%= blocked_user.username %></td>
        <td><%= blocked_user.email || "<span class=\"no_email\">(none available)</span>".html_safe %></td>
        <td><%= time_ago_in_words(blocked_user.last_login_at) %></td>
        <td><%= blocked_details[:reason] %></td>
        <td><%= blocked_details[:admin_user] %></td>
      </tr>
  </tbody>
</table>

<h1>Reported Users in the last <%= @time_span_days %> days:</h1>
<table class="reported_users user_list">
  <thead>
    <tr>
      <th>User ID</th>
      <th>Username</th>
      <th>Email</th>
      <th>Last Login</th>
      <th>Reported For</th>
      <th>Report Text</th>
      <th>Reported By</th>
    </tr>
  </thead>
  <tbody>
    <% @reported_users.each do |reported_user|
       report_details = @reported_user_reasons[reported_user.id] %>
      <tr>
        <td><%= reported_user.id %></td>
        <td><%= reported_user.username %></td>
        <td><%= reported_user.email || "<span class=\"no_email\">(none available)</span>".html_safe %></td>
        <td><%= time_ago_in_words(reported_user.last_login_at) %></td>
        <td><%= report_details[:abuse_flag] %></td>
        <td><%= report_details[:abuse_text] %></td>
        <td><%= report_details[:abuse_reporter] %></td>
      </tr>
  </tbody>
</table>

<h1>Most Reporting Users in the last <%= @time_span_days %> days:</h1>
<table class="reporting_users user_list">
  <thead>
    <tr>
      <th>User ID</th>
      <th>Username</th>
      <th>Email</th>
      <th>Last Login</th>
      <th>Total Reported Users</th>
      <th>Reported-For Breakdown</th>
    </tr>
  </thead>
  <tbody>
    <% @top_reporting_users.each do |reporting_user|
       reporting_details = @top_reporting_user_details[reporting_user.id] %>
      <tr>
        <td><%= reporting_user.id %></td>
        <td><%= reporting_user.username %></td>
        <td><%= reporting_user.email || "<span class=\"no_email\">(none available)</span>".html_safe %></td>
        <td><%= time_ago_in_words(reporting_user.last_login_at) %></td>
        <td><%= reporting_details[:flags].uniq { |f| f.reported_user_id }.length %></td>
        <td>
          <% grouped_by_flag = reporting_details[:flags].group_by { |f| f.flag_type }
             grouped_by_flag.each do |flag_type, flags| %>
            Flag <strong><%= flag_type %></strong>: <%= flags.length %> total flag(s)<br>
          <% end %>
        </td>
      </tr>
  </tbody>
</table>
EOS

        p {
          text "Obviously, the most notable thing about this view is that it’s "; em "big"; text ". That’s OK — "
          text "there’s no inherent reason that long views are bad. The tables in this view aren’t used anywhere "
          text "else, so there’s no need to share the code with anything else."
        }

        p {
          text "However, the length of this view makes it pretty hard to read; if you open it on anything but a huge "
          text "monitor, it’s not even obvious that there "; em "is"; text " a list of reporting users, for example. "
        }

        p {
          text "Further, there’s a lot of duplication among these three tables, which would be nice to clean up, too."
        }
      end

      def using_standard_engines
        p {
          text "Using standard templating engines, our options in this case are pretty limited."
        }

        h5 "Splitting Apart the View"

        p {
          text "One thing we could do would be to break out the three tables into their own partials. This does work, "
          text "and looks pretty concise:"
        }

        erb "/app/views/admin/users/user_reporting.html.erb", <<-EOS
<%= render :partial => 'blocked_users' %>
<%= render :partial => 'reported_users' %>
<%= render :partial => 'reporting_users' %>
EOS

        p {
          text "However, we’ve now created a subtle but insidious problem: these three new partials now require quite "
          text "a few variables to be set in order to render them — specifically, "; code "@time_span_days"; text ", "
          code "@blocked_users"; text ", and "; code "@blocked_user_reasons"; text " for one of them, "
          code "@time_span_days"; text ", "; code "@reported_users"; text ", and "; code "@reported_user_reasons"
          text " for the next, and so on. This is fine, except that "; em "nowhere in the code can you tell this"
          text "— if you look at the original view, it now doesn’t mention those whatsoever, and you can only tell "
          text "that the partials require those variables by carefully scouring their text to see what they use."
        }

        p {
          text "Even worse, "; em "nowhere in the originating view are any of these variables mentioned"; text "! "
          text "If you were to look at the view, it’s literally impossible to tell which variables the controller "
          text "needs to set in order to make it work. You need to go look at the partials it renders. Now, imagine "
          text "we perform some further refactorings — you might need to look through several layers of partials, "
          text "carefully writing down which "; code "@"; text " variables are used and deduplicating them, just to "
          text "wrap your head around the data being communicated from the controller to the view."
        }

        p {
          text "Although many views are written this way, this is not any better in view code than it is in any other "
          text "code. We’re passing data using what are effectively implicit global variables, and that’s seriously "
          text "detrimental to maintainability and readability in any application."
        }

        p {
          text "Further: if we do this, we haven’t done anything to factor out the commonality of these tables…and, "
          text "because they’re now in three separate files, the likelihood that they’ll diverge in a bad way goes up. "
          text "(For example, it’d be much easier for a developer to add a new common column to one of them, while "
          text "forgetting to add it to the others — and now we have not just duplication, but duplication "; em "and"
          text " inconsistency, which is pretty close to the canonical definition of poorly-factored code.)"
        }

        h5 "Unifying the Tables"

        p {
          text "Trying to unify the code for the three tables is a lot trickier. While the tables actually have a "
          text "great deal of commonality, "
          text "they also have varying numbers of columns, and that makes it considerably harder. We have a few "
          text "choices here:"
        }

        ol {
          li {
            text "We could create one partial for the entire table, and then pass in two arrays: one of the extra "
            text "column names, and the second an array of arrays of HTML fragments, one outer array for each row, "
            text "one element in the inner array for each column. Trying to even write that calling code seems like "
            text "an exercise in sheer mess, and prospects for maintainability are slim at best."
          }
          li {
            text "We could create a partial for the table header, and one for the body, and pass in the above data, "
            text "structured just as mentioned above; this cleans it up a little more, but doesn’t really make any "
            text "real fundamental difference, since the big mess will be in the caller, not the partials."
          }
          li {
            text "We could create a partial for the table header, one for the first chunk of the table body, "
            text "and then one that renders a single row of the body, "
            text "passing in HTML for the cells, and loop over the body partial."
          }
        }

        p {
          text "This last option certainly seems like the best. Let’s see what it looks like in practice. First, the "
          text "header partial:"
        }

        erb "/app/views/admin/users/_user_reporting_table_header.html.erb", <<-EOS
<h1><%= title %></h1>

<table class="<%= table_classes %> user_list">
  <thead>
    <tr>
      <th>User ID</th>
      <th>Username</th>
      <th>Email</th>
      <th>Last Login</th>
      <% table_header_columns.each do |table_header_column| %>
      <th><%= table_header_column %></th>
      <% end %>
    </tr>
  </thead>
  <tbody>
EOS

        p "And the body-row partial:"

        erb "/app/views/admin/users/_user_reporting_table_row_begin.html.erb", <<-EOS
<tr>
  <td><%= user.id %></td>
  <td><%= user.username %></td>
  <td><%= user.email || "<span class=\"no_email\">(none available)</span>".html_safe %></td>
  <td><%= time_ago_in_words(user.last_login_at) %></td>
  <%= extra_columns %>
</tr>
EOS

        p "Finally, here’s the caller:"

        erb "/app/views/admin/users/user_reporting.html.erb", <<-EOS
<%= render :partial => 'user_reporting_table_header', :locals => {
  :title => "Blocked users in the last \#{time_span_days} days:",
  :table_classes => "blocked_users",
  :table_header_columns => [ "Blocked Because", "Blocked By" ]
} %>
  <tbody>
<% @blocked_users.each do |blocked_user|
  blocked_details = @blocked_user_reasons[blocked_user.id] %>
  <%= render :partial => 'user_reporting_table_row_begin', :locals => {
    :user => blocked_user, :extra_columns => "<td>\#{h(blocked_details[:reason])}</td><td>\#{h(blocked_details[:admin_user])}</td>"
  } %>
<% end %>
  </tbody>
</table>

<%= render :partial => 'user_reporting_table_header', :locals => {
  :title => "Reported users in the last \#{time_span_days} days:",
  :table_classes => "reported_users",
  :table_header_columns => [ "Reported For", "Report Text", "Reported By" ]
} %>
  <tbody>
<% @reported_users.each do |reported_user|
    report_details = @reported_user_reasons[reported_user.id] %>
  <%= render :partial => 'user_reporting_table_row_begin', :locals => {
    :user => reported_user, :extra_columns =>
      "<td>\#{h(report_details[:abuse_flag])}</td><td>\#{h(report_details[:abuse_text])}</td><td>\#{h(report_details[:abuse_reporter])}</td>"
  } %>
<% end %>
  </tbody>
</table>

<%= render :partial => 'user_reporting_table_header', :locals => {
  :title => "Most Reporting Users in the last \#{time_span_days} days:",
  :table_classes => "reporting_users",
  :table_header_columns => [ "Total Reported Users", "Reported-For Breakdown" ]
} %>
  <tbody>
<% @top_reporting_users.each do |reporting_user|
    reporting_details = @top_reporting_user_details[reporting_user.id]
    total_flags = reporting_details[:flags].uniq { |f| f.reported_user_id }.length

    grouped_by_data = grouped_by_flag.map do |flag_type, flags|
      capture do %>
      Flag <strong><%= flag_type %></strong>: <%= flags.length %> total flag(s)<br>
    <% end
    end.join("\n") %>

  <%= render :partial => 'user_reporting_table_row_begin', :locals => {
    :user => reporting_user, :extra_columns =>
      "<td>\#{h(total_flags)}</td><td>\#{grouped_by_data}</td>"
  } %>
<% end %>
  </tbody>
</table>
EOS
      end

      def standard_engine_issues
        p {
          text "Ugh. We’ve managed to unify the tables, and yet only at significant expense. Let’s try to break down "
          text "the issues we see here:"
        }

        ul {
          li {
            strong "Caller Mess"; text ": By far the most apparent issue here: "
            em "now our caller is almost inscrutable"; text ". It doesn’t even look at first glance like it has "
            text "tables in it, the actual HTML involved is strewn in little tiny chunks that are difficult to find "
            text "(and often is now embedded as Ruby strings, not ERb HTML), we’ve had to resort to "; code "capture"
            text " to pass HTML in, and so on. Generally speaking, it sure isn’t very readable."
          }
          li {
            strong { em "Dangerous (XSS Potential)" }; text ": Once again, we’re back in the land of having to be "
            text "very, very careful about HTML escaping. We have to call "; code "#h"; text " manually around the "
            text "user data we put into the "; code "extra_columns"; text " partial parameter. And if we forget, "
            text "even once? We now have an XSS vulnerability."
          }
          li {
            strong { text "Falling back to "; code "#capture" }; text ": For our last table, building the string "
            text "we need to pass in as "; code "extra_columns"; text " requires enough logic that we either would have "
            text "to use Ruby string concatenation multiple times, or, better, use "; code "#capture"
            text " like we do here. While there’s nothing fundamentally wrong with "; code "#capture"
            text ", the way it suddenly builds HTML out-of-order almost always makes code harder to read and harder "
            text "to maintain and debug."
          }
          li {
            strong "File Clutter"; text ": Our single view is now represented using three files, all of which properly "
            text "live in the "; code "app/views/admin/users"; text " directory. Initially, this isn’t that big a deal; "
            text "however, in a large application, this really adds up. Add seven more views like this, and now you have "
            text "24 separate view files or partials in that directory, with no obvious way of knowing which partials "
            text "belong to which views (or even knowing for sure which partials might not even be used any more). "
            text "In other words, the fact that you have to create a new file just to be able to reuse some code, "
            text "even within a single view, is a heavyweight restriction that leads to more files than you otherwise "
            text "might want."
          }
          li {
            strong "Indentation (of Source)"; text ": This is one of those issues that can seem minor, but really adds up over "
            text "the course of a larger application. How do we indent lines in the above example? It’s not entirely "
            text "clear, and there really isn’t a great solution. Basically, the natural indentation of the HTML itself "
            text "is fighting with the indentation of our interlaced Ruby code. There are many different ways to handle "
            text "this, but none of them are great, and none of them are accepted as “the right way”; every developer "
            text "or team will have its own preferences, and your editor probably won’t be of much help."
          }
          li {
            p {
              strong "Indentation (of Output)"; text ": Related to this, the HTML output we get from this is now really, "
              text "really poorly indented. For example, if the last table has one row, it is now going to look like this "
              text "(with some sections elided for clarity):"
            }

            html_source <<-EOS
<html>
  <head>
    ...
  </head>
  <body>
  ...
<h1>Most Reporting Users in the last 30 days:</h1>

<table class="reporting_users user_list">
  <thead>
    <tr>
      <th>User ID</th>
      <th>Username</th>
      <th>Email</th>
      <th>Last Login</th>
      <th>Total Reported Users</th>
      <th>Reported-For Breakdown</th>
    </tr>
  </thead>
  <tbody>
<tr>
  <td>12345</td>
  <td>jane_doe_1</td>
  <td>jdoe@example.com</td>
  <td>about 2 hours ago</td>
  <td>17</td><td>Flag <strong>Spam</strong>: 27 total flag(s)<br>
Flag <strong>Personal Attack</strong>: 17 total flag(s)<br>
Flag <strong>Off-Topic</strong>: 9 total flag(s)<br>
</td>
</tr>
  </tbody>
</table>
...
  </body>
</html>
EOS
            p "Is this the end of the world? Of course not."
            p "Does it make our HTML considerably harder to read? Of course. "
            p "Should we have to put up with this as just a fact of life in 2015? Absolutely not."
          }
        }
      end

      def using_fortitude
        h5 "Before Refactoring, a Translation"

        p {
          text "Fortitude can help improve this situation "; em "a lot"; text ". However, before we refactor this, let’s "
          text "take a look at what a simple Fortitude translation of the original, un-refactored view looks like in "
          text "Fortitude:"
        }

        fortitude '/app/views/admin/users/user_reporting.html.rb', <<-EOS
class Views::Admin::Users::UserReporting < Views::Base
  needs :time_span_days
  needs :blocked_users, :blocked_user_reasons
  needs :reported_users, :reported_user_reasons
  needs :top_reporting_users, :top_reporting_user_details

  def content
    h1 "Blocked users in the last \#{time_span_days} days: "

    table(:class => "blocked_users user_list") {
      thead {
        tr {
          th "User ID"
          th "Username"
          th "Email"
          th "Last Login"
          th "Blocked Because"
          th "Blocked By"
        }
      }

      tbody {
        blocked_users.each do |blocked_user|
          blocked_details = blocked_user_reasons[blocked_user.id]
          tr {
            td blocked_user.id
            td blocked_user.username
            td {
              if blocked_user.email
                text blocked_user.email
              else
                span "(none available)", :class => :no_email
              end
            }
            td time_ago_in_words(blocked_user.last_login_at)
            td blocked_details[:reason]
            td blocked_details[:admin_user]
          }
        end
      }
    }

    h1 "Reported Users in the last \#{time_span_days} days:"

    table(:class => "reported_users user_list") {
      thead {
        tr {
          th "User ID"
          th "Username"
          th "Email"
          th "Last Login"
          th "Reported For"
          th "Report Text"
          th "Reported By"
        }
      }

      tbody {
        reported_users.each do |reported_user|
          report_details = reported_user_reasons[reported_user.id]
          tr {
            td reported_user.id
            td reported_user.username
            td {
              if reported_user.email
                text reported_user.email
              else
                span "(none available)", :class => :no_email
              end
            }
            td time_ago_in_words(reported_user.last_login_at)
            td report_details[:abuse_flag]
            td report_details[:abuse_text]
            td report_details[:abuse_reporter]
          }
        end
      }
    }

    h1 "Most Reporting Users in the last \#{time_span_days} days:"

    table(:class => "reporting_users user_list") {
      thead {
        tr {
          th "User ID"
          th "Username"
          th "Email"
          th "Last Login"
          th "Total Reported Users"
          th "Reported-For Breakdown"
        }
      }

      tbody {
        top_reporting_users.each do |reporting_user|
          reporting_details = top_reporting_user_details[reporting_user.id]
          tr {
            td reporting_user.id
            td reporting_user.username
            td {
              if reporting_user.email
                text reporting_user.email
              else
                span "(none available)", :class => :no_email
              end
            }
            td time_ago_in_words(reporting_user.last_login_at)
            td(reporting_details[:flags].uniq { |f| f.reported_user_id }.length)
            td {
              grouped_by_flag = reporting_details[:flags].group_by { |f| f.flag_type }
              grouped_by_flag.each do |flag_type, flags|
                text "Flag"; strong flag_type; text ": \#{flags.length} total flag(s)"; br
              end
            }
          }
        end
      }
    }
  end
end
EOS

        p {
          text "Although we really haven’t used the true advantages of Fortitude here, because we haven’t refactored "
          text "anything yet, we can already see a few nice things about this:"
        }

        ul {
          li {
            strong "Parameter Declarations"; text ": The "; code "needs"; text " declarations at the top of the "
            text "Fortitude class show you, at a glance, exactly what you have to pass into this view to render it. "
            text "Every single Fortitude view or partial has this, and it’s guaranteed to be correct: if you don’t "
            text "declare something as a "; code "need"; text ", you’ll be unable to render it in the view. (You can "
            text "also supply defaults to make these optional, but we’re getting ahead of ourselves.)"
          }
          li {
            strong "Logic vs. Rendering"; text ": Although a common convention in Rails code is to use braces "
            text "for single-line blocks and "; code "do...end"; text " for multiline blocks, the convention is "
            text "different in Fortitude code, and for good reason. In Fortitude code, we use braces to delimit actual "
            text "HTML element contents, and "; code "do...end"; text " to delimit Ruby logic. This lets the eye scan "
            text "the class easily and see exactly where there’s logic and where there’s HTML."
          }
          li {
            strong "Cleanliness"; text ": This is, of course, a matter of personal preference, and not all people "
            text "will feel the same way. However, to your author’s eye, the lack of all of the ERb "
            code "<%= ... %>"; text " symbols cluttering up any place there’s logic in the view makes it quite a bit "
            text "cleaner to read."
          }
        }

        p {
          text "However, again, the syntax isn’t really the point of Fortitude — the real point is the refactoring that "
          text "the syntax allows you to do. Let’s take a look at that next."
        }

        h5 "A Beautifully-Refactored View"

        p "Let’s just look at the fully-refactored view right off the bat and see what we’ve been able to do:"

        fortitude '/app/views/admin/users/user_reporting.html.rb', <<-EOS
class Views::Admin::Users::UserReporting < Views::Base
  needs :time_span_days
  needs :blocked_users, :blocked_user_reasons
  needs :reported_users, :reported_user_reasons
  needs :top_reporting_users, :top_reporting_user_details

  def content
    blocked_users_table
    reported_users_table
    reporting_users_table
  end

  def blocked_users_table
    users_table("Blocked Users", :blocked_users, [ "Blocked Because", "Blocked By" ], blocked_users) do |user|
      blocked_details = blocked_user_reasons[user.id]
      td blocked_details[:reason]
      td blocked_details[:admin_user]
    end
  end

  def reported_users_table
    users_table("Reported Users", :reported_users, [ "Reported For", "Report Text", "Reported By" ], reported_users) do |user|
      report_details = reported_user_reasons[user.id]
      td report_details[:abuse_flag]
      td report_details[:abuse_text]
      td report_details[:abuse_reporter]
    end
  end

  def reporting_users_table
    users_table("Most Reporting Users", :reporting_users, [ "Total Reported Users", "Reported-For Breakdown" ], top_reporting_users) do |user|
      reporting_details = top_reporting_user_details[user.id]

      td(reporting_details[:flags].uniq { |f| f.reported_user_id }.length)
      td {
        grouped_by_flag = reporting_details[:flags].group_by { |f| f.flag_type }
        grouped_by_flag.each do |flag_type, flags|
          text "Flag"; strong flag_type; text ": \#{flags.length} total flag(s)"; br
        end
      }
    end
  end

  def users_table(title_prefix, css_class, extra_columns, users)
    h1 "\#{title_prefix} in the last \#{time_span_days} days: "

    table(:class => "\#{css_class} user_list") {
      thead {
        tr {
          ([ "User ID", "Username", "Email", "Last Login" ] + extra_columns).each do |header|
            th header
          end
        }
      }

      tbody {
        users.each do |user|
          tr {
            td user.id
            td user.username
            td {
              if user.email
                text user.email
              else
                span "(none available)", :class => :no_email
              end
            }
            td time_ago_in_words(user.last_login_at)

            yield user
          }
        end
      }
    }
  end
end
EOS
      end

      def fortitude_benefits
        p {
          text "This is such an enormous improvement over either the original ERb view or the refactored ERb view "
          text "that it’s hard to know where to begin. Let’s try enumerating the advantages, over and above the "
          text "ones we mentioned above that are inherent to any Fortitude code:"
        }

        ul {
          li {
            strong "Readability of Overall Structure"; text ": The overall organization of this view is instantly "
            text "obvious with one glance at the "; code "#content"; text " method (the entry point of every "
            text "Fortitude view or partial): it contains a table of blocked users, a table of reported users, "
            text "and a table of reporting users."
          }
          li {
            strong "Readability of the Table"; text ": Our table is now in "; em "just one method"; text ". It’s "
            text "completely clear what the structure of that table is, exactly how it works, and exactly where "
            text "callers can pass in data or code that might change it."
          }
          li {
            strong "Variation in Each Table"; text ": Similarly, it’s easy to see exactly how each table "
            text "differs from the others: it’s exactly the code present in the method ("; em "e.g."; text ", "
            code "#blocked_users_table"; text ", "; code "#reported_users_table"; text ", and so on)."
          }
          li {
            strong "Lack of File Clutter"; text ": Our view is now "; em "one single file"; " again. The way we "
            text "refactor our code is completely independent of the number of files we create for it, allowing us "
            text "to keep like code together. If we have eight views in this controller, we’ll have just eight "
            text "files in "; code "app/views/admin/users"; text ", and it’s crystal-clear exactly what each one is "
            text "for. (Of course, you are more than welcome to factor out Fortitude code into separate files if you "
            text "want — it just isn’t "; em "required"; text " in the same way it is with ERb, HAML, or other "
            text "traditional templating engines.)"
          }
          li {
            strong "Consistent"; text ": At no point do we build HTML by interpolating Ruby strings; it’s all just "
            text "Fortitude code."
          }
          li {
            strong { em "Safe" }; text ": We "; em "never"; text " have to call "; code "#h"; text " anywhere here, "
            text "nor do we even have to think about HTML escaping. It’s all just handled for us, as it should be, "
            text "with no risk of XSS attacks. (This doesn’t mean it’s "; em "impossible"; text " to create XSS "
            text "vulnerabilities using Fortitude, of course — but it’s much, much more difficult, because you "
            text "effectively never have to compose HTML using Ruby strings.)"
          }
          li {
            strong "Indentation (of Source)"; text ": It’s obvious how the source should be indented, there’s only "
            text "one reasonable way to do it, and any editor "
            text "capable of indenting Ruby properly will automatically indent Fortitude properly."
          }
          li {
            p {
              strong "Indentation (of Output)"; text ": Because Fortitude understands the structure of your code, "
              text "it "; em "always"; text " produces perfectly-formatted output. Here’s what the equivalent to the "
              text "poorly-formatted HTML output from ERb above looks like if it’s coming from Fortitude:"
            }

            html_source <<-EOS
<html>
  <head>
    ...
  </head>
  <body>
    ...
    <h1>Most Reporting Users in the last 30 days:</h1>

    <table class="reporting_users user_list">
      <thead>
        <tr>
          <th>User ID</th>
          <th>Username</th>
          <th>Email</th>
          <th>Last Login</th>
          <th>Total Reported Users</th>
          <th>Reported-For Breakdown</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>12345</td>
          <td>jane_doe_1</td>
          <td>jdoe@example.com</td>
          <td>about 2 hours ago</td>
          <td>17</td>
          <td>
            Flag <strong>Spam</strong>: 27 total flag(s)<br>
            Flag <strong>Personal Attack</strong>: 17 total flag(s)<br>
            Flag <strong>Off-Topic</strong>: 9 total flag(s)<br>
          </td>
        </tr>
      </tbody>
    </table>
    ...
  </body>
</html>
EOS

            p {
              text "(In production, Fortitude will, by default, emit this code with no whitespace at all, reducing your "
              text "page weight significantly — also something that ERb cannot do.)"
            }
          }
        }

        p {
          text "Altogether, Fortitude has helped us refactor this view in a way we simply couldn’t have using any "
          text "traditional templating engine. "
        }

        p {
          text "One of the reasons the complex ERb refactoring above may seem unfamiliar to many readers "
          text "is simply that the refactoring ends up being so complex that most teams simply don’t do it — they leave "
          text "this view un-refactored, like the original example, since it actually is cleaner in many ways than "
          text "the refactored version. And, like before, this doesn’t mean that the original is actually particularly "
          em "good"; text "; it contains an awful lot of duplication — it’s just that the tools traditional templating "
          text "engines give you are insufficient to refactor this code well."
        }

        p {
          text " By providing you all the power of Ruby "
          text "to refactor your code, Fortitude allows you to refactor this code into something that’s clean, clear, "
          text "and actually a joy to work with."
        }

        p {
          text "Next, we’ll take a look at how Fortitude lets you use inheritance to beautifully and effectively factor "
          text "a set of views that all have a lot in common, but differ in their exact details."
        }
      end
    end
  end
end
