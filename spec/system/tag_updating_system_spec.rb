describe "Fortitude tag updating", :type => :system do
  before :each do
    @base_class = widget_class do
      enforce_attribute_rules true
      enforce_element_nesting_rules true

      tag :foo, :valid_attributes => %w{bar baz}
    end

    @derived_class = widget_class(:superclass => @base_class)
  end

  it "should be enforcing rules" do
    @base_class.class_eval do
      def content
        foo :something => 'whatever'
      end
    end

    expect { render(@base_class) }.to raise_error(Fortitude::Errors::InvalidElementAttributes)
  end

  it "should allow replacing a tag completely" do
    @derived_class.tag :foo, :can_enclose => %w{p}
    @derived_class.class_eval do
      def content
        foo :something => 'whatever' do
          p "hi"
        end
      end
    end

    expect(render(@derived_class)).to eq("<foo something=\"whatever\"><p>hi</p></foo>")
  end

  it "should not change the parent class's tag when replacing a tag completely" do
    @derived_class.tag :foo, :can_enclose => %w{p}
    @derived_class.class_eval do
      def content
        foo :something => 'whatever' do
          p "hi"
        end
      end
    end

    expect(render(@derived_class)).to eq("<foo something=\"whatever\"><p>hi</p></foo>")

    @base_class.class_eval do
      def content
        foo :something => 'something_else'
      end
    end

    expect { render(@base_class) }.to raise_error(Fortitude::Errors::InvalidElementAttributes)
  end

  it "should not change the parent class's tag when modifying a tag" do
    @derived_class.modify_tag(:foo) { |t| t.valid_attributes += %w{quux} }
    @derived_class.class_eval do
      def content
        foo :quux => 'baz'
      end
    end

    expect(render(@derived_class)).to eq("<foo quux=\"baz\"></foo>")

    @base_class.class_eval do
      def content
        foo :quux => 'baz'
      end
    end

    expect { render(@base_class) }.to raise_error(Fortitude::Errors::InvalidElementAttributes)
  end

  it "should allow modifying a tag's :valid_attributes" do
    @derived_class.modify_tag(:foo) { |t| t.valid_attributes += %w{quux} }
    @derived_class.class_eval do
      def content
        foo :quux => 'baz'
      end
    end

    expect(render(@derived_class)).to eq("<foo quux=\"baz\"></foo>")
  end

  it "should allow modifying a tag's :can_enclose" do
    @derived_class.modify_tag(:div) { |t| t.can_enclose += %w{_text} }
    @derived_class.modify_tag(:p) { |t| t.can_enclose += %w{div} }
    @derived_class.class_eval do
      def content
        p do
          div "whatever"
        end
      end
    end

    expect(render(@derived_class)).to eq("<p><div>whatever</div></p>")
  end

  it "should allow modifying a tag's :newline_before" do
    @derived_class.modify_tag(:a) { |t| t.newline_before = true }
    @derived_class.class_eval do
      format_output true

      def content
        p do
          text "hello"
          a "there"
          text "goodbye"
        end
      end
    end

    expect(render(@derived_class)).to eq("<p>\n  hello\n  <a>there</a>\n  goodbye\n</p>")
  end

  it "should allow modifying a tag's :content_allowed" do
    @derived_class.modify_tag(:br) { |t| t.content_allowed = true }
    @derived_class.class_eval do
      def content
        br "hello"
      end
    end

    expect(render(@derived_class)).to eq("<br>hello</br>")
  end

  it "should allow modifying a tag's :allow_data_attributes" do
    @derived_class.modify_tag(:p) { |t| t.allow_data_attributes = false }
    @derived_class.class_eval do
      def content
        p :'data-foo' => 'bar'
      end
    end

    expect { render(@derived_class) }.to raise_error(Fortitude::Errors::InvalidElementAttributes)
  end

  it "should allow modifying a tag's :allow_aria_attributes" do
    @derived_class.modify_tag(:p) { |t| t.allow_aria_attributes = false }
    @derived_class.class_eval do
      def content
        p :'aria-foo' => 'bar'
      end
    end

    expect { render(@derived_class) }.to raise_error(Fortitude::Errors::InvalidElementAttributes)
  end

  it "should allow overriding a doctype's tags, but shouldn't modify the doctype itself" do
    @base_class.modify_tag(:p) { |t| t.valid_attributes += %w{bonk} }
    @base_class.class_eval do
      def content
        p :bonk => "whatever"
      end
    end

    expect(render(@base_class)).to eq("<p bonk=\"whatever\"></p>")

    other_widget = widget_class do
      enforce_attribute_rules true

      def content
        p :bonk => :whatever
      end
    end

    expect { render(other_widget) }.to raise_error(Fortitude::Errors::InvalidElementAttributes)
  end
end
