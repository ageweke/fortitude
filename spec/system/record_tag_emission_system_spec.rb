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

  def recorded_tags_from(instance)
    expect(render(instance)).to eq("<div><p></p></div>")
    instance.recorded_tags
  end
end
