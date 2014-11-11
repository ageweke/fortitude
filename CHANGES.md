# Fortitude Releases

## 0.0.6,

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
