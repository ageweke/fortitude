describe "Fortitude assigns access", :type => :system do
  it "should expose assigns" do
    wc = widget_class do
      needs :foo, :bar
      def content
        text "assigns[:foo] = #{assigns[:foo]}, assigns[:bar] = #{assigns[:bar]}"
      end
    end

    expect(render(wc.new(:foo => 'the_foo', :bar => 'the_bar'))).to eq("assigns[:foo] = the_foo, assigns[:bar] = the_bar")
  end

  it "should include needs that are left as the default" do
    wc = widget_class do
      needs :foo, :bar => 'def_bar'
      def content
        text "assigns[:foo] = #{assigns[:foo]}, assigns[:bar] = #{assigns[:bar]}"
      end
    end

    expect(render(wc.new(:foo => 'the_foo'))).to eq("assigns[:foo] = the_foo, assigns[:bar] = def_bar")
  end

  it "should not include extra needs, by default" do
    wc = widget_class do
      needs :foo
      def content
        text "assigns[:foo] = #{assigns[:foo]}, assigns[:bar] = #{assigns[:bar]}"
      end
    end

    expect(render(wc.new(:foo => 'the_foo', :bar => 'the_bar'))).to eq("assigns[:foo] = the_foo, assigns[:bar] = ")
  end

  it "should include extra assigns, if we're using them" do
    wc = widget_class do
      extra_assigns :use
      needs :foo
      def content
        text "assigns[:foo] = #{assigns[:foo]}, assigns[:bar] = #{assigns[:bar]}"
      end
    end

    expect(render(wc.new(:foo => 'the_foo', :bar => 'the_bar'))).to eq("assigns[:foo] = the_foo, assigns[:bar] = the_bar")
  end

  it "should allow changing assigns, and always return the current value of the assign" do
    wc = widget_class do
      needs :foo
      def content
        text "foo = #{foo}, assigns[:foo] = #{assigns[:foo]}, "
        assigns[:foo] = "new_foo"
        text "now foo = #{foo}, assigns[:foo] = #{assigns[:foo]}"
      end
    end

    expect(render(wc.new(:foo => 'the_foo'))).to eq("foo = the_foo, assigns[:foo] = the_foo, now foo = new_foo, assigns[:foo] = new_foo")
  end

  it "should not let you introduce new assigns" do
    wc = widget_class do
      def content
        assigns[:quux] = 'the_quux'
        text "assigns[:quux]: #{assigns[:quux].inspect}, "

        quux_value = begin
          quux
        rescue => e
          e.class.name
        end

        text "quux: #{quux_value}"
      end
    end

    expect(render(wc)).to eq("assigns[:quux]: nil, quux: NameError")
  end

  it "should return the same assigns proxy every time" do
    wc = widget_class_with_content do
      text "assigns proxy 1: #{assigns.object_id}, "
      text "assigns proxy 2: #{assigns.object_id}"
    end

    text = render(wc)
    text =~ /assigns proxy 1: (\d+), assigns proxy 2: (\d+)/
    expect($1).to eq($2)
  end

  def should_have_line(text, line)
    lines = text.split(/[\r\n]+/)
    match = lines.detect { |l| l == line }
    unless match
      raise "Couldn't find this line:\n#{line}\nin:\n#{text}"
    end
  end

  def line_matching(text, regexp)
    lines = text.split(/[\r\n]+/)
    match = lines.detect { |l| l =~ regexp }
    unless match
      raise "Couldn't find this regexp:\n#{regexp}\nin:\n#{text}"
    end
    match
  end

  it "should return the right values for many methods" do
    wc = widget_class do
      needs :foo, :bar, :baz => nil

      def content
        text "keys: #{assigns.keys.sort.inspect}\n"
        text "has_key?(:baz): #{assigns.has_key?(:baz).inspect}\n"
        text "has_key?(:quux): #{assigns.has_key?(:quux).inspect}\n"
        text "[](:foo): #{assigns[:foo]}\n"
        text "[](:baz): #{assigns[:baz]}\n"
        text "[](:quux): #{assigns[:quux]}\n"
        text "to_hash: #{assigns.to_hash}\n".html_safe
        text "to_h: #{assigns.to_hash}\n".html_safe
        text "length: #{assigns.length}\n"
        text "size: #{assigns.size}\n"
        text "to_s: #{assigns.to_s}\n".html_safe
        text "inspect: #{assigns.inspect}\n".html_safe
        text "member?(:foo): #{assigns.member?(:foo)}\n"
        text "member?(:baz): #{assigns.member?(:baz)}\n"
        text "member?(:quux): #{assigns.member?(:quux)}\n"

        text "store(:baz, 12345): #{assigns.store(:baz, 12345)}\n"
        text "new [](:baz): #{assigns[:baz]}\n"
      end
    end

    widget = wc.new(:foo => 'the_foo', :bar => 'the_bar')
    text = render(widget)
    should_have_line(text, "keys: [:bar, :baz, :foo]")
    should_have_line(text, "has_key?(:baz): true")
    should_have_line(text, "has_key?(:quux): false")
    should_have_line(text, "[](:foo): the_foo")
    should_have_line(text, "[](:baz): ")
    should_have_line(text, "[](:quux): ")

    hash_line = line_matching(text, /^to_hash: (.*)/)
    hash_line =~ /^to_hash: (.*)/
    hash_text = $1
    as_hash = eval(hash_text)
    expect(as_hash).to eq({ :foo => 'the_foo', :bar => 'the_bar', :baz => nil })

    should_have_line(text, "to_h: #{hash_text}")
    should_have_line(text, "length: 3")
    should_have_line(text, "size: 3")

    to_s_line = line_matching(text, /^to_s: (.*)/)
    expect(to_s_line).to match(/Assigns for #{widget}/)
    expect(to_s_line).to match(/:foo\s*\=\>\s*["']the_foo["']/)
    expect(to_s_line).to match(/:bar\s*\=\>\s*["']the_bar["']/)
    expect(to_s_line).to match(/:baz\s*\=\>\s*nil/)

    inspect_line = line_matching(text, /^inspect: (.*)/)
    expect(inspect_line).to match(/Assigns for #{widget}/)
    expect(inspect_line).to match(/:foo\s*\=\>\s*["']the_foo["']/)
    expect(inspect_line).to match(/:bar\s*\=\>\s*["']the_bar["']/)
    expect(inspect_line).to match(/:baz\s*\=\>\s*nil/)

    should_have_line(text, "member?(:foo): true")
    should_have_line(text, "member?(:baz): true")
    should_have_line(text, "member?(:quux): false")
    should_have_line(text, "store(:baz, 12345): 12345")
    should_have_line(text, "new [](:baz): 12345")
  end

  # We currently don't have a test for the massive number of automatically-delegated methods on the AssignsProxy;
  # writing one would be long and tedious, frankly, and the chance that we're going to find a bug in there is close
  # to zero. If you feel we should have one, though, feel free to contribute one. ;)
end
