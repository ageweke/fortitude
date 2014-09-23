describe "Rails RenderingContext support", :type => :rails do
  uses_rails_with_template :rendering_context_system_spec

  it "should use the context returned by create_fortitude_rendering_context in the view" do
    expect_match("uses_specified_context_in_view", /context is: SimpleRc, value 12345/)
  end

  it "should still use that context even for partials invoked by ERb" do
    expect_match("uses_specified_context_in_partials", /before partial.*context is: SimpleRc, value 23456.*after partial/mi)
  end

  it "should use that context for partials through multiple layers of nesting" do
    text = get_success("uses_specified_context_through_nesting")
    if text =~ /view rc: SimpleRc, 34567, (\d+).*partial.*inner partial rc: SimpleRc, 34567, (\d+)/mi
      first_value, second_value = Integer($1), Integer($2)
      expect(first_value).to eq(second_value)
    else
      raise "Text did not match: #{text.inspect}"
    end
  end

  it "should use that context for widgets rendered with render :widget" do
    expect_match("uses_specified_context_in_render_widget", /context is: SimpleRc, value 45678/)
  end

  it "should use that context for widgets rendered with render :inline" do
    expect_match("uses_specified_context_in_render_inline", /context is: SimpleRc, value 56789/)
  end

  it "should use the context returned by just plain fortitude_rendering_context in the view" do
    expect_match("uses_direct_context_in_view", /context is: SimpleRc, value 67890/)
  end

  it "should still call that method for all widgets" do
    expect_match("uses_direct_context_for_all_widgets", /context is: SimpleRc, value 67890.*context is: SimpleRc, value 67890.*context is: SimpleRc, value 67890/mi)
  end

  it "should call start_widget! and end_widget! properly on widgets in Rails" do
    text = get_success("start_end_widget_basic")
    lines = text.split(/[\r\n]+/)
    lines = lines.select { |l| l =~ /^\d:/ }.map { |l| l.strip }
    expect(lines[0]).to eq("0: start Views::RenderingContextSystemSpec::StartEndWidgetBasic")
    expect(lines[1]).to eq("1: start Views::RenderingContextSystemSpec::StartEndWidgetBasicInner 1")
    expect(lines[2]).to eq("2: end Views::RenderingContextSystemSpec::StartEndWidgetBasicInner 1")
    expect(lines[3]).to eq("3: start Views::RenderingContextSystemSpec::StartEndWidgetBasicInner 2")
    expect(lines[4]).to eq("4: start Views::RenderingContextSystemSpec::StartEndWidgetBasicInner")
    expect(lines[5]).to eq("5: end Views::RenderingContextSystemSpec::StartEndWidgetBasicInner")
    expect(lines[6]).to eq("6: end Views::RenderingContextSystemSpec::StartEndWidgetBasicInner 2")
    expect(lines.length).to eq(7)
  end

  it "should call start_widget! and end_widget! through ERb partials, passing them as hashes" do
    text = get_success("start_end_widget_through_partials")
    lines = text.split(/[\r\n]+/)
    lines = lines.select { |l| l =~ /^\d:/ }.map { |l| l.strip }

    expect(lines[0]).to eq("0: start Views::RenderingContextSystemSpec::StartEndWidgetThroughPartials")
    expect(lines[1]).to eq("1: start Fortitude::Tags::RenderWidgetPlaceholder [{:partial=>\"start_end_widget_through_partials_partial\"}]")
    expect(lines[2]).to eq("2: start Views::RenderingContextSystemSpec::StartEndWidgetThroughPartialsPartialWidget 12345")
    expect(lines[3]).to eq("3: end Views::RenderingContextSystemSpec::StartEndWidgetThroughPartialsPartialWidget 12345")
    expect(lines[4]).to eq("4: end Fortitude::Tags::RenderWidgetPlaceholder [{:partial=>\"start_end_widget_through_partials_partial\"}]")
    expect(lines.length).to eq(5)
  end

       # +<div><span>yohoho
       # +<p>[Views::RenderingContextSystemSpec::CurrentElementNestingToplevel][Fortitude::Tags::Tag][Fortitude::Tags::PartialTagPlaceholder][Array][Views::RenderingContextSystemSpec::CurrentElementNestingChild][Fortitude::Tags::Tag]</p>
       # +</span>
       # +</div>

  it "should return the correct #current_element_nesting, even through multiple widgets and partials" do
    text = get_success("current_element_nesting_toplevel")
    expect(text).to match(%r{<div><span>yohoho\s*<p>0:.*</p>\s*</span>\s*</div>$}mi)
    expect(text).to match(%r{0: \[Views::RenderingContextSystemSpec::CurrentElementNestingToplevel\]}mi)
    expect(text).to match(%r{1: \[Fortitude::Tags::Tag/:div\]}mi)
    expect(text).to match(%r{2: \[Fortitude::Tags::PartialTagPlaceholder/:_fortitude_partial_placeholder\]}mi)
    expect(text).to match(%r{3: \[Fortitude::Tags::RenderWidgetPlaceholder/:_fortitude_render_widget_placeholder\]}mi)
    expect(text).to match(%r{4: \[Views::RenderingContextSystemSpec::CurrentElementNestingChild\]}mi)
    expect(text).to match(%r{5: \[Fortitude::Tags::Tag/:p\]}mi)
  end
end
