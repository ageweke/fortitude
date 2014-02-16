describe "Fortitude setting inheritance", :type => :system do
  # The settings we test here:
  #   - extra_assigns
  #   - automatic_helper_access
  #   - implicit_shared_variable_access
  #   - use_instance_variables_for_assigns
  #
  # needs are covered by the needs_system_spec, and around_content is covered by the around_content_system_spec.

  def extra_assigns_should_be(expected_result, *klasses)
    klasses.each do |klass|
      expect(klass.extra_assigns).to eq(expected_result)
      send("extra_assigns_should_be_#{expected_result}", klass)
    end
  end

  def extra_assigns_should_be_use(klass)
    expect(render(klass.new(:foo => 'the_foo'))).to eq("foo: the_foo")
  end

  def extra_assigns_should_be_ignore(klass)
    expect(render(klass.new(:foo => 'the_foo'))).to eq("foo: NameError")
  end

  def extra_assigns_should_be_error(klass)
    expect { klass.new(:foo => 'the_foo') }.to raise_error(Fortitude::Errors::ExtraAssigns)
  end

  before :each do
    @grandparent = widget_class do
      def content
        foo_value = begin
          foo
        rescue => e
          e.class.name
        end

        text "foo: #{foo_value}"
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

  it "should properly inherit automatic_helper_access"
  it "should properly inherit implicit_shared_variable_access"
  it "should properly inherit use_instance_variables_for_assigns"
end
