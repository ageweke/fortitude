describe "Fortitude record_tag_emission behavior", :type => :system do
  before :each do
    @recording_class = widget_class do
      attr_reader :recorded_tags

      def content
        div {
          p {
            @recorded_tags = rendering_context.current_element_nesting.dup
          }
        }
      end
    end
  end

  it "should not record tag emission by default" do
    expect(recorded_tags_from(@recording_class.new)).to eq([ ])
  end

  it "should record tag emission if asked to" do
    @recording_class.class_eval { record_tag_emission true }
    expect(recorded_tags_from(@recording_class.new).map(&:name)).to eq([ :div, :p ])
  end

  it "should record tag emission across two widgets" do
    parent_class = widget_class do
      record_tag_emission true
      attr_accessor :child_instance

      def content
        div {
          widget child_instance
        }
      end
    end

    child_class = widget_class do
      record_tag_emission true
      attr_reader :recorded_tags

      def content
        p {
          @recorded_tags = rendering_context.current_element_nesting.dup
        }
      end
    end

    parent_instance = parent_class.new
    child_instance = child_class.new

    parent_instance.child_instance = child_instance

    results = render(parent_instance)
    expect(results).to eq("<div><p></p></div>")

    rt = child_instance.recorded_tags

    expect(rt.shift).to be(parent_instance)
    expect(rt.shift.name).to eq(:div)
    expect(rt.shift).to be(child_instance)
    expect(rt.shift.name).to eq(:p)
    expect(rt).to eq([ ])
  end

  def recorded_tags_from(instance)
    expect(render(instance)).to eq("<div><p></p></div>")
    rt = instance.recorded_tags
    expect(rt.shift).to be(instance)
    rt
  end
end
