require "tilt"
require "fileutils"

describe "Fortitude Tilt integration", :type => :system do
  def tempdir
    @tempdir ||= begin
      out = File.join(File.dirname(File.dirname(__FILE__)), 'tmp', 'spec', 'tilt_system_spec')
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

  def render_with_tilt(full_path, evaluation_scope = context_object, variables = { }, &block)
    template = Tilt.new(full_path)
    template.render(evaluation_scope, variables, &block)
  end

  def render_text_with_tilt(filename, text, evaluation_scope = context_object, variables = { }, &block)
    full_path = splat!(filename, text)
    render_with_tilt(full_path, evaluation_scope, variables, &block)
  end

  it "should render a very simple template via Tilt" do
    text = <<-EOS
class SimpleTemplate < Fortitude::Widget::Html5
  def content
    text "this is"
    p "a simple widget"
    text "!"
  end
end
EOS

    expect(render_text_with_tilt("simple_template.rb", text)).to eq("this is<p>a simple widget</p>!")
  end

  SIMPLE_TEMPLATE_WITH_VARIABLES = <<-EOS
class SimpleTemplateWithVariables < Fortitude::Widget::Html5
  needs :foo, :bar => 'whatever'

  def content
    text "foo: \#{foo}, bar: \#{bar}"
  end
end
EOS

  SIMPLE_TEMPLATE_WITH_VARIABLES_NO_EXTRA_ASSIGNS = <<-EOS
class SimpleTemplateWithVariablesNoExtraAssigns < Fortitude::Widget::Html5
  extra_assigns :error
  needs :foo, :bar => 'whatever'

  def content
    text "foo: \#{foo}, bar: \#{bar}"
  end
end
EOS

  SIMPLE_TEMPLATE_WITH_VARIABLES_WANTS_EXTRA_ASSIGNS = <<-EOS
class SimpleTemplateWithVariablesWantsExtraAssigns < Fortitude::Widget::Html5
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

  def context_object(variable_mappings = { }, klass = Object.class)
    out = klass.new
    variable_mappings.each do |name, value|
      out.instance_variable_set("@#{name}", value)
    end
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

  it "should ignore context-object instance variables that the template doesn't actually need"
  it "should pass extra context-object instance variables if the template wants extra assigns"

  it "should forward the passed block to the widget"

  it "should make explicit locals override variables defined on the context object"
  it "should allow helpers defined on the context object to be invoked via automatic helper support"
  it "should allow helpers defined on the context object to be invoked via explicit helper support"

  it "should not require the class name to match the filename of the widget at all"

  it "should still render a widget that's directly in a module (class Foo::Bar::Baz < Fortitude::Widget::Base)"
  it "should still render a widget that's directly in a module, of a subclass of Widget::Base (class Foo::Bar::Baz < MyWidget)"
  it "should still render a widget that's in a module via namespace nesting (module Foo; module Bar; Baz < Fortitude::Widget::Base)"
  it "should still render a widget that's in a module via namespace nesting, of a subclass of Widget::Base (module Foo; module Bar; Baz < MyWidget)"

  it "should allow overriding the class that's defined in the module explicitly with an option"
  it "should allow overriding the class that's defined in the module explicitly with a comment in the template"
end
