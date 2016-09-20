describe "Rails helper support", :type => :rails do
  uses_rails_with_template :helpers_system_spec

  it "should support the built-in Rails helpers by default" do
    skip("Rails 3.1 fails on this test with Ruby 2.3 only") if rails_server.rails_version =~ /^3\.1\./ && RUBY_VERSION =~ /^2\.3\./
    expect_match("basic_helpers",
      /Three months ago: 3 months/mi,
      /A million dollars: \$1,000,000\.00/mi,
      %r{Select datetime:\s*<select.*name="date.*>.*<option.*value="2014".*</option>}mi)
  end

  it "should refine the built-in Rails helpers by default" do
    expect_match("helpers_that_output_when_refined",
      %r{START.*<img.*src="http://example.com/foo".*/><a href="mailto:test@example.com">test@example.com</a><link.*href="http://example.com/bar".*/>END}mi)
  end

  it "should support helpers that use blocks" do
    expect_match("block_helpers",
      %r{<body>\s*<form.*action="/form_dest".*>.*<input.*authenticity_token.*/>.*<p>inside the form</p>.*</form>}mi,
      %r{})
  end

  it "should support built-in Rails helpers that output, rather than return, properly" do
    expect_match("built_in_outputting_helpers",
      %r{<div class=.concat_container.>.*this is concatted.*</div>.*<div class=.safe_concat_container.>.*this is safe_concatted.*</div>}mi)
  end

  it "should support custom-defined helpers" do
    expect_match("custom_helpers_basic", %r{excited: awesome!!!})
  end

  it "should support custom-defined helpers that output, rather than return, properly" do
    expect_match("custom_helper_outputs", %r{how awesome: super awesome!})
  end

  it "should support custom-defined helpers that take a block" do
    expect_match("custom_helpers_with_a_block", %r{fedxxcbayyabcxxdef})
  end

  it "should allow changing a built-in Rails helper from outputting to returning" do
    expect_match("built_in_outputting_to_returning", %r{<body>\s*<p>\s*text is: this is the_text\s*</p>\s*</body>}mi)
  end

  it "should allow changing a built-in Rails helper from returning to outputting" do
    expect_match("built_in_returning_to_outputting", %r{<body>\s*it was 3 months, yo\s*</body>}mi)
  end

  it "should allow changing a custom-defined helper from outputting to returning" do
    expect_match("custom_outputting_to_returning", %r{and super awesome!, yo}mi)
  end

  it "should allow changing a custom-defined helper from returning to outputting" do
    expect_match("custom_returning_to_outputting", %r{and awesome!!!, yo}mi)
  end

  it "should inherit helper settings, but also let them be overridden" do
    expect_match("helper_settings_inheritance", %r{it is really awesome!!!, yo\s*and super awesome!, too}mi)
  end

  it "should allow access to controller methods declared as helpers" do
    expect_match("controller_helper_method", %r{it is \*\~\* Fred \*\~\*\!}mi)
  end

  it "should allow access to methods explicitly imported as helpers" do
    expect_match("controller_helper_module", %r{and &gt;=== June ===&gt;}mi)
  end

  it "should allow turning off automatic helper access" do
    expect_match("automatic_helpers_disabled", %r{excitedly: NoMethodError; time_ago_in_words: NoMethodError; number_to_currency: \$1,000,000.00})
  end

  it "should inherit automatic helper access properly" do
    expect_match("automatic_helpers_inheritance", %r{C1: excitedly: NoMethodError; time_ago_in_words: NoMethodError; number_to_currency: \$1,000,000.00.*C2: excitedly: awesome!!!; time_ago_in_words: 3 months; number_to_currency: \$1,000,000.00})
  end

  it "should allow access to private helpers in exactly the same way as ERb" do
    expect_match("private_helper_erb", %r{a private helper: private!})
    expect_match("private_helper_fortitude", %r{a private helper: private!})
  end
end
