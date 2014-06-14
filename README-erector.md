# Fortitude for Erector Users

This file is intended as a quick introduction to Fortitude for users of Erector. Eventually it will be replaced by
more complete documentation, but, in the mean time, it should be sufficient to get you started. :)

## What is Fortitude?

Fortitude is a Ruby templating engine that works using the same principles as Erector (_i.e._, views are expressed as
classes containing Ruby code, using a DSL that mimics HTML); from a developer's point of view, the two are very
similar. However, Fortitude is a complete, ground-up reimagining and reimplementation, and, as such, has many
advantages:

* Dramatically faster: 40-60x faster (no, that's not a typo) than Erector at rendering real-world Web pages (in fact,
Fortitude appears to be the fastest general-purpose Rails rendering engine, running 10%-40% faster than even ERb/
Erubis);
* Dramatically less garbage generation: produces ≤10% as much garbage when rendering a page (and about 50% as much
garbage as ERb/Erubis);
* Full, complete native HTML5 support (with selectable X/HTML4.01 Strict/Transitional/Frameset doctypes);
* Enforces HTML element-nesting and attribute-name rules, and enforce ID uniqueness across a page (configurable, and off by default);
* In development, beautiful HTML comments around each widget, showing what class is being rendered, the values of all variables supplied to that class, and the nesting depth of that widget;
* Fully compatible with Ruby 1.8.7-2.1.x, JRuby 1.7.11, and Rails 3.0.x-4.1.x;
* Full Tilt support, and can be used with or without Rails;
* Much more thorough Rails support &mdash; all known Rails integration points have been resolved, and it should work
as smoothly with Rails as does (_e.g._) ERb/Erubis;
* Much cleaner, totally transparent support for helpers (both inside and outside of Rails);
* Great internationalization support, iincluding Rails' translation mechanism and per-widget language variants;
* "Staticization" support for incredibly fast rendering of HTML that doesn't depend on input variables;
* Customizable tags (define your own, modify behavior of existing tags, like whether they start a newline in formatted-output mode);
* Configure all options on a per-class basis with inheritance (zero "across-the-board" global settings);
* A much-more-robust `html2fortitude` tool for converting ERb views to Fortitude code;
* ...and much more!

Above all, the primary point of Fortitude is to allow you to _factor your views_, as only Erector (and now Fortitude)
can do, by allowing you to express them as Ruby code. This is by far the largest advantage of using a rendering engine
like Fortitude or Erector. But the rest of the bullet points above are pretty nice, too. :)

## Current Status

Currently, Fortitude is feature-complete and extremely well-tested. However, it is largely yet-undocumented, which
is why current users of Erector are the best candidates for its very first beta users.

Further, Fortitude has not yet been used "in anger" in the real world yet. As such, bugs are likely to crop up,
including perhaps some obvious ones, but they will be fixed extremely quickly. You can help Fortitude get ready for
prime time as quickly as possible by using it, and reporting any issues that crop up!

## Getting Help

* For general information and discussion, join the [`fortitude-ruby`](https://groups.google.com/forum/#!forum/fortitude-ruby) Google group.
* To report bugs, please file a [GitHub issue](https://github.com/ageweke/fortitude/issues).
* To contact the author directly, please [send an email](mailto:andrew@geweke.org).

## What Doesn't It Support?

The only major feature of Erector that Fortitude doesn't support (and likely will never support) is Erector's special
syntax for assigning classes or IDs to HTML tags. For example, in Erector, you can write:

    p.foo  # => '<p class="foo"/>'
    p.foo! # => '<p id="foo"/>'

Supporting this kind of syntax would, as far as this author can determine, necessarily incur a severe performance
penalty in Fortitude. One of the reasons Fortitude is so much faster than Erector is that it can generate HTML
directly and immediately from, say, the `p` method; supporting the syntax above prevents it from doing that (this is
Erector's `Promise` and related code). (In Erector, you can even do `a(:href => 'foo') { ... }.bar!`, and it will
turn that into `<a href="foo" id="bar!">...</a>` &mdash; which is very cool, but very expensive to implement.) The
solution is simply to turn this into hash-style code:

    p(class: 'foo')
    p(id: 'foo')

...which has the advantage of being consistent with the way other attributes are expressed anyway, and allows Fortitude
to achieve great speed.

Fortitude also does not support various pieces of Erector that are not particularly part of its core rendering engine,
but which are included in the `erector` gem anyway &mdash; things like the `Page`, `Table`, and `Form` widgets, the
JQuery and SASS integration, and so on. These have been kept out of Fortitude because (a) there are already
conventional (and much-more-common) ways of integrating these with Rails, (b) trying to design widgets like these that
are useful to nearly all users of Erector/Fortitude may be an unsolvable problem, and (c) the author feels that this
would be best suited for another gem that can depend on `fortitude` anyway.

Finally, there may be small methods or classes here and there from Erector that the author has simply overlooked in
his implementation of Fortitude. As you find things like these that you need, feel free to open a GitHub issue for
them, and they'll be implemented (or a decision made not to implement them) on a case-by-case basis.

## Awesome! How do I get started?

Getting started with Fortitude is very simple:

1. Create a base widget class for your application and declare the doctype you are using;
1. Make sure your view classes are named properly and located in the right files so they can be loaded;
1. If needed, set various options for backwards compatibility with Erector.

### Create a Base Widget Class

While Fortitude does provide widget classes you can inherit from directly (`class MyView < Fortitude::Widgets::Html5`),
you'll almost certainly be happier if you define a single widget class that all your views inherit from. (If you're
using Erector, you probably already have this.) In that class, you want to declare the doctype you're using &mdash;
are we generating HTML5? HTML4.01 Transitional? What?

The simplest way to do this (path assumes Rails; in other applications, all that matters is that this class is
available in the runtime somehow &mdash; you're responsible for making sure it gets loaded):

    app/views/base.rb:

    class Views::Base < Fortitude::Widget
      doctype :html5
    end

You do not have to (nor should you) declare a `doctype` in any widgets that inherit from this class.

### Put Views In the Right Place

Fundamentally, all that Fortitude really cares about is that the class that represents a view gets loaded somehow.
Assuming you're using Rails, if you have a `UsersController` and an action `show`, you can build the view like so:

    app/views/users/show.rb:

    class Views::Users::Show < Views::Base
      needs :user

      def content
        h1("Welcome, #{user.name}!", :class => [ 'announcement', 'heading' ])
        p(:class => 'content') {
          text "Welcome! We're glad to see you, "
          b user.full_name
          text ". We think you're awesome!"
        }
      end
    end

The careful reader may note that this doesn't quite make sense: if `app/views` is on the load path, a file at
`users/show.rb` should define a class named `Users::Show`, not `Views::Users::Show`. The trick is _not_ that `app/` is
on the load path; that would be exceedingly dangerous (since `models/user.rb` could be inferred to contain a class
called `Models::User`). Rather, Fortitude augments ActiveSupport's autoload mechanism to allow exactly the behavior
shown above, where any file under `app/views` will be autoloaded, and assumed to have a class name of `Views::` plus
its path underneath `app/views`.

### Set Options for Backwards Compatibility

Already, you'll notice one major difference from Erector: we access the `user` "need" by calling a method named `user`,
not accessing the `@user` instance variable. This is a deliberate choice: because of this, a) you can override that
method if you need (and call `super` in it as necessary), and b) if you misspell it or later remove the `needs :user`
declaration, you'll get an error immediately, rather than just an always-`nil` variable.

However, if you have an existing codebase using Erector syntax (`@user`), you can change Fortitude to use this instead:

    class Views::Base < Fortitude::Widget
      doctype :html5

      use_instance_variables_for_assigns true
    end

Now the user will be available at both `@user` and `user`.

Fortitude is also considerably more strict about variables passed to its views; only those listed in the `needs`
declaration will be available (and if no `needs` declaration is present, none will be available). Further, variables
set in the controller are only available to a widget if a) it's the top-level view and it `needs` that variable, or
b) it's explicitly passed to that widget. You can change this, too:

    class Views::Base < Fortitude::Widget
      doctype :html5

      extra_assigns :use
      implicit_shared_variable_access true
    end

`extra_assigns :use` says "if passed assignments that I haven't `need`ed, make them available anyway, instead of
ignoring them". (There's `method_missing` magic happening here that causes these extra assignments to show up as
methods; if you've set `use_instance_variables_for_assigns`, they'll show as instance variables, too).
`implicit_shared_variable_access` allows access from the widget to data that hasn't been passed to the widget at all,
but is defined elsewhere &mdash; in Rails, this means controller instance variables.

Note that both these options allow considerably sloppier views, and they are not generally recommended; however, they
do make Fortitude work more like Erector, and thus are very useful if you have a codebase of existing Erector widgets.

Finally, note that these settings take effect on whatever widget you set them on, and all widgets that inherit from
that one, but can be overridden in subclasses. Thus you can (for example) create a `Views::ErectorCompatibility`
widget that sets some of these options for Erector compatibility, but a separate `Views::New` class (or whatever you
want to call it) that you use for new widgets, and on which you don't set `extra_assigns` or
`use_instance_variables_for_assigns`.

# Cool Stuff You Can Do

In addition to the features listed at the beginning, here's some cool stuff you can do &mdash; there's much more, but
this is just to whet your appetite:

* Set `enforce_element_nesting_rules true` in a widget to cause Fortitude to raise an exception if you nest elements
  against the HTML specification (for example, try to put a `p` inside a `span`). You'll get a very detailed error
  message, including a hyperlink to the HTML spec in question. (It's recommended you only do this
  `if Rails.env.development? || Rails.env.test?` or something similar, for obvious reasons.)
* Set `enforce_attribute_rules true` in a widget to cause Fortitude to raise an exception if you try to use an
  attribute that isn't defined in the HTML specification.
* Set `enforce_id_uniqueness true` in a widget to cause Fortitude to raise an exception if you try to use an ID on
  a tag that has already been used on that page.
* By default, `format_output true` is set on `Fortitude::Widget` in Rails development mode. This causes Fortitude to
  produce beautifully-indented HTML, with only a minor performance penalty. You can turn it off in development, or on
  in production, the obvious way.
* By default, `start_and_end_comments true` is set on `Fortitude::Widget` in Rails development mode. This causes
  Fortitude to emit a beautifully-formatted HTML comment above every single widget, telling you what class it's
  rendering and what assigns were passed to it; this makes changing and debugging your output _vastly_ easier, in my
  experience.
* If you want, `close_void_tags false` can be set to emit `<br>` instead of `<br/>`. (The former is arguably more
  correct, while the latter is more consistent with XML and is also accepted in browsers.) This only affects elements
  that are _required_ to be void (have no contents) &mdash; elements that can contain data must always be closed if
  they don't.
* `shared_variables` in a widget allows access to shared (controller-set) variables no matter what the setting of
  `implicit_shared_variable_access` &mdash; for example, `shared_variables[:foo]`. You can even write shared variables
  using `shared_variables[:foo] = 'bar'`, although that's incredibly evil.
* `assigns` in a widget similarly allows access to all assigns passed to that widget, both read and write, when
  indexed like a `Hash` (_e.g._, `assigns[:foo]`, `assigns[:bar] = 'baz'`).
* `doctype!` used within a `content` method will emit the proper `<!DOCTYPE ...>` declaration for the doctype you've
  selected.
* `javascript`, passed a `String`, will generate the proper `<script>` tag for JavaScript, depending on the doctype
  you've selected. (XHTML doctypes will add `CDATA`, HTML4 will add `type="javascript"`, and HTML5 will leave it
  simple, since that's all that's required for HTML5.)
* `comment`, passed a `String`, will emit an HTML comment, properly escaping its text.
* If you have a method in a widget that emits static HTML (_i.e._, always emits the same thing, no matter what
  variables are passed into a widget), define it, then (at class level) say `static :my_method_name`. This causes
  Fortitude to precompile it into a method that simply emits a string, speeding up output significantly.
* At class level, if you say `around_content :foo`, then, instead of simply running `content` on your widget, it will
  run the method `foo`, calling `content` when you `yield`. You can have `around_content` calls, and they nest
  properly, running superclasses' `around_content` blocks outside of subclasses', and so on. This can be used to build
  neat features on top of Fortitude (and is how `start_and_end_comments` is implemented, among other things).
* If you declare a method called, _e.g._, `localized_content_fr`, then, if `I18n.locale` is `fr`, it will run that
  method _instead_ of `content`. This can be used to build completely-different content variants for localization.
* If you're building a layout, and you factor it into multiple methods, it can be difficult to get `yield` working
  properly. You can call `yield_from_widget` anywhere within a widget, and it will do the exact same thing as Rails'
  `yield`.
