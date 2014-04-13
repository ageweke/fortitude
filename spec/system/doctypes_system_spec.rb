describe "Fortitude doctype support", :type => :system do
  def wc(*args, &block)
    widget_class({ :superclass => Fortitude::Widget::Base }.merge(args[-1] || { }), &block)
  end

  def wc_with_doctype(dt, *args, &block)
    out = wc(*args, &block)
    out.doctype(dt)
    out
  end

  describe "HTML4 Strict" do
    it "should not allow <dir>" do
      widget_class = wc_with_doctype(:html4_strict)
      widget_class.class_eval do
        def content
          dir do
            li "hi"
          end
        end
      end

      expect { render(widget_class) }.to raise_error(NoMethodError, /dir/i)
    end

    it "should not allow 'background' on :body" do
      widget_class = wc_with_doctype(:html4_strict)
      widget_class.class_eval do
        enforce_attribute_rules true

        def content
          body :background => 'red' do
            p "hi"
          end
        end
      end

      expect { render(widget_class) }.to raise_error(Fortitude::Errors::InvalidElementAttributes)
    end

    it "should not allow <frame>" do
      widget_class = wc_with_doctype(:html4_strict)
      widget_class.class_eval do
        def content
          frame :src => 'http://www.google.com/'
        end
      end

      expect { render(widget_class) }.to raise_error(NoMethodError, /frame/i)
    end
  end

  describe "HTML4 Transitional" do
    it "should allow <dir>" do
      widget_class = wc_with_doctype(:html4_transitional)
      widget_class.class_eval do
        def content
          dir do
            li "hi"
          end
        end
      end

      expect(render(widget_class)).to eq("<dir><li>hi</li></dir>")
    end

    it "should allow 'background' on :body" do
      widget_class = wc_with_doctype(:html4_transitional)
      widget_class.class_eval do
        enforce_attribute_rules true

        def content
          body :background => 'red' do
            p "hi"
          end
        end
      end

      expect(render(widget_class)).to eq("<body background=\"red\"><p>hi</p></body>")
    end

    it "should not allow <frame>" do
      widget_class = wc_with_doctype(:html4_transitional)
      widget_class.class_eval do
        def content
          frame :src => 'http://www.google.com/'
        end
      end

      expect { render(widget_class) }.to raise_error(NoMethodError, /frame/i)
    end
  end

  describe "HTML4 Frameset" do
    it "should allow <dir>" do
      widget_class = wc_with_doctype(:html4_frameset)
      widget_class.class_eval do
        def content
          dir do
            li "hi"
          end
        end
      end

      expect(render(widget_class)).to eq("<dir><li>hi</li></dir>")
    end

    it "should allow 'background' on :body" do
      widget_class = wc_with_doctype(:html4_frameset)
      widget_class.class_eval do
        enforce_attribute_rules true

        def content
          body :background => 'red' do
            p "hi"
          end
        end
      end

      expect(render(widget_class)).to eq("<body background=\"red\"><p>hi</p></body>")
    end

    it "should allow <frame>" do
      widget_class = wc_with_doctype(:html4_frameset)
      widget_class.class_eval do
        def content
          frame :src => 'http://www.google.com/'
        end
      end

      expect(render(widget_class)).to eq("<frame src=\"http://www.google.com/\"/>")
    end
  end

  describe "XHTML1.0 Strict" do
    it "should not allow <dir>" do
      widget_class = wc_with_doctype(:xhtml10_strict)
      widget_class.class_eval do
        def content
          dir do
            li "hi"
          end
        end
      end

      expect { render(widget_class) }.to raise_error(NoMethodError, /dir/i)
    end

    it "should not allow 'background' on :body" do
      widget_class = wc_with_doctype(:xhtml10_strict)
      widget_class.class_eval do
        enforce_attribute_rules true

        def content
          body :background => 'red' do
            p "hi"
          end
        end
      end

      expect { render(widget_class) }.to raise_error(Fortitude::Errors::InvalidElementAttributes)
    end

    it "should not allow <frame>" do
      widget_class = wc_with_doctype(:xhtml10_strict)
      widget_class.class_eval do
        def content
          frame :src => 'http://www.google.com/'
        end
      end

      expect { render(widget_class) }.to raise_error(NoMethodError, /frame/i)
    end
  end

  describe "XHTML1.0 Transitional" do
    it "should allow <dir>" do
      widget_class = wc_with_doctype(:xhtml10_transitional)
      widget_class.class_eval do
        def content
          dir do
            li "hi"
          end
        end
      end

      expect(render(widget_class)).to eq("<dir><li>hi</li></dir>")
    end

    it "should allow 'background' on :body" do
      widget_class = wc_with_doctype(:xhtml10_transitional)
      widget_class.class_eval do
        enforce_attribute_rules true

        def content
          body :background => 'red' do
            p "hi"
          end
        end
      end

      expect(render(widget_class)).to eq("<body background=\"red\"><p>hi</p></body>")
    end

    it "should not allow <frame>" do
      widget_class = wc_with_doctype(:xhtml10_transitional)
      widget_class.class_eval do
        def content
          frame :src => 'http://www.google.com/'
        end
      end

      expect { render(widget_class) }.to raise_error(NoMethodError, /frame/i)
    end
  end

  describe "XHTML1.0 Frameset" do
    it "should allow <dir>" do
      widget_class = wc_with_doctype(:xhtml10_frameset)
      widget_class.class_eval do
        def content
          dir do
            li "hi"
          end
        end
      end

      expect(render(widget_class)).to eq("<dir><li>hi</li></dir>")
    end

    it "should allow 'background' on :body" do
      widget_class = wc_with_doctype(:xhtml10_frameset)
      widget_class.class_eval do
        enforce_attribute_rules true

        def content
          body :background => 'red' do
            p "hi"
          end
        end
      end

      expect(render(widget_class)).to eq("<body background=\"red\"><p>hi</p></body>")
    end

    it "should allow <frame>" do
      widget_class = wc_with_doctype(:xhtml10_frameset)
      widget_class.class_eval do
        def content
          frame :src => 'http://www.google.com/'
        end
      end

      expect(render(widget_class)).to eq("<frame src=\"http://www.google.com/\"/>")
    end
  end

  describe "XHTML1.1" do
    it "should not allow <dir>" do
      widget_class = wc_with_doctype(:xhtml11)
      widget_class.class_eval do
        def content
          dir do
            li "hi"
          end
        end
      end

      expect { render(widget_class) }.to raise_error(NoMethodError, /dir/i)
    end

    it "should not allow 'background' on :body" do
      widget_class = wc_with_doctype(:xhtml11)
      widget_class.class_eval do
        enforce_attribute_rules true

        def content
          body :background => 'red' do
            p "hi"
          end
        end
      end

      expect { render(widget_class) }.to raise_error(Fortitude::Errors::InvalidElementAttributes)
    end

    it "should not allow <frame>" do
      widget_class = wc_with_doctype(:xhtml11)
      widget_class.class_eval do
        def content
          frame :src => 'http://www.google.com/'
        end
      end

      expect { render(widget_class) }.to raise_error(NoMethodError, /frame/i)
    end
  end

  describe "#doctype! method" do
    {
      :html5 => "<!DOCTYPE html>",
      :html4_strict => '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">',
      :html4_transitional => '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">',
      :html4_frameset => '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">',
      :xhtml10_strict => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">',
      :xhtml10_transitional => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">',
      :xhtml10_frameset => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">',
      :xhtml11 => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">'
    }.each do |doctype, expected_declaration|
      it "should output the correct declaration for #{doctype}" do
        expect(render(wc_with_doctype(doctype) { def content; doctype!; end })).to eq(expected_declaration)
      end
    end
  end

  describe "javascript tag" do
    it "should generate <script> with no CDATA for :html5" do
      wc = wc_with_doctype(:html5) { def content; javascript "hello"; end }
      expect(render(wc)).to eq("<script>hello</script>")
    end

    it "should generate <script type=\"text/javascript\"> with no CDATA for all :html4 doctypes" do
      [ :html4_strict, :html4_transitional, :html4_frameset ].each do |doctype|
        wc = wc_with_doctype(doctype) { def content; javascript "hello"; end }
        expect(render(wc)).to eq("<script type=\"text/javascript\">hello</script>")
      end
    end

    it "should generate <script type=\"text/javascript\"> with CDATA for all :xhtml doctypes" do
      [ :xhtml10_strict, :xhtml10_transitional, :xhtml10_frameset, :xhtml11 ].each do |doctype|
        wc = wc_with_doctype(doctype) { def content; javascript "hello"; end }
        expect(render(wc)).to eq(%{<script type=\"text/javascript\">
//<![CDATA[
hello
//]]>
</script>})
      end
    end
  end
end
