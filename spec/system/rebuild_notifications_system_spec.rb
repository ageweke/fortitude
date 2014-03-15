describe "Fortitude rebuilding notifications", :type => :system do
  before :each do
    @notifications = [ ]
    n = @notifications
    ActiveSupport::Notifications.subscribe("fortitude.rebuilding") do |*args|
      n << args
    end

    @wc = widget_class
  end

  def expect_notification(expected_payload)
    expected_payload = { :class => @wc, :originating_class => @wc }.merge(expected_payload)
    notification = @notifications.detect do |(name, start, finish, id, payload)|
      payload == expected_payload
    end
    raise "Can't find notification with payload #{expected_payload.inspect}; have: #{@notifications.inspect}" unless notification
    @notifications.delete(notification)
  end

  def expect_no_more_notifications!(what = nil)
    remaining = @notifications
    remaining = remaining.select { |n| n[4][:what] == what } if what

    if remaining.length > 0
      raise "Had more notifications that we didn't expect: #{remaining.inspect}"
    end
  end

  describe "text methods" do
    it "should fire a notification when rebuilding because format_output has changed" do
      @wc.format_output true
      expect_notification(:what => :text_methods, :why => :format_output_changed)
      expect_no_more_notifications!(:text_methods)

      @wc.format_output false
      expect_notification(:what => :text_methods, :why => :format_output_changed)
      expect_no_more_notifications!(:text_methods)
    end
  end

  describe "with a subclass" do
    before :each do
      @wc = widget_class
      @wc_subclass = widget_class(:superclass => @wc)
    end

    it "should fire with the right class for text methods" do
      @wc_subclass.format_output true
      expect_notification(:what => :text_methods, :why => :format_output_changed, :class => @wc_subclass, :originating_class => @wc_subclass)
      expect_no_more_notifications!(:text_methods)

      @wc.format_output true
      expect_notification(:what => :text_methods, :why => :format_output_changed, :class => @wc, :originating_class => @wc)
      expect_notification(:what => :text_methods, :why => :format_output_changed, :class => @wc_subclass, :originating_class => @wc)
      expect_no_more_notifications!(:text_methods)
    end
  end
end
