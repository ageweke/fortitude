describe "Fortitude unparsed tag types", :type => :system do
  it "should not escape data inside a <script> tag" do
    expect(render(widget_class_with_content { script "foo < bar > baz & quux" })).to eq(
      %{<script>foo < bar > baz & quux</script>})
  end

  it "should not escape data inside a javascript call" do
    expect(render(widget_class_with_content { javascript "foo < bar > baz & quux" })).to eq(
      %{<script>foo < bar > baz & quux</script>})
  end

  it "should not escape data inside a <style> tag" do
    expect(render(widget_class_with_content { style "foo < bar > baz & quux" })).to eq(
      %{<style>foo < bar > baz & quux</style>})
  end
end
