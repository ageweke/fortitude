describe "Fortitude doctype support", :type => :system do
  def wc(*args, &block)
    widget_class({ :superclass => Fortitude::Widget }.merge(args[-1] || { }), &block)
  end

  def wc_with_doctype(dt, *args, &block)
    out = wc(*args, &block)
    out.doctype(dt)
    out
  end

  describe "#doctype! method" do
    it "should output the correct declaration" do
      expect(render(wc_with_doctype(:html5) { def content; doctype!; end })).to eq("<!DOCTYPE html>")
    end
  end
end

=begin
      should_render_to("<!DOCTYPE html>") { doctype :html5 }
      should_render_to('<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">') { doctype :html4_strict }
      should_render_to('<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">') { doctype :html4_transitional }
      should_render_to('<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">') { doctype :html4_frameset }
      should_render_to('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">') { doctype :xhtml1_strict }
      should_render_to('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">') { doctype :xhtml1_transitional }
      should_render_to('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">') { doctype :xhtml1_frameset }
      should_render_to('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">') { doctype :xhtml11 }
=end
