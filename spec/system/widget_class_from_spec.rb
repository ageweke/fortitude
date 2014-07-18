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

  def wcff(*args)
    ::Fortitude::Widget.widget_class_from_file(*args)
  end

  context "with no hints" do
    it "should return a widget subclass that's already been evaluated" do
      text = "class ExplicitClass1 < Fortitude::Widget; end"
      ::Object.class_eval(text)
      expect(wcfs(text)).to eq(::ExplicitClass1)
    end

    it "should automatically evaluate the source, if needed" do
      text = "class ExplicitClass2 < Fortitude::Widget; end"
      expect(wcfs(text)).to eq(::ExplicitClass2)
    end

    it "should fail if given source code it can't guess the class name from" do
      expect do
        wcfs("cname = 'ExplicitCla' + 'ss3'; eval('class ' + cname + ' < ::Fortitude::Widget; end')")
      end.to raise_error(::Fortitude::Widget::Files::CannotDetermineWidgetClassNameError)
    end

    it "should be able to guess the class name of a class namespaced in a module" do
      module ::Wcfs1; end
      expect(wcfs("class Wcfs1::ExplicitClass6 < ::Fortitude::Widget; end")).to eq(Wcfs1::ExplicitClass6)
    end

    it "should be able to guess the class name of a class nested in a module" do
      expect(wcfs("module Wcfs2; class ExplicitClass7 < ::Fortitude::Widget; end; end")).to eq(Wcfs2::ExplicitClass7)
    end

    it "should be able to guess the class name of a class nested in a module several levels deep" do
      expect(wcfs("module Wcfs3; module Wcfs4; class ExplicitClass8 < ::Fortitude::Widget; end; end; end")).to eq(Wcfs3::Wcfs4::ExplicitClass8)
    end

    it "should be able to guess the class name of a class nested in a module several levels deep, using newlines" do
      expect(wcfs(%{module Wcfs5
  module Wcfs6
    class ExplicitClass9 < ::Fortitude::Widget
    end
  end
end})).to eq(Wcfs5::Wcfs6::ExplicitClass9)
    end

    it "should be able to guess the class name of a class with both nesting and namespacing" do
      ::Object.class_eval %{module Wcfs7; module Wcfs8; module Wcfs9; end; end; end}

      expect(wcfs(%{module Wcfs7
  module Wcfs8
    class Wcfs9::ExplicitClass10 < ::Fortitude::Widget
    end
  end
end})).to eq(Wcfs7::Wcfs8::Wcfs9::ExplicitClass10)
    end
  end

  context "with an explicit class name provided" do
    it "should be able to get a widget class, even if it can't get it by parsing the source code" do
      result = wcfs("cname = 'ExplicitCla' + 'ss4'; eval('class ' + cname + ' < ::Fortitude::Widget; end')",
        :class_names_to_try => [ 'ExplicitClass4' ])
      expect(result).to eq(ExplicitClass4)
    end

    it "should be able to get a widget class, even if it can't get it by parsing the source code, if passed in among a bunch of other crap" do
      result = wcfs("cname = 'ExplicitCla' + 'ss5'; eval('class ' + cname + ' < ::Fortitude::Widget; end')",
        :class_names_to_try => [ 'String', 'Integer', 'Foo::Bar::Baz', 'ExplicitClass5', 'Baz::Quux' ])
      expect(result).to eq(ExplicitClass5)
    end
  end
end
