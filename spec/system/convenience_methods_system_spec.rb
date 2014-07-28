describe "Fortitude convenience methods", :type => :system do
  describe "#all_fortitude_superclasses" do
    it "should return an empty array for ::Fortitude::Widget" do
      expect(::Fortitude::Widget.all_fortitude_superclasses).to eq([ ])
    end

    it "should return just ::Fortitude::Widget for a direct subclass" do
      class ConvenienceSpecAllSuperclassesDirectSubclass < ::Fortitude::Widget; end
      expect(ConvenienceSpecAllSuperclassesDirectSubclass.all_fortitude_superclasses).to eq([ ::Fortitude::Widget ])
    end

    it "should return a whole class hierarchy if appropriate" do
      class ConvenienceSpecAllSuperclassesGrandparent < ::Fortitude::Widget; end
      class ConvenienceSpecAllSuperclassesParent < ConvenienceSpecAllSuperclassesGrandparent; end
      class ConvenienceSpecAllSuperclassesChild < ConvenienceSpecAllSuperclassesParent; end
      expect(ConvenienceSpecAllSuperclassesChild.all_fortitude_superclasses).to eq([
        ConvenienceSpecAllSuperclassesParent,
        ConvenienceSpecAllSuperclassesGrandparent,
        ::Fortitude::Widget
      ])
    end
  end

  describe "#javascript" do
    it "should output JavaScript inside the proper tag, by default" do
      expect(render(widget_class_with_content { javascript "hi, there" })).to eq(
        %{<script>hi, there</script>})
    end

    it "should include newlines if we're formatting output, but not indent it" do
      wc = widget_class do
        format_output true

        def content
          div do
            text "hi"
            javascript "hi, there"
            text "bye"
          end
        end
      end

      expect(render(wc)).to eq(%{<div>
  hi
<script>
hi, there
</script>
  bye
</div>})
    end
  end
end
