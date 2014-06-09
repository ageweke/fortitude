describe "Rails production-mode support", :type => :rails do
  uses_rails_with_template :production_mode_system_spec

  it "should not, by default, format output" do
    expect_match("sample_output", %r{<section class="one"><p>hello, Jessica</p></section>}i)
  end

  it "should not, by default, output BEGIN/END debugging tags" do
    data = get_success("sample_output")
    expect(data).not_to match(%r{<!--\s*BEGIN}mi)
    expect(data).not_to match(%r{<!--\s*END}mi)
  end
end
