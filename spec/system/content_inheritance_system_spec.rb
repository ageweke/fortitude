describe "Fortitude content inheritance", :type => :system do
  it "should allow calling super from #content" do
    parent = widget_class_with_content { text 'parent!' }
    child = widget_class_with_content(:superclass => parent) do
      super()
      text "child!"
      super()
    end

    expect(render(parent.new)).to eq("parent!")
    expect(render(child.new)).to eq("parent!child!parent!")
  end
end
