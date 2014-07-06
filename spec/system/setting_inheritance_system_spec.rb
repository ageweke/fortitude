describe "Fortitude setting inheritance", :type => :system do
  # The settings we test here:
  #   - extra_assigns
  #   - automatic_helper_access
  #   - implicit_shared_variable_access
  #   - use_instance_variables_for_assigns
  #   - format_output
  #   - enforce_element_nesting_rules
  #   - enforce_attribute_rules
  #   - start_and_end_comments
  #   - translation_base
  #   - enforce_id_uniqueness
  #   - debug
  #
  # needs are covered by the needs_system_spec, and around_content is covered by the around_content_system_spec;
  # these are not tested here because their semantics are quite a bit more complex than the settings here.

  def translation_base_should_be(expected_result, *klasses)
    klasses.each do |klass|
      expect(klass.translation_base).to eq(expected_result)
      send("translation_base_should_be_for_class", expected_result, klass)
    end
  end

  def translation_base_should_be_for_class(expected_result, klass)
    expect(klass.translation_base).to eq(expected_result)
    ho_class = Class.new do
      def t(x)
        "translation_for:#{x}"
      end
    end
    ho = ho_class.new

    rendering_context = rc(:helpers_object => ho)
    expect(render(klass, :rendering_context => rendering_context)).to eq("translation: translation_for:#{expected_result}.foo.bar.baz")
  end


  def enforce_id_uniqueness_should_be(expected_result, *klasses)
    klasses.each do |klass|
      expect(klass.enforce_id_uniqueness).to eq(expected_result)
      send("enforce_id_uniqueness_should_be_#{expected_result}", klass)
    end
  end

  def enforce_id_uniqueness_should_be_true(klass)
    expect { render(klass) }.to raise_error(Fortitude::Errors::DuplicateId)
  end

  def enforce_id_uniqueness_should_be_false(klass)
    expect(render(klass)).to eq('<p id="foo"></p><p id="foo"></p>')
  end


  def start_and_end_comments_should_be(expected_result, *klasses)
    klasses.each do |klass|
      expect(klass.start_and_end_comments).to eq(expected_result)
      send("start_and_end_comments_should_be_#{expected_result}", klass)
    end
  end

  def start_and_end_comments_should_be_true(klass)
    result = render(klass)
    if result =~ /^(.*BEGIN?)\s*\S+\s*(depth.*END)\s*\S+\s*(depth.*)$/i
      expect($1).to eq("<!-- BEGIN")
      expect($2).to eq("depth 0: :baz => (DEFAULT) \"default_baz\" --><p></p><!-- END")
      expect($3).to eq("depth 0 -->")
    else
      raise "result does not match expected pattern: #{result.inspect}"
    end
  end

  def start_and_end_comments_should_be_false(klass)
    expect(render(klass)).to eq("<p></p>")
  end


  def debug_should_be(expected_result, *klasses)
    klasses.each do |klass|
      expect(klass.debug).to eq(expected_result)
      send("debug_should_be_#{expected_result}", klass)
    end
  end

  def debug_should_be_true(klass)
    expect { render(klass) }.to raise_error(Fortitude::Errors::BlockPassedToNeedMethod)
  end

  def debug_should_be_false(klass)
    expect(render(klass)).to eq("p is: abc")
  end


  def enforce_attribute_rules_should_be(expected_result, *klasses)
    klasses.each do |klass|
      expect(klass.enforce_attribute_rules).to eq(expected_result)
      send("enforce_attribute_rules_should_be_#{expected_result}", klass)
    end
  end

  def enforce_attribute_rules_should_be_true(klass)
    expect { render(klass) }.to raise_error(Fortitude::Errors::InvalidElementAttributes)
  end

  def enforce_attribute_rules_should_be_false(klass)
    expect(render(klass)).to eq("<p foo=\"bar\"></p>")
  end


  def close_void_tags_should_be(expected_result, *klasses)
    klasses.each do |klass|
      expect(klass.close_void_tags).to eq(expected_result)
      send("close_void_tags_should_be_#{expected_result}", klass)
    end
  end

  def close_void_tags_should_be_true(klass)
    expect(render(klass)).to eq("<br/>")
  end

  def close_void_tags_should_be_false(klass)
    expect(render(klass)).to eq("<br>")
  end


  def enforce_element_nesting_rules_should_be(expected_result, *klasses)
    klasses.each do |klass|
      expect(klass.enforce_element_nesting_rules).to eq(expected_result)
      send("enforce_element_nesting_rules_should_be_#{expected_result}", klass)
    end
  end

  def enforce_element_nesting_rules_should_be_true(klass)
    expect { render(klass) }.to raise_error(Fortitude::Errors::InvalidElementNesting)
  end

  def enforce_element_nesting_rules_should_be_false(klass)
    expect(render(klass)).to eq("<p><div></div></p>")
  end


  def record_tag_emission_should_be(expected_result, *klasses)
    klasses.each do |klass|
      expect(klass.record_tag_emission).to eq(expected_result)
      send("record_tag_emission_should_be_#{expected_result}", klass)
    end
  end

  def record_tag_emission_should_be_true(klass)
    instance = klass.new
    expect(render(instance)).to eq("<p><div></div></p>")
    expect(instance.inner_element_nesting.map(&:name)).to eq([ :p, :div ])
  end

  def record_tag_emission_should_be_false(klass)
    instance = klass.new
    expect(render(instance)).to eq("<p><div></div></p>")
    expect(instance.inner_element_nesting).to eq([ ])
  end


  def format_output_should_be(expected_result, *klasses)
    klasses.each do |klass|
      expect(klass.format_output).to eq(expected_result)
      send("format_output_should_be_#{expected_result}", klass)
    end
  end

  def format_output_should_be_true(klass)
    expect(render(klass)).to eq(%{<div>
  <p>
    <span class="foo"></span>
  </p>
</div>})
  end

  def format_output_should_be_false(klass)
    expect(render(klass)).to eq('<div><p><span class="foo"></span></p></div>')
  end


  def extra_assigns_should_be(expected_result, *klasses)
    klasses.each do |klass|
      expect(klass.extra_assigns).to eq(expected_result)
      send("extra_assigns_should_be_#{expected_result}", klass)
    end
  end

  def extra_assigns_should_be_use(klass)
    expect(render(klass.new(:foo => 'the_foo'))).to match(/foo: the_foo/)
  end

  def extra_assigns_should_be_ignore(klass)
    expect(render(klass.new(:foo => 'the_foo'))).to match(/foo: NameError/)
  end

  def extra_assigns_should_be_error(klass)
    expect { klass.new(:foo => 'the_foo') }.to raise_error(Fortitude::Errors::ExtraAssigns)
  end


  def automatic_helper_access_should_be(expected_result, *klasses)
    klasses.each do |klass|
      expect(klass.automatic_helper_access).to eq(expected_result)
      send("automatic_helper_access_should_be_#{expected_result}", klass)
    end
  end

  def rc_for_automatic_helper_access
    @aha_helpers_class ||= Class.new do
      def helper1
        "this is helper1!"
      end
    end

    rc(:helpers_object => @aha_helpers_class.new)
  end

  def automatic_helper_access_should_be_true(klass)
    expect(render(klass.new, :rendering_context => rc_for_automatic_helper_access)).to match(/helper1: this is helper1!/)
  end

  def automatic_helper_access_should_be_false(klass)
    expect(render(klass.new, :rendering_context => rc_for_automatic_helper_access)).to match(/helper1: NameError/)
  end


  def implicit_shared_variable_access_should_be(expected_result, *klasses)
    klasses.each do |klass|
      expect(klass.implicit_shared_variable_access).to eq(expected_result)
      send("implicit_shared_variable_access_should_be_#{expected_result}", klass)
    end
  end

  def rc_for_implicit_shared_variable_access
    @isva_obj = Object.new
    @isva_obj.instance_variable_set("@bar", "this is bar!")
    rc(:instance_variables_object => @isva_obj)
  end

  def implicit_shared_variable_access_should_be_true(klass)
    expect(render(klass.new, :rendering_context => rc_for_implicit_shared_variable_access)).to match(/bar: &quot;this is bar!&quot;/)
  end

  def implicit_shared_variable_access_should_be_false(klass)
    expect(render(klass.new, :rendering_context => rc_for_implicit_shared_variable_access)).to match(/bar: nil/)
  end


  def use_instance_variables_for_assigns_should_be(expected_result, *klasses)
    klasses.each do |klass|
      expect(klass.use_instance_variables_for_assigns).to eq(expected_result)
      send("use_instance_variables_for_assigns_should_be_#{expected_result}", klass)
    end
  end

  def use_instance_variables_for_assigns_should_be_true(klass)
    expect(render(klass.new(:baz => 'some_baz'))).to match(/baz: &quot;some_baz&quot;/)
  end

  def use_instance_variables_for_assigns_should_be_false(klass)
    expect(render(klass.new(:baz => 'some_baz'))).to match(/baz: nil/)
  end

  before :each do
    @grandparent = widget_class do
      needs :baz => 'default_baz'

      def content
        foo_value = begin
          foo
        rescue => e
          e.class.name
        end

        text "foo: #{foo_value}\n"

        helper1_value = begin
          helper1
        rescue => e
          e.class.name
        end

        text "helper1: #{helper1_value}\n"
        text "bar: #{@bar.inspect}\n"
        text "baz: #{@baz.inspect}"
      end
    end

    @parent1 = widget_class(:superclass => @grandparent)
    @child11 = widget_class(:superclass => @parent1)
    @child12 = widget_class(:superclass => @parent1)

    @parent2 = widget_class(:superclass => @grandparent)
    @child21 = widget_class(:superclass => @parent2)
    @child22 = widget_class(:superclass => @parent2)
  end

  it "should properly inherit extra_assigns" do
    extra_assigns_should_be(:ignore, @grandparent, @parent1, @child11, @child12, @parent2, @child21, @child22)

    @parent1.extra_assigns :use
    extra_assigns_should_be(:ignore, @grandparent, @parent2, @child21, @child22)
    extra_assigns_should_be(:use, @parent1, @child11, @child12)

    @parent2.extra_assigns :error
    extra_assigns_should_be(:ignore, @grandparent)
    extra_assigns_should_be(:error, @parent2, @child21, @child22)
    extra_assigns_should_be(:use, @parent1, @child11, @child12)

    @grandparent.extra_assigns :use
    extra_assigns_should_be(:error, @parent2, @child21, @child22)
    extra_assigns_should_be(:use, @grandparent, @parent1, @child11, @child12)

    @grandparent.extra_assigns :ignore
    extra_assigns_should_be(:error, @parent2, @child21, @child22)
    extra_assigns_should_be(:use, @parent1, @child11, @child12)
    extra_assigns_should_be(:ignore, @grandparent)

    @child22.extra_assigns :ignore
    extra_assigns_should_be(:error, @parent2, @child21)
    extra_assigns_should_be(:use, @parent1, @child11, @child12)
    extra_assigns_should_be(:ignore, @grandparent, @child22)
  end

  it "should properly inherit automatic_helper_access" do
    automatic_helper_access_should_be(true, @grandparent, @parent1, @child11, @child12, @parent2, @child21, @child22)

    @parent1.automatic_helper_access false
    automatic_helper_access_should_be(true, @grandparent, @parent2, @child21, @child22)
    automatic_helper_access_should_be(false, @parent1, @child11, @child12)

    @parent2.automatic_helper_access true
    automatic_helper_access_should_be(true, @grandparent, @parent2, @child21, @child22)
    automatic_helper_access_should_be(false, @parent1, @child11, @child12)

    @grandparent.automatic_helper_access false
    automatic_helper_access_should_be(true, @parent2, @child21, @child22)
    automatic_helper_access_should_be(false, @grandparent, @parent1, @child11, @child12)

    @grandparent.automatic_helper_access true
    automatic_helper_access_should_be(true, @grandparent, @parent2, @child21, @child22)
    automatic_helper_access_should_be(false, @parent1, @child11, @child12)
  end

  it "should properly inherit close_void_tags" do
    @grandparent.class_eval do
      def content
        br
      end
    end

    close_void_tags_should_be(false, @grandparent, @parent1, @child11, @child12, @parent2, @child21, @child22)

    @parent1.close_void_tags true
    close_void_tags_should_be(false, @grandparent, @parent2, @child21, @child22)
    close_void_tags_should_be(true, @parent1, @child11, @child12)

    @parent2.close_void_tags false
    close_void_tags_should_be(false, @grandparent, @parent2, @child21, @child22)
    close_void_tags_should_be(true, @parent1, @child11, @child12)

    @grandparent.close_void_tags true
    close_void_tags_should_be(false, @parent2, @child21, @child22)
    close_void_tags_should_be(true, @grandparent, @parent1, @child11, @child12)

    @grandparent.close_void_tags false
    close_void_tags_should_be(false, @grandparent, @parent2, @child21, @child22)
    close_void_tags_should_be(true, @parent1, @child11, @child12)
  end

  it "should properly inherit format_output" do
    @grandparent.class_eval do
      def content
        div do
          p do
            span :class => 'foo'
          end
        end
      end
    end

    format_output_should_be(false, @grandparent, @parent1, @child11, @child12, @parent2, @child21, @child22)

    @parent1.format_output true
    format_output_should_be(false, @grandparent, @parent2, @child21, @child22)
    format_output_should_be(true, @parent1, @child11, @child12)

    @parent2.format_output false
    format_output_should_be(false, @grandparent, @parent2, @child21, @child22)
    format_output_should_be(true, @parent1, @child11, @child12)

    @grandparent.format_output true
    format_output_should_be(false, @parent2, @child21, @child22)
    format_output_should_be(true, @grandparent, @parent1, @child11, @child12)

    @grandparent.format_output false
    format_output_should_be(false, @grandparent, @parent2, @child21, @child22)
    format_output_should_be(true, @parent1, @child11, @child12)
  end

  it "should properly inherit enforce_element_nesting_rules" do
    @grandparent.class_eval do
      def content
        p { div }
      end
    end

    enforce_element_nesting_rules_should_be(false, @grandparent, @parent1, @child11, @child12, @parent2, @child21, @child22)

    @parent1.enforce_element_nesting_rules true
    enforce_element_nesting_rules_should_be(false, @grandparent, @parent2, @child21, @child22)
    enforce_element_nesting_rules_should_be(true, @parent1, @child11, @child12)

    @parent2.enforce_element_nesting_rules false
    enforce_element_nesting_rules_should_be(false, @grandparent, @parent2, @child21, @child22)
    enforce_element_nesting_rules_should_be(true, @parent1, @child11, @child12)

    @grandparent.enforce_element_nesting_rules true
    enforce_element_nesting_rules_should_be(false, @parent2, @child21, @child22)
    enforce_element_nesting_rules_should_be(true, @grandparent, @parent1, @child11, @child12)

    @grandparent.enforce_element_nesting_rules false
    enforce_element_nesting_rules_should_be(false, @grandparent, @parent2, @child21, @child22)
    enforce_element_nesting_rules_should_be(true, @parent1, @child11, @child12)
  end

  it "should properly inherit record_tag_emission" do
    @grandparent.class_eval do
      attr_reader :inner_element_nesting

      def content
        p { div { @inner_element_nesting = rendering_context.current_element_nesting.dup } }
      end
    end

    record_tag_emission_should_be(false, @grandparent, @parent1, @child11, @child12, @parent2, @child21, @child22)

    @parent1.record_tag_emission true
    record_tag_emission_should_be(false, @grandparent, @parent2, @child21, @child22)
    record_tag_emission_should_be(true, @parent1, @child11, @child12)

    @parent2.record_tag_emission false
    record_tag_emission_should_be(false, @grandparent, @parent2, @child21, @child22)
    record_tag_emission_should_be(true, @parent1, @child11, @child12)

    @grandparent.record_tag_emission true
    record_tag_emission_should_be(false, @parent2, @child21, @child22)
    record_tag_emission_should_be(true, @grandparent, @parent1, @child11, @child12)

    @grandparent.record_tag_emission false
    record_tag_emission_should_be(false, @grandparent, @parent2, @child21, @child22)
    record_tag_emission_should_be(true, @parent1, @child11, @child12)
  end

  it "should properly inherit translation_base" do
    @grandparent.class_eval do
      def content
        text "translation: #{t(".foo.bar.baz")}"
      end
    end

    translation_base_should_be(nil, @grandparent, @parent1, @child11, @child12, @parent2, @child21, @child22)

    @parent1.translation_base "aaa.bbb"
    translation_base_should_be(nil, @grandparent, @parent2, @child21, @child22)
    translation_base_should_be("aaa.bbb", @parent1, @child11, @child12)

    @child22.translation_base "ccc.ddd"
    translation_base_should_be(nil, @grandparent, @parent2, @child21)
    translation_base_should_be("aaa.bbb", @parent1, @child11, @child12)
    translation_base_should_be("ccc.ddd", @child22)

    @grandparent.translation_base "eee.fff"
    translation_base_should_be("eee.fff", @grandparent, @parent2, @child21)
    translation_base_should_be("aaa.bbb", @parent1, @child11, @child12)
    translation_base_should_be("ccc.ddd", @child22)

    @parent2.translation_base "ggg.hhh"
    translation_base_should_be("eee.fff", @grandparent)
    translation_base_should_be("ggg.hhh", @parent2, @child21)
    translation_base_should_be("aaa.bbb", @parent1, @child11, @child12)
    translation_base_should_be("ccc.ddd", @child22)
  end

  it "should properly inherit enforce_id_uniqueness" do
    @grandparent.class_eval do
      def content
        p :id => 'foo'
        p :id => 'foo'
      end
    end

    enforce_id_uniqueness_should_be(false, @grandparent, @parent1, @child11, @child12, @parent2, @child21, @child22)

    @parent1.enforce_id_uniqueness true
    enforce_id_uniqueness_should_be(false, @grandparent, @parent2, @child21, @child22)
    enforce_id_uniqueness_should_be(true, @parent1, @child11, @child12)

    @parent2.enforce_id_uniqueness false
    enforce_id_uniqueness_should_be(false, @grandparent, @parent2, @child21, @child22)
    enforce_id_uniqueness_should_be(true, @parent1, @child11, @child12)

    @grandparent.enforce_id_uniqueness true
    enforce_id_uniqueness_should_be(false, @parent2, @child21, @child22)
    enforce_id_uniqueness_should_be(true, @grandparent, @parent1, @child11, @child12)

    @grandparent.enforce_id_uniqueness false
    enforce_id_uniqueness_should_be(false, @grandparent, @parent2, @child21, @child22)
    enforce_id_uniqueness_should_be(true, @parent1, @child11, @child12)
  end

  it "should properly inherit start_and_end_comments" do
    @grandparent.class_eval do
      def content
        p
      end
    end

    start_and_end_comments_should_be(false, @grandparent, @parent1, @child11, @child12, @parent2, @child21, @child22)

    @parent1.start_and_end_comments true
    start_and_end_comments_should_be(false, @grandparent, @parent2, @child21, @child22)
    start_and_end_comments_should_be(true, @parent1, @child11, @child12)

    @parent2.start_and_end_comments false
    start_and_end_comments_should_be(false, @grandparent, @parent2, @child21, @child22)
    start_and_end_comments_should_be(true, @parent1, @child11, @child12)

    @grandparent.start_and_end_comments true
    start_and_end_comments_should_be(false, @parent2, @child21, @child22)
    start_and_end_comments_should_be(true, @grandparent, @parent1, @child11, @child12)

    @grandparent.start_and_end_comments false
    start_and_end_comments_should_be(false, @grandparent, @parent2, @child21, @child22)
    start_and_end_comments_should_be(true, @parent1, @child11, @child12)
  end

  it "should properly inherit debug" do
    @grandparent.class_eval do
      needs :p => 'abc'

      def content
        p { text "hi" }
        text "p is: #{p}"
      end
    end

    debug_should_be(false, @grandparent, @parent1, @child11, @child12, @parent2, @child21, @child22)

    @parent1.debug true
    debug_should_be(false, @grandparent, @parent2, @child21, @child22)
    debug_should_be(true, @parent1, @child11, @child12)

    @parent2.debug false
    debug_should_be(false, @grandparent, @parent2, @child21, @child22)
    debug_should_be(true, @parent1, @child11, @child12)

    @grandparent.debug true
    debug_should_be(false, @parent2, @child21, @child22)
    debug_should_be(true, @grandparent, @parent1, @child11, @child12)

    @grandparent.debug false
    debug_should_be(false, @grandparent, @parent2, @child21, @child22)
    debug_should_be(true, @parent1, @child11, @child12)
  end

  it "should properly inherit enforce_attribute_rules" do
    @grandparent.class_eval do
      def content
        p :foo => 'bar'
      end
    end

    enforce_attribute_rules_should_be(false, @grandparent, @parent1, @child11, @child12, @parent2, @child21, @child22)

    @parent1.enforce_attribute_rules true
    enforce_attribute_rules_should_be(false, @grandparent, @parent2, @child21, @child22)
    enforce_attribute_rules_should_be(true, @parent1, @child11, @child12)

    @parent2.enforce_attribute_rules false
    enforce_attribute_rules_should_be(false, @grandparent, @parent2, @child21, @child22)
    enforce_attribute_rules_should_be(true, @parent1, @child11, @child12)

    @grandparent.enforce_attribute_rules true
    enforce_attribute_rules_should_be(false, @parent2, @child21, @child22)
    enforce_attribute_rules_should_be(true, @grandparent, @parent1, @child11, @child12)

    @grandparent.enforce_attribute_rules false
    enforce_attribute_rules_should_be(false, @grandparent, @parent2, @child21, @child22)
    enforce_attribute_rules_should_be(true, @parent1, @child11, @child12)
  end

  it "should properly inherit implicit_shared_variable_access" do
    implicit_shared_variable_access_should_be(false, @grandparent, @parent1, @child11, @child12, @parent2, @child21, @child22)

    @parent1.implicit_shared_variable_access true
    implicit_shared_variable_access_should_be(false, @grandparent, @parent2, @child21, @child22)
    implicit_shared_variable_access_should_be(true, @parent1, @child11, @child12)

    @parent2.implicit_shared_variable_access false
    implicit_shared_variable_access_should_be(false, @grandparent, @parent2, @child21, @child22)
    implicit_shared_variable_access_should_be(true, @parent1, @child11, @child12)

    @grandparent.implicit_shared_variable_access true
    implicit_shared_variable_access_should_be(false, @parent2, @child21, @child22)
    implicit_shared_variable_access_should_be(true, @grandparent, @parent1, @child11, @child12)

    @grandparent.implicit_shared_variable_access false
    implicit_shared_variable_access_should_be(false, @grandparent, @parent2, @child21, @child22)
    implicit_shared_variable_access_should_be(true, @parent1, @child11, @child12)
  end

  it "should properly inherit use_instance_variables_for_assigns" do
    use_instance_variables_for_assigns_should_be(false, @grandparent, @parent1, @child11, @child12, @parent2, @child21, @child22)

    @parent1.use_instance_variables_for_assigns true
    use_instance_variables_for_assigns_should_be(false, @grandparent, @parent2, @child21, @child22)
    use_instance_variables_for_assigns_should_be(true, @parent1, @child11, @child12)

    @parent2.use_instance_variables_for_assigns false
    use_instance_variables_for_assigns_should_be(false, @grandparent, @parent2, @child21, @child22)
    use_instance_variables_for_assigns_should_be(true, @parent1, @child11, @child12)

    @grandparent.use_instance_variables_for_assigns true
    use_instance_variables_for_assigns_should_be(false, @parent2, @child21, @child22)
    use_instance_variables_for_assigns_should_be(true, @grandparent, @parent1, @child11, @child12)

    @grandparent.use_instance_variables_for_assigns false
    use_instance_variables_for_assigns_should_be(false, @grandparent, @parent2, @child21, @child22)
    use_instance_variables_for_assigns_should_be(true, @parent1, @child11, @child12)
  end
end
