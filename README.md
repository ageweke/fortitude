# Fortitude

Fortitude is a new rendering engine for Ruby (with or without Rails), based on the same principles as
[Erector](https://github.com/erector/erector). It expresses HTML using a Ruby DSL. By doing this, it allows you to
factor your view layer far more (and much more naturally) than any other templating engine, allowing dramatically
better maintainability and code quality &mdash; in what is often one of your application's largest layers.

Currently, Fortitude is in beta release: while there are no known bugs, and it has extensive tests (548 examples and
counting), it is as-of-yet largely undocumented and has not received much use outside of its author's environment.
As a result, it is largely intended for people who are already familiar with Erector, and for use in environments
where occasional bugs (that will be fixed quickly) are not an issue.

Fortitude should be production-ready in a short while, including very extensive documentation.

If you're familiar with Erector and want to use Fortitude, see [README-erector.md](README-erector.md).

## Notes for Rails 5 users
If your app explicitly handles any of the `Fortitude::Error` exceptions, be aware that rails now wraps these
in `ActionView::Template::Error`, so be sure to handle those instead. You can access the original fortitude errors with
something like:
```ruby
rescue_from ActionView::Template::Error do |exception|
  original_fortitude_exception = exception.cause
end
```
