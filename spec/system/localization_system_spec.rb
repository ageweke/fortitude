describe "Fortitude native (non-Rails) localization support", :type => :system do
  before :each do
    @klass = widget_class do
      def localized_content_en
        text "english!"
      end

      def localized_content_en_GB
        text "hullo!"
      end

      def localized_content_fr
        text "french!"
      end

      def content
        text "saluton"
      end

      def widget_locale
        nil
      end
    end
  end

  it "should not run a localized method unless #widget_locale returns something" do
    expect(render(@klass)).to eq("saluton")
  end

  it "should run the correct content method" do
    @klass.send(:define_method, :widget_locale) { :en }
    expect(render(@klass)).to eq("english!")
    @klass.send(:define_method, :widget_locale) { 'en' }
    expect(render(@klass)).to eq("english!")
    @klass.send(:define_method, :widget_locale) { :fr }
    expect(render(@klass)).to eq("french!")
    @klass.send(:define_method, :widget_locale) { :en_GB }
    expect(render(@klass)).to eq("hullo!")
  end

  it "should run the default method for unknown locales" do
    @klass.send(:define_method, :widget_locale) { :es }
    expect(render(@klass)).to eq("saluton")
  end

  context "with simple locale setting" do
    before :each do
      @klass = widget_class do
        attr_accessor :widget_locale

        def initialize(attributes = { })
          self.widget_locale = attributes.delete(:widget_locale)
          super(attributes)
        end

        def content
          text "saluton"
        end
      end
    end

    it "should work even if localized methods come from a superclass" do
      subclass = Class.new(@klass)
      @klass.class_eval do
        def localized_content_en
          text "english!"
        end
      end

      expect(render(subclass.new)).to eq("saluton")
      expect(render(subclass.new(:widget_locale => 'en'))).to eq("english!")
    end

    it "should work even if localized methods come from a module" do
      mod = Module.new do
        def localized_content_en
          text "english!"
        end
      end

      expect(render(@klass.new(:widget_locale => 'en'))).to eq("saluton")
      @klass.send(:include, mod)
      expect(render(@klass.new(:widget_locale => 'en'))).to eq("english!")
    end

    it "should work even if localized methods are added late" do
      expect(render(@klass.new(:widget_locale => 'en'))).to eq("saluton")
      @klass.send(:define_method, :localized_content_en) do
        text "english!"
      end
      expect(render(@klass.new(:widget_locale => 'en'))).to eq("english!")
    end
  end
end
