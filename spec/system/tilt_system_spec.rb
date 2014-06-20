require "tilt"
require "fileutils"

describe "Fortitude Tilt integration", :type => :system do
  def tempdir
    @tempdir ||= begin
      out = File.join(File.dirname(File.dirname(File.dirname(__FILE__))), 'tmp', 'spec', 'tilt_system_spec')
      FileUtils.rm_rf(out)
      FileUtils.mkdir_p(out)
      out
    end
  end

  def splat!(filename, text)
    full_path = File.join(tempdir, filename)
    FileUtils.mkdir_p(File.dirname(full_path))
    File.open(full_path, 'w') { |f| f << text }
    full_path
  end

  def render_with_tilt(full_path, evaluation_scope = context_object, variables = { }, options = { }, &block)
    template = Tilt.new(full_path, options)
    template.render(evaluation_scope, variables, &block)
  end

  def render_text_with_tilt(filename, text, evaluation_scope = context_object, variables = { }, options = { }, &block)
    full_path = splat!(filename, text)
    render_with_tilt(full_path, evaluation_scope, variables, options, &block)
  end

  it "should render a very simple template via Tilt" do
    text = <<-EOS
class SimpleTemplate < Fortitude::Widgets::Html5
  def content
    text "this is"
    p "a simple widget"
    text "!"
  end
end
EOS

    expect(render_text_with_tilt("simple_template.rb", text)).to eq("this is<p>a simple widget</p>!")
  end

  it "should allow the Tilt template to be created with an empty string, since earlier versions of Tilt do that" do
    expect { Fortitude::Tilt::FortitudeTemplate.new { "" } }.not_to raise_error
  end

  SIMPLE_TEMPLATE_WITH_VARIABLES = <<-EOS
class SimpleTemplateWithVariables < Fortitude::Widgets::Html5
  needs :foo, :bar => 'whatever'

  def content
    text "foo: \#{foo}, bar: \#{bar}"
  end
end
EOS

  SIMPLE_TEMPLATE_WITH_VARIABLES_NO_EXTRA_ASSIGNS = <<-EOS
class SimpleTemplateWithVariablesNoExtraAssigns < Fortitude::Widgets::Html5
  extra_assigns :error
  needs :foo, :bar => 'whatever'

  def content
    text "foo: \#{foo}, bar: \#{bar}"
  end
end
EOS

  SIMPLE_TEMPLATE_WITH_VARIABLES_WANTS_EXTRA_ASSIGNS = <<-EOS
class SimpleTemplateWithVariablesWantsExtraAssigns < Fortitude::Widgets::Html5
  extra_assigns :use
  needs :foo, :bar => 'whatever'

  def content
    text "foo: \#{foo}, bar: \#{bar}, baz: \#{assigns[:baz] || 'nil'}"
  end
end
EOS

  it "should pass explicit locals to the template" do
    result = render_text_with_tilt("simple_template_with_variables.rb", SIMPLE_TEMPLATE_WITH_VARIABLES, context_object, { :foo => 'the_foo', :bar => 'the_bar' })
    expect(result).to eq("foo: the_foo, bar: the_bar")
  end

  def context_object(variable_mappings = { }, klass = Object.class, &block)
    out = klass.new
    variable_mappings.each do |name, value|
      out.instance_variable_set("@#{name}", value)
    end
    out.instance_eval(&block) if block
    out
  end

  it "should make variables defined on the context object available to the template as needs" do
    co = context_object(:foo => 'the_foo', :bar => 'the_bar')

    result = render_text_with_tilt("simple_template_with_variables.rb", SIMPLE_TEMPLATE_WITH_VARIABLES, co, { })
    expect(result).to eq("foo: the_foo, bar: the_bar")
  end

  it "should allow passing locals as strings, and overriding context-object variables" do
    co = context_object(:foo => 'co_foo', :bar => 'co_bar')
    result = render_text_with_tilt("simple_template_with_variables.rb", SIMPLE_TEMPLATE_WITH_VARIABLES, co, { 'bar' => 'local_bar' })
    expect(result).to eq("foo: co_foo, bar: local_bar")
  end

  it "should allow passing locals as symbols, and overriding context-object variables" do
    co = context_object(:foo => 'co_foo', :bar => 'co_bar')
    result = render_text_with_tilt("simple_template_with_variables.rb", SIMPLE_TEMPLATE_WITH_VARIABLES, co, { :bar => 'local_bar' })
    expect(result).to eq("foo: co_foo, bar: local_bar")
  end

  it "should ignore passed locals that the template doesn't actually need" do
    result = render_text_with_tilt("simple_template_with_variables_no_extra_assigns.rb", SIMPLE_TEMPLATE_WITH_VARIABLES_NO_EXTRA_ASSIGNS,
      context_object, { :foo => 'the_foo', :baz => 'baz!'})
    expect(result).to eq("foo: the_foo, bar: whatever")
  end

  it "should pass extra locals if the template wants extra assigns" do
    result = render_text_with_tilt("simple_template_with_variables_wants_extra_assigns.rb", SIMPLE_TEMPLATE_WITH_VARIABLES_WANTS_EXTRA_ASSIGNS,
      context_object, { :foo => 'the_foo', :baz => 'baz!'})
    expect(result).to eq("foo: the_foo, bar: whatever, baz: baz!")
  end

  it "should ignore context-object instance variables that the template doesn't actually need" do
    result = render_text_with_tilt("simple_template_with_variables_no_extra_assigns.rb", SIMPLE_TEMPLATE_WITH_VARIABLES_NO_EXTRA_ASSIGNS,
      context_object(:foo => 'the_foo', :baz => 'baz!'), { })
    expect(result).to eq("foo: the_foo, bar: whatever")
  end

  it "should pass extra context-object instance variables if the template wants extra assigns" do
    result = render_text_with_tilt("simple_template_with_variables_wants_extra_assigns.rb", SIMPLE_TEMPLATE_WITH_VARIABLES_WANTS_EXTRA_ASSIGNS,
      context_object(:foo => 'the_foo', :baz => 'baz!'), { })
    expect(result).to eq("foo: the_foo, bar: whatever, baz: baz!")
  end

  SHARED_VARIABLE_ACCESS = <<-EOS
class SharedVariableAccess < Fortitude::Widgets::Html5
  def content
    data = shared_variables[:foo]
    text "foo is: \#{data}"
    shared_variables[:foo] = 'new_foo'
  end
end
EOS

  it "should allow instance variables on the context object to be accessed via #shared_variables" do
    co = context_object(:foo => 'the_foo')
    result = render_text_with_tilt("shared_variable_access.rb", SHARED_VARIABLE_ACCESS, co, { })
    expect(result).to eq("foo is: the_foo")
    expect(co.instance_variable_get("@foo")).to eq("new_foo")
  end

  IMPLICIT_SHARED_VARIABLE_ACCESS = <<-EOS
class ImplicitSharedVariableAccess < Fortitude::Widgets::Html5
  implicit_shared_variable_access true
  def content
    text "foo is: \#{@foo}"
    @foo = "new_foo"
  end
end
EOS

  it "should allow instance variables on the context object to be read and written implicitly if implicit_shared_variable_access is set" do
    co = context_object(:foo => 'the_foo')
    result = render_text_with_tilt("implicit_shared_variable_access.rb", IMPLICIT_SHARED_VARIABLE_ACCESS, co, { })
    expect(result).to eq("foo is: the_foo")
    expect(co.instance_variable_get("@foo")).to eq("new_foo")
  end

  WIDGET_WITH_BLOCK = <<-EOS
class WidgetWithBlock < Fortitude::Widgets::Html5
  def content
    data = yield("foo")
    text "data is: \#{data}"
  end
end
EOS

  it "should forward the passed block to the widget" do
    result = render_text_with_tilt("widget_with_block.rb", WIDGET_WITH_BLOCK,
      context_object, { }) { |a| "xx#{a}yy" }
    expect(result).to eq("data is: xxfooyy")
  end

  WIDGET_CALLING_FOO = <<-EOS
class WidgetCallingFoo < Fortitude::Widgets::Html5
  def content
    val = foo("xxx")
    text "val is: \#{val}"
  end
end
EOS

  it "should allow helpers defined on the context object to be invoked via automatic helper support" do
    co = context_object do
      def foo(x)
        "foo#{x}foo"
      end
    end

    result = render_text_with_tilt("widget_calling_foo.rb", WIDGET_CALLING_FOO, co, { })
    expect(result).to eq("val is: fooxxxfoo")
  end

  WIDGET_CALLING_FOO_AHA_OFF = <<-EOS
class WidgetCallingFooAhaOff < Fortitude::Widgets::Html5
  automatic_helper_access false

  def content
    val = invoke_helper(:foo, "yyy")
    text "val is: \#{val}"
  end
end
EOS

  it "should allow helpers defined on the context object to be invoked via explicit helper support" do
    co = context_object do
      def foo(x)
        "foo#{x}foo"
      end
    end

    result = render_text_with_tilt("widget_calling_foo_aha_off.rb", WIDGET_CALLING_FOO_AHA_OFF, co, { })
    expect(result).to eq("val is: fooyyyfoo")
  end

  it "should not require the class name to match the filename of the widget at all" do
    result = render_text_with_tilt("foo_bar.rb", SIMPLE_TEMPLATE_WITH_VARIABLES, context_object, { :foo => 'the_foo', :bar => 'the_bar' })
    expect(result).to eq("foo: the_foo, bar: the_bar")
  end

  it "should still render a widget that's directly in a module (class Foo::Bar::Baz < Fortitude::Widget)" do
    eval("module Spec1; module Bar; end; end")

    text = <<-EOS
class Spec1::Bar::Baz < Fortitude::Widgets::Html5
  def content
    text "hello from spec1"
  end
end
EOS

    expect(render_text_with_tilt("random_#{rand(1_000_000)}.rb", text, context_object, { })).to eq("hello from spec1")
  end

  it "should still render a widget that's directly in a module, of a subclass of Widget (class Foo::Bar::Baz < MyWidget)" do
    eval("module Spec2; module Bar; end; end")
    eval("class Spec2::Spec2Superclass < Fortitude::Widgets::Html5; end")

    text = <<-EOS
class Spec2::Bar::Baz < Spec2::Spec2Superclass
  def content
    text "hello from spec2"
  end
end
EOS

    expect(render_text_with_tilt("random_#{rand(1_000_000)}.rb", text, context_object, { })).to eq("hello from spec2")
  end

  it "should still render a widget that's in a module via namespace nesting (module Foo; module Bar; Baz < Fortitude::Widget)" do
    text = <<-EOS
module Spec3
  module Bar
    class Baz < Fortitude::Widgets::Html5
      def content
        text "hello from spec3"
      end
    end
  end
end
EOS

    expect(render_text_with_tilt("random_#{rand(1_000_000)}.rb", text, context_object, { })).to eq("hello from spec3")
  end

  it "should still render a widget that's in a module via namespace nesting, of a subclass of Widget (module Foo; module Bar; Baz < MyWidget)" do
    eval("module Spec4; class Spec4Superclass < Fortitude::Widgets::Html5; end; end")

    text = <<-EOS
module Spec4
  module Bar
    class Baz < Fortitude::Widgets::Html5
      def content
        text "hello from spec4"
      end
    end
  end
end
EOS

    expect(render_text_with_tilt("random_#{rand(1_000_000)}.rb", text, context_object, { })).to eq("hello from spec4")
  end

  def impossible_to_find_class_name_text(num, insert="")
    text = <<-EOS
klass_name = "Spec#{num}" + "TheClass"
c = Class.new(Fortitude::Widgets::Html5) do
#{insert}
  def content
    text "hello from spec#{num}"
  end
end
::Object.const_set(klass_name, c)
EOS
  end

  it "should fail with a nice message if it can't figure out which class to render" do
    e = capture_exception(Fortitude::Tilt::CannotDetermineTemplateClassError) do
      render_text_with_tilt("random_#{rand(1_000_000)}.rb", impossible_to_find_class_name_text(5), context_object, { })
    end

    expect(e).to be
    expect(e.tried_class_names).to eq([ ])
    expect(e.message).to match(/\#\!fortitude_tilt_class/)
    expect(e.message).to match(/:fortitude_class/)
  end

  it "should allow overriding the class that's defined in the module explicitly with an option" do
    result = render_text_with_tilt("random_#{rand(1_000_000)}.rb", impossible_to_find_class_name_text(6), context_object, { },
      { :fortitude_class => "Spec6TheClass" })
    expect(result).to eq("hello from spec6")
  end

  it "should fail with a nice message if you tell it to use something that doesn't exist, using an option" do
    e = capture_exception(Fortitude::Tilt::NotATemplateClassError) do
      render_text_with_tilt("random_#{rand(1_000_000)}.rb", impossible_to_find_class_name_text(7), context_object, { },
        { :fortitude_class => "NonExistent" })
    end
    expect(e.class_name).to eq("NonExistent")
    expect(e.actual_object).to be_nil
    expect(e.message).to match(/NonExistent/)
  end

  it "should fail with a nice message if you tell it to use something that isn't a class, using an option" do
    e = capture_exception(Fortitude::Tilt::NotATemplateClassError) do
      render_text_with_tilt("random_#{rand(1_000_000)}.rb", impossible_to_find_class_name_text(8), context_object, { },
        { :fortitude_class => 12345 })
    end
    expect(e.class_name).to eq(12345)
    expect(e.actual_object).to eq(12345)
    expect(e.message).to match(/12345/)
  end

  it "should fail with a nice message if you tell it to use something that isn't a widget class, using an option" do
    e = capture_exception(Fortitude::Tilt::NotATemplateClassError) do
      render_text_with_tilt("random_#{rand(1_000_000)}.rb", impossible_to_find_class_name_text(9), context_object, { },
        { :fortitude_class => "String" })
    end
    expect(e.class_name).to eq("String")
    expect(e.actual_object).to eq(String)
    expect(e.message).to match(/String/)
  end

  it "should allow overriding the class that's defined in the module explicitly with a comment in the template" do
    result = render_text_with_tilt("random_#{rand(1_000_000)}.rb",
      impossible_to_find_class_name_text(10, "#!fortitude_tilt_class: Spec10TheClass"), context_object, { })
    expect(result).to eq("hello from spec10")
  end

  it "should fail with a nice message if you tell it to use something that isn't a class, using a comment in the template" do
    e = capture_exception(Fortitude::Tilt::NotATemplateClassError) do
      render_text_with_tilt("random_#{rand(1_000_000)}.rb",
        impossible_to_find_class_name_text(11, "#!fortitude_tilt_class: 12345"), context_object, { })
    end
    expect(e.class_name).to eq("12345")
    expect(e.actual_object).to be_nil
    expect(e.message).to match(/12345/)
  end

  it "should fail with a nice message if you tell it to use something that isn't a widget class, using a comment in the template" do
    e = capture_exception(Fortitude::Tilt::NotATemplateClassError) do
      render_text_with_tilt("random_#{rand(1_000_000)}.rb",
        impossible_to_find_class_name_text(12, "#!fortitude_tilt_class: String"), context_object, { })
    end
    expect(e.class_name).to eq("String")
    expect(e.actual_object).to eq(String)
    expect(e.message).to match(/String/)
  end
end
