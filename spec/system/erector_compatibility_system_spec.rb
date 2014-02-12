describe "Fortitude Erector compatibility", :type => :system do
  it "should allow implicit long-distance access to controller variables, if asked to" do
    ivars[:foo] = "the_foo"
    ivars[:bar] = "the_bar"

    superclass = widget_class
    subclass = widget_class(:superclass => superclass) do
      implicit_shared_variable_access true

      def content
        text "foo: #{@foo}, "
        text "bar: #{@bar}"
        @baz = "widget_baz"
      end
    end

    expect(render(subclass)).to eq("foo: the_foo, bar: the_bar")
    expect(ivars[:baz]).to eq("widget_baz")
  end

  it "should properly inherit the setting for implicit long-distance access to controller variables"

  it "should allow local access to needs via @foo, if asked to"
  it "should allow local access to non-needed passed variables via @foo, if asked to"
  it "should allow local access to non-needed passed variables via method, if asked to"
end
