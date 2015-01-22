# Contributors to Fortitude

Fortitude is written by [Andrew Geweke](https://github.com/ageweke), with contributions from:

* [Ahto Jussila](https://github.com/ahto): a patch to provide separate MRI and JRuby gems, so that
  `gem install fortitude` works properly no matter which platform you're on.
* [Roman Heinrich](https://github.com/mindreframer): reporting a bug where trying to use Fortitude as a Tilt
  engine to render would fail if the locals passed in were `nil`.
* [Jacob Maine](https://github.com/mainej):
  * Reporting the lack of `ActionMailer` support for Fortitude, and offering a patch to add it;
  * Reporting a bug where view classes ending in `.html.rb` would encounter classloading issues
    (resulting in `uninitialized constant` or `superclass mismatch` errors) in development mode.
* [Leaf](https://github.com/leafo) for:
  * Reporting slow widget classloading in very large systems due to eager, not lazy, complication of `needs`-related
    methods, and significant work helping determine that widget localization support was a major source of slowness
    here.
  * Reporting the need for support for passing blocks to `widget`, and thus being able to `yield` from one widget
    to another.
  * Discussion and details around exactly what `:attribute => true`, `:attribute => false`, and so on should render
    from Fortitude.
  * Reporting multiple bugs in support for `render :widget => ...`, and many useful pointers to possible fixes and
    additional methods to make the implementation a lot more robust.
  * Reporting a bug, tracking down the exact cause, and providing a fix for a case where the closing tag of an element
    would get written to the wrong output buffer if the output buffer was changed inside the element (as could happen
    with, among other things, Rails' `cache` method).
  * Reporting a bug where overriding a "needs" method would work only for the class it was defined on, and not any
    subclasses.
  * Reporting an issue where the module Fortitude uses to mix in its "needs" methods was not given a name, and instead
    the module it used to mix in helper methods was given two names, one of them incorrect.
  * Reporting a bug where using `#capture` inside a widget being rendered via `render :widget => ...` would not work
    properly.
  * Reporting a bug where doing something like `div(nil, :class => 'foo')` would produce just `<div></div>` instead of
    the desired `<div class="foo"></div>`.
  * Reporting an issue where `return`ing from inside a block passed to a tag method would not render the closing tags.
* [Adam Becker](https://github.com/ajb) for:
  * Discussion and details around exactly what `:attribute => true`, `:attribute => false`, and so on should render
    from Fortitude.
  * Reporting an issue where you could not easily render a Fortitude widget from Erector, nor vice-versa.
