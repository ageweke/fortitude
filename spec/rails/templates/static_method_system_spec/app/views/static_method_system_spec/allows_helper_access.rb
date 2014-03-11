class Views::StaticMethodSystemSpec::AllowsHelperAccess < Fortitude::Widget
  def content
    text "foo is: #{foo('aaa')}"
    bar('bbb')
  end

  static :content, :helpers_object => (lambda do |widget|
    out = ActionView::Base.new.extend(StaticMethodSystemSpecController._helpers)
    class << out
      attr_accessor :widget

      def output_buffer
        widget.output_buffer
      end
    end
    out.widget = widget
    out
  end)
end
