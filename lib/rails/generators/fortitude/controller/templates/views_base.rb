class Views::Base < Fortitude::Widget
  # You can configure the behavior of Fortitude in this file.
  #
  # Don't be afraid -- by default you can simply ignore this file, and probably everything will
  # work exactly as you'd expect. Come back to it if you want to tweak Fortitude's behavior or
  # read about some of its more interesting features.
  #
  #
  # Fortitude configuration options apply to the class they're invoked on, and all subclasses.
  # By convention, app/views/base.rb holds Views::Base, which is used as the superclass of all
  # Fortitude widgets in a Rails application -- thus, configuration set here will apply to all
  # Fortitude widgets. However, you can create any subclasses of this class you want, and set
  # different configuration there, which will apply to all subclasses of those widgets.
  # (For example, you could create app/views/admin/base.rb containing
  # Views::Admin::Base < Views::Base, and set configuration there that would only apply to any
  # widget inheriting from Views::Admin::Base). The only exception is `doctype`, which cannot
  # be set on the descendant of any class that's set it itself.
  #
  # Below are all the current Fortitude configuration options, as of the creation of this file.


  # This controls the set of tags available to you (and the nesting and attributes they allow,
  # if you enable enforce_element_nesting_rules or enforce_attribute_rules). It also controls
  # what the `doctype!` method outputs, and related behavior (such as how self-closing elements
  # like <br> render).
  #
  # You can choose from :html5, :html4_transitional, :html4_strict, :html4_frameset,
  # :xhtml11, :xhtml10_transitional, :xhtml10_strict, and :xhtml10_frameset.
  doctype :html5



  # format_output: default true in development mode, false otherwise
  #
  # format_output causes the output of "pretty-printed" HTML, beautifully nested and easy for
  # humans to read. If set to false, HTML is produced with as little whitespace as possible
  # while preserving meaning -- better for production, where minimizing size of generated HTML
  # is more important.

  # format_output (!! Rails.env.development?)


  # start_and_end_comments: default true in development mode, false otherwise
  #
  # start_and_end_comments causes comments to be written into the HTML at the start and end
  # of every widget rendered, showing the class name of the widget, its nesting depth, and
  # all the arguments passed to that widget. This makes it vastly easier to look at the HTML
  # generated for an entire page and know exactly which view file to go change in order to
  # change that HTML.

  # start_and_end_comments (!! Rails.env.development?)


  # debug: default true in development mode, false otherwise
  #
  # debug alerts you when a rare, but extremely-difficult-to-debug, situation arises.
  # Fortitude prioritizes parameters declared using 'need' above its built-in HTML tags.
  # As an example, if you pass a parameter called `time` to your view by saying
  # `needs :time`, then the method `time` in your widget will return the value of that
  # attribute, rather than (as it otherwise would) rendering the HTML5 `<time>` tag.
  # This is fine (and you can always use `tag_time` to get the HTML5 tag).
  #
  # But say you forget, imagine it's the tag, and write the following:
  # time { p "this is the time" } (or something similar). Because time is now a method
  # that simply returns the value of the `time` parameter, this code will do absolutely
  # nothing -- it's throwing away the block passed to it, returning the `time` parameter,
  # and outputting nothing. Needless to say, this can be extremely frustrating to debug.
  #
  # If `debug` is true, then, the code above will raise an exception
  # (Fortitude::Errors::BlockPassedToNeedMethod) instead of ignoring the block, and it'll be
  # dramatically easier to debug.

  # debug (!! Rails.env.development?)


  # enforce_element_nesting_rules: default false
  #
  # If set to true, Fortitude will require you to respect the HTML element-nesting rules
  # (for example, you can't put a <div> inside a <p>), and will raise an exception
  # (Fortitude::Errors::InvalidElementNesting) if you do something the HTML spec disallows.
  # This can be extremely useful in helping you to write clean HTML.
  #
  # There is a small speed penalty for turning this on, so it's recommended you only enable
  # it in development mode.

  # enforce_element_nesting_rules false


  # enforce_attribute_rules: default false
  #
  # If set to true, Fortitude will prevent you from using any attribute that isn't defined
  # in the HTML spec, and will raise a Fortitude::Errors::InvalidElementAttributes error
  # if you do otherwise. (Note that any attribute starting with 'data-' or 'aria-' is allowed,
  # since that's in the spec.) This can be extremely useful in helping you to write clean
  # HTML.
  #
  # There is a small speed penalty for turning this on, so it's recommended you only enable
  # it in development mode.

  # enforce_attribute_rules false


  # enforce_id_uniqueness: default false
  #
  # If set to true, Fortitude will prevent you from giving multiple elements the same 'id'
  # on a page, and will raise a Fortitude::Errors::DuplicateId if you do. This can be
  # extremely useful in helping you to write clean HTML.
  #
  # There is a small speed penalty for turning this on, so it's recommended you only enable
  # it in development mode.

  # enforce_id_uniqueness false


  # close_void_tags: default false
  #
  # In HTML5, "self-closing" tags like `<br>` can be written as `<br>` or `<br/>`; either is
  # legal. (In HTML4, `<br/>` is not legal, and neither is `<br></br>`. In XML, `<br/>` or
  # `<br></br>` is mandatory.) By default, Fortitude will output `<br>`. However, if you set
  # `close_void_tags` to true, then Fortitude will output `<br/>`, instead. Attempting to
  # change this to true in a HTML4 doctype or false for an XHTML doctype will result in an
  # error.

  # close_void_tags false


  # extra_assigns: default :ignore
  #
  # This controls what happens if you pass parameters to a widget that it hasn't declared a
  # `need` for. If set to `:ignore`, it will simply ignore them; they will not be available to
  # the widget to use. If set to `:use`, it will make them available for use in the widget --
  # this is not recommended, however; it's better for the widget to declare all parameters
  # it possibly could use, giving them defaults, instead of making undeclared parameters
  # magically accessible. If set to `:error`, Fortitude will raise a
  # Fortitude::Errors::ExtraAssigns in this case. (However, assigning "extra" variables in
  # a Rails controller -- e.g., assigning `@foo`, then rendering a view that doesn't
  # `need :foo` -- will never cause this error.)
  #
  # It can be useful to set this to :error if writing brand-new views (rather than translating
  # old ERb views to Fortitude), since it will enforce cleaner code.
  #
  # There is a small speed penalty for setting this to `:use`.

  # extra_assigns :ignore


  # automatic_helper_access: default true
  #
  # If set to true, Fortitude's access to helpers works identically to ERb's -- i.e., you can
  # use any helper in a Fortitude widget that would be accessible to an equivalent ERb view.
  # If set to false, however, only helpers built-in to Rails and those you manually declare
  # using `helper :foo` are accessible. This can be useful if starting to use Fortitude in
  # a large, messy ERb/HAML/whatever codebase with many helpers, where you don't want new
  # Fortitude code to start using a large variety of perhaps less-than-ideal helpers.

  # automatic_helper_access true


  # implicit_shared_variable_access: default false
  #
  # Rails ERb views use a giant bag of global state: not only can views access any `@foo`
  # controller variable, but partials can, too, even if not passed to them -- and, even
  # worse, they can _write_ to them. Fortitude disallows all of this by default; the only
  # variables accessible to a Fortitude widget are those passed in directly and that it
  # `:needs`. This results in vastly cleaner views. (If you really want to access such
  # variables, even in Fortitude, they are available in a `shared_variables` `Hash`-like
  # object that's accessible by widgets.)
  #
  # However, if you're translating legacy code from ERB/HAML/whatever to Fortitude, you may
  # find that lots of code depends on this sort of action-at-a-distance, to the point where
  # translating it is no longer feasible. If so, you can set `implicit_shared_variable_access`
  # to `true`, and then you can read (and write!) any of these shared variables by simply
  # using the normal syntax (`@foo`).
  #
  # There is a small speed penalty for enabling this.

  # implicit_shared_variable_access false


  # use_instance_variables_for_assigns: default false
  #
  # By default, parameters passed to a Fortitude widget are accessible using Ruby reader/
  # method syntax (`foo`), and _not_ using Ruby instance-variable syntax (`@foo`). This
  # has many advantages, not the least of which is that typos result in a clean exception
  # instead of a "parameter" that happens to always be `nil`.
  #
  # However, if you're translating legacy code from ERB/HAML/whatever to Fortitude, you may
  # find that lots of code depends on accessing parameters as instance variables. Setting
  # this to `true` will expose parameters in both styles (`foo` and `@foo`). (Read, however,
  # about `implicit_shared_variable_access`, above, too -- only by setting that also will
  # Fortitude behave exactly like ERb in all such situations.)

  # use_instance_variables_for_assigns false


  # translation_base: default nil
  #
  # Rails' translation helper (usually called as `#t`, as in `t(:welcome_message)`) allows
  # you to easily localize views. When called with a string starting with a dot,
  # Rails normally prepends the view path to the key before looking it up -- for example,
  # in app/views/foo/bar.html.rb, calling `t('.baz')` is equivalent to calling
  # `t('foo.bar.baz'). However, in Fortitude, you can change this by setting `translation_base`
  # to a string; this will prepend that string, before passing it onwards. (The
  # `translation_base` string itself can even start with a dot, in which case it will be
  # passed onwards to Rails' mechanism, which will then still add the view prefix before
  # looking up the translation.)
  #
  # While generally not needed, this can be used to help clean up legacy applications with
  # messy translations. For example, setting this to `fortitude.` will allow you to segregate
  # all Fortitude translations under a top-level `fortitude` key, while setting it to
  # `.fortitude.` will allow you to segregate each view's Fortitude translations under a
  # Fortitude key underneath that view path.
  #
  # If this is used by any widget in the entire system, there is a small speed penalty applied
  # to all calls of `#t` -- so only use this if you really need it.

  # translation_base nil


  # use_localized_content_methods: default false
  #
  # If set to true, then, if (for example) the locale is set to `fr`, Fortitude will look
  # for a method in the widget called `#localized_content_fr`; if it exists, it will call
  # that method _instead_ of `#content`. This provides support for views that may differ
  # dramatically from one locale to the next.
  #
  # There is a very small speed penalty for any widget using this feature.

  # use_localized_content_methods false
end
