# Fortitude Releases

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
