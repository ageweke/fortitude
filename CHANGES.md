# Fortitude Releases

## 0.9.4,

* Fixed an issue where use of Rails' `form_for` or `fields_for` from within another `form_for` or `fields_for` block
  would not produce the correct output. (Thanks to [Leaf](https://github.com/leafo) for the bug report!)

## 0.9.3, 2 February 2015

* Fixed a memory leak when using `render :inline`, or certain other cases triggered by a user. (Fortitude widget
  classes know about all their subclasses, in order to enable proper propagation of configuration changes.
  If you created a subclass of a Fortitude widget that was intended to be single-use or otherwise temporary, it would
  not get garbage-collected, since its superclass would still maintain a reference to it. Fortitude now uses the
  [ref](https://github.com/ruby-concurrency/ref) gem in order to make this a weak reference, hence allowing it to
  be garbage-collected. `render :inline` creates a temporary subclass of a Fortitude widget, thus triggering exactly
  this issue.)

## 0.9.2, 22 January 2015

* Began writing lots of documentation for Fortitude, beginning with the reasons why you should use it.
* Fixed a single spec that caused failures under Rails 4.2.0 (which was an issue with the spec and something changed
  in Rails 4.2, not Fortitude).
* Fixed a bug where if you call `return` from inside a block passed to a tag method, the closing tags would not be
  output, resulting in invalid HTML. (Thanks to [Leaf](https://github.com/leafo) for the bug report!)
* Fixed a bug where if you raised an exception from inside a block passed to a tag method, the closing tags would not
  be output, resulting in invalid HTML.
* Added a couple of missing `form_for` helper methods (`button`, `submit`) that somehow I missed. (Thanks to
  [Leaf](https://github.com/leafo) for the bug report!)
* Fixed a bug where passing an object that was a `Hash`, or a subclass of `Hash`, to a view would cause that object to
  become an object of class `ActiveSupport::HashWithIndifferentAccess` instead. (This was because we were, internally,
  calling `#with_indifferent_access` on the `Hash` we had that contained all assignments to a widget, and
  `#with_indifferent_access` is recursive.)
* `Fortitude::Widget.widget_class_from_file`, when it cannot find a class in the given file, now returns any constants
  it _did_ find matching names it thinks that file might use in the resulting exception. This can be used to, for
  example, determine if the file in question actually contains a module with the appropriate name, rather than a
  widget class.
* When rendering using Tilt, Fortitude now properly supplies the file and line to the call to `eval` the source code of
  the widget. This, in turn, means that `__FILE__`, `__LINE__`, and `caller` will work properly when used at class
  level inside a widget rendered via Tilt.
* Fixed a bug where `Fortitude::Widget.widget_class_from_file` and `Fortitude::Widget.widget_class_from_source` would,
  when scanning a file containing an ordinary class definition like
  `module Foo; module Bar; class Baz < Fortitude::Widget`, instead return a class `Foo::Baz` if such existed and
  was a descendant of `Fortitude::Widget` instead of the correct `Foo::Bar::Baz`.
* Fixed a bug where, if `format_output` was turned on, `<pre>` tags would still insert whitespace and newlines for
  formatting like any other tag &mdash; which is incorrect, because, only inside `<pre>` tags, such whitespace is
  significant. Now, `<pre>` tags correctly suppress all formatting within them.
* Added `Fortitude::Widget#content_and_attributes_from_tag_arguments`; this takes as input any style of arguments
  permitted to a Fortitude tag method (_e.g._, `p`, `p 'hello'`, `p :id => :foo`, `p 'hello', :id => :foo`) and always
  returns a two-element array &mdash; the first element is the text supplied to the method (if any), and the second
  is the attributes supplied to the method (if any), or an empty `Hash` otherwise. This can help take a fair amount of
  bookkeeping burden off of helper methods you might build on top of Fortitude.
* Added `Fortitude::Widget#add_css_classes` (_a.k.a._ `#add_css_class`). This takes as its first argument one or more
  CSS classes to add (as a `String`, `Symbol`, or `Array` of such), and, as its remainder, any arguments valid for a
  Fortitude tag method (_e.g._, textual content, a `Hash` of attributes, textual content and a `Hash`, or neither).
  It then returns a two-argument array of textual content and attributes; the attributes will have a `class` or
  `:class` key that contains any classes specified in the original, plus the additional classes to add. In other
  words, you can use it as such:

```ruby
def super_p(*args, &block)
  p(*add_css_classes(:super, *args), &block)
end
```

  ...and now `super_p` acts just like `p`, except that it adds a class of `super` to its output. This is an extremely
  common pattern in code built on top of Fortitude, and so now it is baked into the core.

## 0.9.1, 14 December 2014

* Fixed a bug where doing something like `div nil, :class => 'foo'` would simply output `<div></div>`, rather than the
  desired `<div class="foo"></div>`. (Thanks to [Leaf](https://github.com/leafo) for the bug report!)
* You can now render widgets from ERb using a `widget` method, using the exact same syntax you would for rendering them
  from Fortitude. In addition, this works for Erector widgets, too.
* Fixed a bug where calling `Fortitude::Widget.widget_class_from_file` would fail if the class name as specified in the
  source text of the file started with leading colons (_e.g._, `class ::Views::Foo`).

## 0.9.0, 29 November 2014

Updated Fortitude's version number to 0.9.0: at this point, Fortitude should be considered fully production-ready,
as it is used successfully in multiple very large systems and bug reports are increasingly rare. I don't want to
release a 1.0 until there's excellent documentation, but the codebase seems to be ready.

* Added explicit support for eager-loading Fortitude widget classes under `views/` for Rails applications. This both
  should improve first-run performance of Fortitude-using Rails applications in production, and should avoid an
  occasional problem where Fortitude widget classes were not properly loaded in environments that used eager loading,
  rather than autoloading, for classes.

## 0.0.10, 25 November 2014

* Fixed an issue where `#capture` was not working properly if you rendered a widget using `render :widget =>` in a
  controller. The fix further simplifies Fortitude's support for that feature and integrates even more correctly with
  Rails in that way. (Thanks to [Leaf](https://github.com/leafo) for the bug report!)
* Fixed an issue where, if you overrode a "needs" method in a class, subclasses of that class would not use the
  overridden method, but instead access the "needs" method directly. (Thanks to [Leaf](https://github.com/leafo)
  for the bug report!)
* Fixed a simple mistake that meant the module Fortitude uses to declare `needs` methods was not given a name at all,
  and instead the module it uses to declare helpers was given two names, one of them incorrect. (Thanks to
  [Leaf](https://github.com/leafo) for catching this.)
* When you're invoking a widget from another widget using the `#widget` method, and you pass a block, that block is
  evaluated in the context of the parent widget. (This has always been true.) However, this meant that something like
  the following was impossible, where you're effectively defining new DSL on a widget-by-widget basis:

```ruby
class Views::ModalDialog < Views::Base
  needs :title

  def content
    h3 "Modal: #{title}"
    yield
    button "Submit"
  end

  def modal_header(name)
    h5 "Modal header: #{name}"
    hr
  end
end

class Views::MyView < Views::Base
  needs :username

  def content
    h1 "User #{username}"

    widget Views::ModalDialog, :title => "User Settings" do
      modal_header "Settings for #{username}"
      input :type => :text, :name => :email
      ...
    end
  end
end
```

  The problem arises because, within the block in `Views::MyView#content`, you want to be able to access methods from
  two contexts: the parent widget (for `#username`), and the child widget (for `#modal_header`). Ruby provides no
  single, simple way to do this, but, without it, it's very difficult to come up with a truly elegant DSL for cases
  like this.

  Fortitude now supports this via a small bit of `method_missing` magic: the block passed to a widget is still
  evaluated in the context of the parent, but, if a method is called that is not present, Fortitude looks for that
  method in the child widget and invokes it there, if present. This allows the above situation, which is important
  for writing libraries that "feel right" to a Ruby programmer. (The fact that the block is evaluated primarily in the
  context of the parent widget, like all other Ruby blocks, preserves important standard Ruby semantics, and also
  means that the onus is on the author of a feature like `Views::ModalDialog` to present method names that are
  unlikely to conflict with those in use in parent widgets &mdash; which seems correct.)

* You can now render Erector widgets from Fortitude widgets using just `widget MyErectorWidget`, and vice-versa, using
  either the class-and-assigns or instantiated-widget calling conventions. Note that this integration is not 100%
  perfect; in particular, passing a block from a Fortitude widget to an Erector widget, or vice-versa, is likely to
  fail or produce incorrect output due to the way Erector manipulates output buffers. However, the simple case of
  invoking a widget from another works fine, and can be very useful to those migrating to Fortitude. (Thanks to
  [Adam Becker](https://github.com/ajb) for the bug report!)
* Fixed an issue where Fortitude could write the close tag of an element to the wrong output buffer if the output
  buffer was changed inside the element (as can happen with, among other things, Rails' `cache` method). This could
  cause the output HTML to be structured improperly. (Thanks to [Leaf](https://github.com/leafo) for the bug report,tracking down the exact cause, and providing the fix!)

## 0.0.9, 20 November 2014

* Fortitude now supports passing blocks to widgets (above and beyond support for Rails' standard layouts and their
  usage using `yield`). You can now do the following:

```ruby
class Views::Foo < Views::Base
  def content
    p "something here"
    widget Views::Bar, :name => 'Yoko' { text "hello" }
    p "something else"
  end
end

class Views::Bar < Views::Base
  def content
    p "more content"
    yield
    p "even more content"
  end
end
```

  This will do as expected and cause `Views::Bar`'s `yield` call to call the block passed to it. Furthermore, because
  it's often very useful to break a widget down into methods, and you might not want to explicitly pass the block all
  over, you can call `yield_from_widget` from _any_ widget method and it will behave correctly. (This has actually
  always been true in Fortitude for yielding to layouts; it just now will also yield to blocks passed into the widget
  directly, too).

  Fortitude first prefers a block passed in to `#widget`; it then looks for a block passed to the constructor of a
  widget, and, finally, it will delegate to the layout (if any) if no other block is found. If there isn't even a
  layout, you will receive an error.

  Unlike Erector, Fortitude passes any arguments you give `yield` through to the widget, whether using `yield` or
  `yield_from_widget`; it also passes, as the first argument, the widget instance being yielded from, too. This allows
  a more elegant solution to the fact that the block is evaluated in the scope of the caller, not the wiget, and thus
  may not have access to Fortitude methods (like `p`, `text`, and so on) if the caller is not itself a widget; you can
  simply call those methods on the passed-in widget instance.

  Thank you to [Leaf](https://github.com/leafo) for bringing up this issue!

* The exact interpretation of attribute values has changed. Along with
  [considerable discussion](https://github.com/ageweke/fortitude/issues/12), it became clear that the most desirable
  behavior was the following: attributes with a value of `false` or `nil` simply are not output at all (thus making
  behavior like `input(:type => :checkbox, :checked => some_boolean_variable)` work properly); attributes with a
  value of `true` are output as the key only (so the previous example becomes `<input type="checkbox" checked>` if
  `some_boolean_variable` is `true`) &mdash; except in XHTML document types, where that would be illegal, so they
  become (_e.g._) `<input type="checkbox" checked="checked">`; and attributes mapped to the empty string are output
  with a value of the empty string. Many thanks to [Leaf](https://github.com/leafo) and
  [Adam Becker](https://github.com/ajb) for all the discussion and validation around this!

* Multiple huge performance increases in Fortitude's class-loading time for widgets. Fortitude internally uses
  dynamic compilation of many methods to achieve the very highest runtime performance; however, the system that did
  this compilation could cause slow startup times if you had a very large number of widgets. Fortitude now lazy-
  compiles some methods and caches its own internal trivial template language in order to make startup much faster
  without slowing down critical runtime performance. Many thanks to [Leaf](https://github.com/leafo) for reporting this
  issue and testing a number of fixes for it as they were made!

* Fixed a number of bugs in Fortitude's support for `render :widget => ...`, including use of helpers, coexistence
  with Erector, and being able to pass a widget class rather than an already-instantiated widget. Many thanks to
  [Leaf](https://github.com/leafo) for the detailed bug report, suggestions for fixes, and pointers to new methods that
  made the implementation much more robust.

## 0.0.8, 13 November 2014

* Fixed an issue where repeated reloading of a view in development mode in Rails could cause an error of the form
  `superclass mismatch for class MyView`. (The issue was that Fortitude was calling `require_dependency` on the view
  `.rb` file in the template handler, which caused it to get loaded outside of the scope where Rails is watching for
  loaded constants, so that it can unload them before the next request. This caused view classes to hang around
  forever, but not necessarily their superclasses, causing a very confusing `superclass mismatch` error.) Many thanks
  again to [Jacob Maine](https://github.com/mainej) for the very detailed bug report and collaboration to fix the
  issue.

## 0.0.7, 11 November 2014

* Fortitude 0.0.6 introduced a regression, where referring to an autoloaded view class by partially-qualified namespace
  path could cause an `Errno::ENOENT` exception indicating that a particular directory wasn't found.

## 0.0.6, 11 November 2014

* Fixed an issue where naming a widget with an `.html.rb` extension (for example) at the end would work at first,
  but cause really irritating errors (like `uninitialized constant Views::Foo::Bar` apparently _in_ the very file
  that defines `Views::Foo::Bar` correctly in `app/views/foo/bar.html.rb`) when editing code in development mode.
  (Thanks to [Jacob Maine](https://github.com/mainej) for the very detailed bug report!)
* Fixed an issue where trying to use Fortitude as a Tilt engine, but passing `nil` for the `locals`, would cause an
  exception. (Thanks to [Roman Heinrich](https://github.com/mindreframer) for reporting the bug!)
* Using Fortitude as a template engine for mailers (`ActionMailer::Base` subclasses) now works. (Believe it or not,
  this was almost completely an issue of forgetting to support this, rather than it being undone &mdash; the code
  was complete, and it was just a matter of applying it to `ActionMailer::Base` as well as `ActionController::Base`.)
  (Thanks to [Jacob Maine](https://github.com/mainej) for the bug report and pull request!)
* The various on-the-fly modules that Fortitude creates and mixes in to widgets (and define helpers,  tag methods,
  and `needs` methods) now all have actual names, which makes them much easier to identify in debugging printouts.
* The code in `spec/` that knew how to reliably create, maintain, shut down, and otherwise manipulate an external
  `rails server` process has now been pulled out into its own gem, `oop_rails_server`; this is so I can also use it
  with a new, closely-related upcoming project, and because reuse is good. ;)
* Updated the Travis configuration to the very latest Ruby and Rails versions.

## 0.0.5, 22 September 2014

* You can now load both Fortitude and Erector at the same time into a project, and it will "just work": Erector
  widgets will render using Erector, and Fortitude widgets will render using Fortitude. (Fortitude takes over the
  actual template engine registration for `.rb` files, and uses a trick to keep Erector from displacing it; it then
  looks at the widget class being rendered, and delegates all Erector rendering directly to Erector.)
* When inside a widget, you can now render a sub-widget using `widget MyWidget.new(...)` &mdash; _i.e._, passing an
  actual widget instance &mdash; or using `widget MyWidget, { :param1 => value1 }` &mdash; _i.e._, passing a widget
  class and a `Hash` of assignments (which can be omitted if the widget doesn't have any `need`s).
* Fixed an issue where, _e.g._, calling `#render_to_string` on a Fortitude widget within a Rails controller, and then
  also rendering a Fortitude widget as the template for that action, would cause a method to be called on `nil`.
* Added `Fortitude::RenderingContext#parent_widget`, which returns the parent widget of the current widget during
  rendering at runtime. (In other words, this is not the superclass of the current widget, but the widget that caused
  this widget to get rendered, using either `Fortitude::Widget#widget` or `render :partial => ...`.) This can, of
  course, be `nil` if there is no current parent widget.
* Added `Fortitude::Widget.all_fortitude_superclasses`, which returns an `Array` of all superclasses of a widget up to,
  but not including, `Fortitude::Widget` itself.
* Added `Fortitude::Widget.widget_class_from_file`, which accepts the path to a file and an array of "root" directories
  to look under (_i.e._, assuming you're using something like Rails' autoloading mechanism), and returns the `Class`
  object for the widget that's contained in that file. This uses a series of mechansims to try to detect the class
  that's present in the file: a "magic comment" that can be present in the file, an array of class names to try
  that you can pass in, the position of the class in the file hierarchy, and scanning the source text itself.
* Added a `record_tag_emission` class-level setting that tells a widget to call `#emitting_tag!` on the
  `Fortitude::RenderingContext` when emitting a tag; you can use this to build various systems that need to know where
  in the hierarchy of tags we are at the moment.
* The object being returned from Fortitude tag methods &mdash; which, in general, you should never use &mdash; now
  inherits from `Object`, not `BasicObject`, so that some built-in methods like `#is_a?` can be safely called on it.
  This is for use in some users' environments doing funny things with the Ruby runtime that end up calling methods
  like that on the return values of widget `#content` methods, which very often just end up being the tag return
  value object.

## 0.0.4, 24 June 2014

* Added support for building a JRuby-specific gem to the gemspec, so that things work smoothly for JRuby users.
  (Thanks, [Ahto Jussila](https://github.com/ahto)!)
* Added preliminary support for inline widget classes: if you call `.inline_subclass` on any subclass of
  `Fortitude::Widget` and pass a block, you'll get back a new subclass of whatever class you called it on, with a
  `content` method defined as per the block you passed. For example:

      my_widget_class = Fortitude::Widgets::Html5.inline_subclass do
        p "hello, world!"
      end
      my_widget_class.new.to_html # => '<p>hello, world!</p>'

* And, similarly, if you call `.inline_html` on any subclass of `Fortitude::Widget` and pass a block, you'll get back
  the HTML rendered by the new subclass of that class. For example:

      html = Fortitude::Widgets::Html5.inline_html do
        p "hello, world!"
      end
      html # => '<p>hello, world!</p>'

* Note that this will not work on `Fortitude::Widget`, because `Fortitude::Widget` has no `doctype` declared, and
  therefore has no HTML tags available. You can either use one of the pre-made classes in `Fortitude::Widgets`, or,
  better yet, declare your own base widget class and then use `.inline_subclass` and `.inline_html` on that. (Using
  that mechanism, you can also set things like `format_output`, `start_and_end_comments`, and even things like
  `needs`, mixing in or defining helper methods, and so on, and it will all work just fine.)

## 0.0.3, 23 June 2014

* Changed `Fortitude::Widget#to_html` to return the generated HTML. If you pass a `Fortitude::RenderingContext` into
  this method that has previously been used to render other HTML, you'll get all HTML (old and new) both, because
  we always append to a single output buffer &mdash; but that should be a corner case at most.

## 0.0.2, 21 June 2014

* Void tags (those that can't take content, ever, like `<hr>` or `<br>`) are now never closed in HTML4 doctypes
  (_i.e._, just output as plain `<hr>`, with no close tag), since using self-closing syntax (`<hr/>`) is
  [broken](http://stackoverflow.com/questions/3558119/are-self-closing-tags-valid-in-html5) and an end tag (`</hr>`)
  is illegal according to the [W3C Validator](http://validator.w3.org/). In XHTML doctypes, they are always closed
  using self-closing syntax (`<hr/>`) since they have to be closed somehow and that's a good way to indicate that
  they are void (can't ever take content). In HTML5, they are left unclosed by default (since HTML5 knows they're void
  and isn't expecting an end tag for them, ever), but you can use `close_void_tags true` to add self-closing syntax
  for them (`<br/>`) if you want, since
  [that is now allowed in HTML5](http://stackoverflow.com/questions/3558119/are-self-closing-tags-valid-in-html5).
  See [this article](http://www.colorglare.com/2014/02/03/to-close-or-not-to-close.html) for even more discussion.
* Empty tags (those that _can_ take content, but just happen not to) are now always closed using a separate tag
  (_e.g._, `<p></p>`), since it is
  [not legal or correct](http://stackoverflow.com/questions/3558119/are-self-closing-tags-valid-in-html5) to use
  self-closing syntax (`<p/>`) here in HTML doctypes (HTML4 or HTML5), and it is perfectly legal in XHTML doctypes to
  use a separate closing tag &mdash; and, in a way, nice, since it lets you visually differentiate between void tags
  and normal tags that just happen to be empty.
* Very significant internal refactoring of code to make development easier, and new developers' lives easier.
* Fixed support for Tilt < 2.x; earlier Tilt versions expect to be able to instantiate a template class with an empty
  string and have it not raise an exception, as a way of testing whether an engine works. (Empty strings are not
  valid Fortitude templates, since we expect to see a class declaration in there.) Now we trap that case explicitly to
  do nothing, which allows Tilt 1.4.x to work.

## 0.0.1, 18 June 2014

* Very first release of Fortitude.
