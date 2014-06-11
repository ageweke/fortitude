describe "Fortitude doctype support", :type => :system do
  def wc(*args, &block)
    widget_class({ :superclass => Fortitude::Widget }.merge(args[-1] || { }), &block)
  end

  def wc_with_doctype(dt, *args, &block)
    out = wc(*args, &block)
    out.doctype(dt)
    out
  end

  def allows_dir?(doctype)
    widget_class = wc_with_doctype(doctype)
    widget_class.class_eval do
      def content
        dir do
          li "hi"
        end
      end
    end

    begin
      render(widget_class)
      true
    rescue NoMethodError => nme
      false
    end
  end

  it "should autoload specific widgets" do
    expect(Fortitude::Widgets::Html5).to be
    expect(Fortitude::Widget::Html4Strict).to be
    expect(Fortitude::Widget::Html4Transitional).to be
    expect(Fortitude::Widget::Html4Frameset).to be
    expect(Fortitude::Widget::Xhtml10Strict).to be
    expect(Fortitude::Widget::Xhtml10Transitional).to be
    expect(Fortitude::Widget::Xhtml10Frameset).to be
    expect(Fortitude::Widget::Xhtml11).to be
  end

  before :all do
    @classes_by_doctype = { }
  end

  EXPECTED_RESULTS = {
    :html5 => {
      :allows_dir  => false, :allows_background => false, :allows_frame => false, :closes_void_tags => false,
      :doctype_line => '<!DOCTYPE html>',
      :javascript => :none
    },

    :html4_strict => {
      :allows_dir  => false, :allows_background => false, :allows_frame => false, :closes_void_tags => false,
      :doctype_line => '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">',
      :javascript => :type
    },

    :html4_transitional => {
      :allows_dir  => true, :allows_background => true, :allows_frame => false, :closes_void_tags => false,
      :doctype_line => '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">',
      :javascript => :type
    },

    :html4_frameset => {
      :allows_dir  => true, :allows_background => true, :allows_frame => true, :closes_void_tags => false,
      :doctype_line => '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">',
      :javascript => :type
    },

    :xhtml10_strict => {
      :allows_dir  => false, :allows_background => false, :allows_frame => false, :closes_void_tags => true,
      :doctype_line => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">',
      :javascript => :type_and_cdata
    },

    :xhtml10_transitional => {
      :allows_dir  => true, :allows_background => true, :allows_frame => false, :closes_void_tags => true,
      :doctype_line => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">',
      :javascript => :type_and_cdata
    },

    :xhtml10_frameset => {
      :allows_dir  => true, :allows_background => true, :allows_frame => true, :closes_void_tags => true,
      :doctype_line => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">',
      :javascript => :type_and_cdata
    },

    :xhtml11 => {
      :allows_dir  => false, :allows_background => false, :allows_frame => false, :closes_void_tags => true,
      :doctype_line => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">',
      :javascript => :type_and_cdata
    }
  }.each do |doctype, expected_results|
    describe doctype do
      let(:the_widget_class) {
        @classes_by_doctype[doctype] ||= wc_with_doctype(doctype)
      }

      it "should #{expected_results[:allows_dir] ? "" : "not "}allow <dir>" do
        the_widget_class.class_eval do
          def content
            dir do
              li "hi"
            end
          end
        end

        if expected_results[:allows_dir]
          expect(render(the_widget_class)).to eq("<dir><li>hi</li></dir>")
        else
          expect { render(the_widget_class) }.to raise_error(NoMethodError, /dir/i)
        end
      end

      it "should #{expected_results[:allows_background ? "" : "not "]}allow <body background=\"...\">" do
        the_widget_class.class_eval do
          enforce_attribute_rules true

          def content
            body :background => 'red' do
              p "hi"
            end
          end
        end

        if expected_results[:allows_background]
          expect(render(the_widget_class)).to eq("<body background=\"red\"><p>hi</p></body>")
        else
          expect { render(the_widget_class) }.to raise_error(Fortitude::Errors::InvalidElementAttributes)
        end
      end

      it "should #{expected_results[:allows_frame] ? "" : "not "} allow <frame>" do
        the_widget_class.class_eval do
          def content
            frame :src => 'http://www.google.com/'
          end
        end

        if expected_results[:allows_frame]
          expect(render(the_widget_class)).to match(%r{<frame src="http://www.google.com/"/?>})
        else
          expect { render(the_widget_class) }.to raise_error(NoMethodError, /frame/i)
        end
      end

      it "should #{expected_results[:closes_void_tags] ? "": "not "}close void tags" do
        the_widget_class.class_eval do
          def content
            br
          end
        end

        if expected_results[:closes_void_tags]
          expect(render(the_widget_class)).to eq("<br/>")
        else
          expect(render(the_widget_class)).to eq("<br>")
        end
      end

      it "should output the correct DOCTYPE line" do
        the_widget_class.class_eval do
          def content
            doctype!
          end
        end

        expect(render(the_widget_class)).to eq(expected_results[:doctype_line])
      end

      it "should not escape content inside <script>" do
        the_widget_class.class_eval do
          def content
            script "foo < bar > baz & quux"
          end
        end

        expect(render(the_widget_class)).to eq("<script>foo < bar > baz & quux</script>")
      end

      it "should not escape content inside <style>" do
        the_widget_class.class_eval do
          def content
            style "foo < bar > baz & quux"
          end
        end

        expect(render(the_widget_class)).to eq("<style>foo < bar > baz & quux</style>")
      end

      it "should output the correct tags for the #javascript method" do
        the_widget_class.class_eval do
          def content
            javascript "hi"
          end
        end

        expected_output = case expected_results[:javascript]
        when :type_and_cdata then %{<script type="text/javascript">
//<![CDATA[
hi
//]]>
</script>}
        when :type then %{<script type="text/javascript">hi</script>}
        when :none then %{<script>hi</script>}
        else raise "Unknown expected result for :javascript: #{expected_results[:javascript].inspect}"
        end

        expect(render(the_widget_class)).to eq(expected_output)
      end
    end
  end
end
