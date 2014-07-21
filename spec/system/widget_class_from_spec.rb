require 'fileutils'

describe "Fortitude widget-class-from-(file|source) support", :type => :system do
  def tempdir
    @tempdir ||= begin
      out = File.join(File.dirname(File.dirname(File.dirname(__FILE__))), 'tmp', 'spec', 'widget_class_from_spec')
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

  def wcfs(*args)
    ::Fortitude::Widget.widget_class_from_source(*args)
  end

  def wcff(filename, *args)
    filename = File.join(tempdir, filename)
    ::Fortitude::Widget.widget_class_from_file(filename, *args)
  end

  context "with no hints" do
    it "should return a widget subclass that's already been evaluated" do
      text = "class WidgetFromClass1 < Fortitude::Widget; end"
      ::Object.class_eval(text)
      expect(wcfs(text)).to eq(::WidgetFromClass1)
    end

    it "should automatically evaluate the source, if needed" do
      text = "class WidgetFromClass2 < Fortitude::Widget; end"
      expect(wcfs(text)).to eq(::WidgetFromClass2)
    end

    it "should fail if given source code it can't guess the class name from" do
      expect do
        wcfs("cname = 'WidgetFromCla' + 'ss3'; eval('class ' + cname + ' < ::Fortitude::Widget; end')")
      end.to raise_error(::Fortitude::Widget::Files::CannotDetermineWidgetClassNameError)
    end

    it "should fail if the source code contains something that isn't a widget class" do
      cdne = capture_exception(::Fortitude::Widget::Files::CannotDetermineWidgetClassNameError) do
        wcfs("class WidgetFromClass11; end")
      end
      expect(cdne.tried_class_names).to be_include("WidgetFromClass11")
    end

    it "should work if given something that's a grandchild of Fortitude::Widget, not a direct child" do
      ::Object.class_eval("class WidgetFromClass12Parent < ::Fortitude::Widget; end")
      expect(wcfs("class WidgetFromClass12 < WidgetFromClass12Parent; end")).to eq(WidgetFromClass12)
    end

    it "should be able to guess the class name of a class namespaced in a module" do
      module ::Wcfs1; end
      expect(wcfs("class Wcfs1::WidgetFromClass6 < ::Fortitude::Widget; end")).to eq(Wcfs1::WidgetFromClass6)
    end

    it "should be able to guess the class name of a class nested in a module" do
      expect(wcfs("module Wcfs2; class WidgetFromClass7 < ::Fortitude::Widget; end; end")).to eq(Wcfs2::WidgetFromClass7)
    end

    it "should be able to guess the class name of a class nested in a module several levels deep" do
      expect(wcfs("module Wcfs3; module Wcfs4; class WidgetFromClass8 < ::Fortitude::Widget; end; end; end")).to eq(Wcfs3::Wcfs4::WidgetFromClass8)
    end

    it "should be able to guess the class name of a class nested in a module several levels deep, using newlines" do
      expect(wcfs(%{module Wcfs5
  module Wcfs6
    class WidgetFromClass9 < ::Fortitude::Widget
    end
  end
end})).to eq(Wcfs5::Wcfs6::WidgetFromClass9)
    end

    it "should be able to guess the class name of a class with both nesting and namespacing" do
      ::Object.class_eval %{module Wcfs7; module Wcfs8; module Wcfs9; end; end; end}

      expect(wcfs(%{module Wcfs7
  module Wcfs8
    class Wcfs9::WidgetFromClass10 < ::Fortitude::Widget
    end
  end
end})).to eq(Wcfs7::Wcfs8::Wcfs9::WidgetFromClass10)
    end
  end

  context "with an explicit class name provided" do
    it "should be able to get a widget class, even if it can't get it by parsing the source code" do
      result = wcfs("cname = 'WidgetFromCla' + 'ss4'; eval('class ' + cname + ' < ::Fortitude::Widget; end')",
        :class_names_to_try => [ 'WidgetFromClass4' ])
      expect(result).to eq(WidgetFromClass4)
    end

    it "should be able to get a widget class, even if it can't get it by parsing the source code, if passed in among a bunch of other crap" do
      result = wcfs("cname = 'WidgetFromCla' + 'ss5'; eval('class ' + cname + ' < ::Fortitude::Widget; end')",
        :class_names_to_try => [ 'String', 'Integer', 'Foo::Bar::Baz', 'WidgetFromClass5', 'Baz::Quux' ])
      expect(result).to eq(WidgetFromClass5)
    end
  end

  context "with a magic comment provided" do
    it "should be able to get a widget class, even if it can't get it by parsing the source code" do
      result = wcfs(%{#!fortitude_class: WidgetFromClass13
        cname = 'WidgetFromCla' + 'ss13'; eval('class ' + cname + ' < ::Fortitude::Widget; end')})
      expect(result).to eq(WidgetFromClass13)
    end

    it "should be able to get a widget class, even if it can't get it by parsing the source code, using an alternate magic comment text" do
      result = wcfs(%{#!foo_bar_baz: WidgetFromClass14
        cname = 'WidgetFromCla' + 'ss14'; eval('class ' + cname + ' < ::Fortitude::Widget; end')},
        :magic_comment_text => %w{bar_baz_quux foo_bar_baz foo_Bar})
      expect(result).to eq(WidgetFromClass14)
    end

    it "should be able to get a widget class, even if it can't get it by parsing the source code, using a standard magic comment text, even if an alternate is provided" do
      result = wcfs(%{#!fortitude_class: WidgetFromClass20
        cname = 'WidgetFromCla' + 'ss20'; eval('class ' + cname + ' < ::Fortitude::Widget; end')},
        :magic_comment_text => %w{bar_baz_quux foo_bar_baz foo_Bar})
      expect(result).to eq(WidgetFromClass20)
    end

    it "should be able to get a widget class, even if it can't get it by parsing the source code, even at the end" do
      result = wcfs(%{
        cname = 'WidgetFromCla' + 'ss15'; eval('class ' + cname + ' < ::Fortitude::Widget; end')
#!fortitude_class: WidgetFromClass15})
      expect(result).to eq(WidgetFromClass15)
    end

    it "should not fail if it's wrong (something that doesn't exist)" do
      text = %{#!fortitude_class: Whatever
class WidgetFromClass16 < Fortitude::Widget; end}
      expect(wcfs(text)).to eq(::WidgetFromClass16)
    end

    it "should not fail if it's wrong (something that isn't a widget class)" do
      text = %{#!fortitude_class: String
class WidgetFromClass17 < Fortitude::Widget; end}
      expect(wcfs(text)).to eq(::WidgetFromClass17)
    end

    it "should tell you the magic comment texts it was looking for in the error if it can't find a class" do
      cdne = capture_exception(::Fortitude::Widget::Files::CannotDetermineWidgetClassNameError) do
        wcfs(%{class WidgetFromClass18; end})
      end
      expect(cdne.magic_comment_texts).to eq(%w{fortitude_class})
    end

    it "should tell you the magic comment texts it was looking for in the error if it can't find a class and custom magic texts were provided" do
      cdne = capture_exception(::Fortitude::Widget::Files::CannotDetermineWidgetClassNameError) do
        wcfs(%{class WidgetFromClass19; end}, :magic_comment_text => %w{foo_bar bar_baz})
      end
      expect(cdne.magic_comment_texts).to be_include('fortitude_class')
      expect(cdne.magic_comment_texts).to be_include('foo_bar')
      expect(cdne.magic_comment_texts).to be_include('bar_baz')
    end
  end

  context "when given a file" do
    it "should still be able to guess the class name correctly" do
      splat!('widget_from_file_1.rb', %{class WidgetFromClass21 < Fortitude::Widget; end})
      expect(wcff('widget_from_file_1.rb')).to eq(WidgetFromClass21)
    end

    it "should still be able to use magic comments" do
      splat!('widget_from_file_2.rb', %{#!fortitude_class: WidgetFromClass22\ncname = 'WidgetFromCla' + 'ss22'; eval('class ' + cname + ' < ::Fortitude::Widget; end')})
      expect(wcff('widget_from_file_2.rb')).to eq(WidgetFromClass22)
    end

    it "should be able to use a root directory to infer a class name" do
      ::Object.class_eval("module Wcfs10; module Wcfs11; end; end")
      splat!('wcfs10/wcfs_11/widget_from_class_23.rb', %{cname = 'WidgetFromCla' + 'ss23'; eval('class Wcfs10::Wcfs11::' + cname + ' < ::Fortitude::Widget; end')})
      expect(wcff('wcfs10/wcfs_11/widget_from_class_23.rb', :root_dir => tempdir)).to eq(Wcfs10::Wcfs11::WidgetFromClass23)
    end
  end

  it "should prioritize a magic comment above class names you told it to try or directory-based names or scanned source text" do
    splat!('widget_baz.rb', %{
#!fortitude_class: WidgetFoo

eval('class WidgetB' +
'az < Fortitud' +
'e::Widget; end')
eval('class WidgetB' +
'ar < Fortitud' +
'e::Widget; end')
class WidgetQuux < Fortitude::Widget; end
eval('class WidgetF' +
'oo < Fortitud' +
'e::Widget; end')
    })

    expect(wcff('widget_baz.rb', :root_dir => tempdir, :class_names_to_try => %w{WidgetBar})).to eq(WidgetFoo)
  end

  it "should prioritize class names you told it to try above directory-based names or scanned source text" do
    splat!('widget_baz.rb', %{
eval('class WidgetB' +
'az < Fortitud' +
'e::Widget; end')
eval('class WidgetB' +
'ar < Fortitud' +
'e::Widget; end')
class WidgetQuux < Fortitude::Widget; end
eval('class WidgetF' +
'oo < Fortitud' +
'e::Widget; end')
    })

    expect(wcff('widget_baz.rb', :root_dir => tempdir, :class_names_to_try => %w{WidgetBar})).to eq(WidgetBar)
  end

  it "should prioritize directory-based names above scanned source text" do
    splat!('widget_baz.rb', %{
eval('class WidgetB' +
'az < Fortitud' +
'e::Widget; end')
eval('class WidgetB' +
'ar < Fortitud' +
'e::Widget; end')
class WidgetQuux < Fortitude::Widget; end
eval('class WidgetF' +
'oo < Fortitud' +
'e::Widget; end')
    })

    expect(wcff('widget_baz.rb', :root_dir => tempdir)).to eq(WidgetBaz)
  end
end
