describe "Fortitude setting inheritance", :type => :system do
  # The settings we test here:
  #   - extra_assigns
  #   - automatic_helper_access
  #   - implicit_shared_variable_access
  #   - use_instance_variables_for_assigns
  #
  # needs are covered by the needs_system_spec, and around_content is covered by the around_content_system_spec.

  it "should inherit format_output properly"
  it "should inherit enforce_element_nesting_rules properly"
  it "should inherit enforce_attribute_rules properly"
  it "should inherit start_and_end_comments properly"
  it "should inherit translation_base properly"
  it "should inherit enforce_id_uniqueness properly"

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
