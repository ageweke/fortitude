describe "Fortitude convenience methods", :type => :system do
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
