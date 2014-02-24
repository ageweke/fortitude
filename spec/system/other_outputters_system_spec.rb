describe "Fortitude other outputting methods", :type => :system do
  def r(&block)
    render(widget_class_with_content(&block))
  end

  def should_render_to(value, &block)
    expect(r(&block)).to eq(value)
  end

  describe "comments" do
    it "should render a simple comment" do
      should_render_to("<!-- foo -->") { comment "foo" }
    end

    it "should escape anything potentially comment-ending in a comment" do
      [ "fo --> oo", "fo -- oo", "fo --", "--", "-----", "---", " -- ", "-- ", " --", "- -",
        ">", " > ", ">>", "-->" ].each do |string|
        text = render(widget_class_with_content { comment string })
        if text =~ /^<!--(.*)-->$/
          contents = $1
        else
          raise "Not a comment?!? #{text.inspect}"
        end

        # From http://www.w3.org/TR/html5/syntax.html#comments:
        #
        # Comments must start with the four character sequence U+003C LESS-THAN SIGN, U+0021 EXCLAMATION MARK,
        # U+002D HYPHEN-MINUS, U+002D HYPHEN-MINUS (<!--). Following this sequence, the comment may have text,
        # with the additional restriction that the text must not start with a single ">" (U+003E) character,
        # nor start with a U+002D HYPHEN-MINUS character (-) followed by a ">" (U+003E) character, nor contain
        # two consecutive U+002D HYPHEN-MINUS characters (--), nor end with a U+002D HYPHEN-MINUS character (-).
        # Finally, the comment must be ended by the three character sequence U+002D HYPHEN-MINUS, U+002D HYPHEN-MINUS,
        # U+003E GREATER-THAN SIGN (-->).
        expect(contents).not_to match(/\-\-/)
        expect(contents).not_to match(/^\s*>/)
        expect(contents).not_to match(/^\s*\->/)
        expect(contents).not_to match(/>$/)
      end
    end

    it "should not escape standard HTML escape characters inside a comment" do
      expect(render(widget_class_with_content { comment 'mind your "p"s & "q"s' })).to eq('<!-- mind your "p"s & "q"s -->')
      expect(render(widget_class_with_content { comment 'is 3 < 4, or is 4 > 3?' })).to eq('<!-- is 3 < 4, or is 4 > 3? -->')
    end

    it "should not allow passing a block" do
      expect { render { comment { text "hi" } } }.to raise_error(ArgumentError)
    end

    it "should put comments on their own lines if we're formatting output, and indent them properly" do
      wc = widget_class do
        format_output true

        def content
          div do
            text "this is really cool"
            comment "isn't it?"
            text "man?"
          end
        end
      end

      expect(render(wc)).to eq(%{<div>
  this is really cool
  <!-- isn't it? -->
  man?
</div>})
    end
  end

  describe "cdata" do
    it "should output data inside CDATA" do
      wc = widget_class_with_content { cdata "hi there" }
      expect(render(wc)).to eq(%{<![CDATA[hi there]]>})
    end

    it "should properly split up a CDATA section if necessary" do
      wc = widget_class_with_content { cdata "this contains a ]]> cdata end in it" }
      expect(render(wc)).to eq(%{<![CDATA[this contains a ]]]]><![CDATA[> cdata end in it]]>})
    end

    it "should properly split up a CDATA section into several pieces if necessary" do
      wc = widget_class_with_content { cdata "this contains a ]]> cdata end in it and ]]> again" }
      expect(render(wc)).to eq(%{<![CDATA[this contains a ]]]]><![CDATA[> cdata end in it and ]]]]><![CDATA[> again]]>})
    end

    it "should not indent CDATA contents or ending, even if we're formatting output" do
      wc = widget_class do
        format_output true

        def content
          div do
            div do
              cdata %{hi
there
man}
            end
          end
        end
      end

      expect(render(wc)).to eq(%{<div>
  <div>
    <![CDATA[hi
there
man]]>
  </div>
</div>})
    end
  end

  describe "doctype" do
    it "should output a doctype of any string if asked" do
      should_render_to("<!DOCTYPE foobar>") { doctype 'foobar' }
    end

    it "should output well-known doctypes" do
      should_render_to("<!DOCTYPE html>") { doctype :html5 }
      should_render_to('<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">') { doctype :html4_strict }
      should_render_to('<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">') { doctype :html4_transitional }
      should_render_to('<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">') { doctype :html4_frameset }
      should_render_to('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">') { doctype :xhtml1_strict }
      should_render_to('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">') { doctype :xhtml1_transitional }
      should_render_to('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">') { doctype :xhtml1_frameset }
      should_render_to('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">') { doctype :xhtml11 }
    end

    it "should fail if passed an unknown symbol" do
      expect { render(widget_class_with_content { doctype :foo }) }.to raise_error(ArgumentError)
    end

    it "should fail if passed nil" do
      expect { render(widget_class_with_content { doctype :foo }) }.to raise_error(ArgumentError)
    end
  end
end
