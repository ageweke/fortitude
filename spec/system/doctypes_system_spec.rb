describe "Fortitude doctype support", :type => :system do
  def wc(*args, &block)
    widget_class({ :superclass => Fortitude::Widget::Base }.merge(args[-1] || { }), &block)
  end

  def wc_with_doctype(dt, *args, &block)
    out = wc(*args, &block)
    out.doctype(dt)
    out
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
