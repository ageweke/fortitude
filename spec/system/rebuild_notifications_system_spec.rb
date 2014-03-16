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

  describe "needs" do
    it "should fire a notification when rebuilding because a need was declared" do
      @wc.needs :foo
      expect_notification(:what => :needs, :why => :need_declared)
      expect_no_more_notifications!(:needs)

      @wc.needs :bar => :baz
      expect_notification(:what => :needs, :why => :need_declared)
      expect_no_more_notifications!(:needs)
    end

    it "should fire a notification when rebuilding because extra_assigns was changed" do
      @wc.extra_assigns :use
      expect_notification(:what => :needs, :why => :extra_assigns_changed)
      expect_no_more_notifications!(:needs)

      @wc.extra_assigns :error
      expect_notification(:what => :needs, :why => :extra_assigns_changed)
      expect_no_more_notifications!(:needs)
    end

    it "should fire a notification when rebuilding because use_instance_variables_for_assigns was changed" do
      @wc.use_instance_variables_for_assigns true
      expect_notification(:what => :needs, :why => :use_instance_variables_for_assigns_changed)
      expect_no_more_notifications!(:needs)

      @wc.use_instance_variables_for_assigns false
      expect_notification(:what => :needs, :why => :use_instance_variables_for_assigns_changed)
      expect_no_more_notifications!(:needs)
    end
  end

  describe "run_content" do
    it "should fire a notification when rebuilding because an around_content filter was added" do
      @wc.around_content :around1
      expect_notification(:what => :run_content, :why => :around_content_added)
      expect_no_more_notifications!(:run_content)

      @wc.around_content :around2
      expect_notification(:what => :run_content, :why => :around_content_added)
      expect_no_more_notifications!(:run_content)
    end

    it "should fire a notification when rebuilding because an around_content filter was removed" do
      @wc.around_content :around1
      expect_notification(:what => :run_content, :why => :around_content_added)
      expect_no_more_notifications!(:run_content)

      @wc.remove_around_content :around1
      expect_notification(:what => :run_content, :why => :around_content_removed)
      expect_no_more_notifications!(:run_content)
    end

    it "should fire a notification when rebuilding because a localized content method was added" do
      @wc.class_eval do
        def localized_content_en
          text "foo"
        end
      end
      expect_notification(:what => :run_content, :why => :localized_methods_presence_changed)
      expect_no_more_notifications!(:run_content)

      @wc.send(:remove_method, :localized_content_en)
      expect_notification(:what => :run_content, :why => :localized_methods_presence_changed)
      expect_no_more_notifications!(:run_content)
    end
  end

  describe "tag_methods" do
    it "should fire a notification when rebuilding because a tag was added" do
      @wc.tag :foo
      expect_notification(:what => :tag_methods, :why => :tags_declared)
      expect_no_more_notifications!(:tag_methods)
    end

    it "should fire a notification when rebuilding because format_output has changed" do
      @wc.format_output true
      expect_notification(:what => :tag_methods, :why => :format_output_changed)
      expect_no_more_notifications!(:tag_methods)

      @wc.format_output false
      expect_notification(:what => :tag_methods, :why => :format_output_changed)
      expect_no_more_notifications!(:tag_methods)
    end

    it "should fire a notification when rebuilding because enforce_element_nesting_rules has changed" do
      @wc.enforce_element_nesting_rules true
      expect_notification(:what => :tag_methods, :why => :enforce_element_nesting_rules_changed)
      expect_no_more_notifications!(:tag_methods)

      @wc.enforce_element_nesting_rules false
      expect_notification(:what => :tag_methods, :why => :enforce_element_nesting_rules_changed)
      expect_no_more_notifications!(:tag_methods)
    end

    it "should fire a notification when rebuilding because enforce_attribute_rules has changed" do
      @wc.enforce_attribute_rules true
      expect_notification(:what => :tag_methods, :why => :enforce_attribute_rules_changed)
      expect_no_more_notifications!(:tag_methods)

      @wc.enforce_attribute_rules false
      expect_notification(:what => :tag_methods, :why => :enforce_attribute_rules_changed)
      expect_no_more_notifications!(:tag_methods)
    end

    it "should fire a notification when rebuilding because enforce_id_uniqueness has changed" do
      @wc.enforce_id_uniqueness true
      expect_notification(:what => :tag_methods, :why => :enforce_id_uniqueness_changed)
      expect_no_more_notifications!(:tag_methods)

      @wc.enforce_id_uniqueness false
      expect_notification(:what => :tag_methods, :why => :enforce_id_uniqueness_changed)
      expect_no_more_notifications!(:tag_methods)
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

    it "should fire with the right class for needs" do
      @wc_subclass.extra_assigns :use
      expect_notification(:what => :needs, :why => :extra_assigns_changed, :class => @wc_subclass, :originating_class => @wc_subclass)
      expect_no_more_notifications!(:needs)

      @wc.extra_assigns :error
      expect_notification(:what => :needs, :why => :extra_assigns_changed, :class => @wc, :originating_class => @wc)
      expect_notification(:what => :needs, :why => :extra_assigns_changed, :class => @wc_subclass, :originating_class => @wc)
      expect_no_more_notifications!(:needs)
    end

    it "should fire with the right class for run_content" do
      @wc_subclass.around_content :around1
      expect_notification(:what => :run_content, :why => :around_content_added, :class => @wc_subclass, :originating_class => @wc_subclass)
      expect_no_more_notifications!(:run_content)

      @wc.around_content :around2
      expect_notification(:what => :run_content, :why => :around_content_added, :class => @wc, :originating_class => @wc)
      expect_notification(:what => :run_content, :why => :around_content_added, :class => @wc_subclass, :originating_class => @wc)
      expect_no_more_notifications!(:run_content)
    end

    it "should fire with the right class for tag_methods" do
      @wc_subclass.format_output true
      expect_notification(:what => :tag_methods, :why => :format_output_changed, :class => @wc_subclass, :originating_class => @wc_subclass)
      expect_no_more_notifications!(:tag_methods)

      @wc.format_output true
      expect_notification(:what => :tag_methods, :why => :format_output_changed, :class => @wc, :originating_class => @wc)
      expect_notification(:what => :tag_methods, :why => :format_output_changed, :class => @wc_subclass, :originating_class => @wc)
      expect_no_more_notifications!(:tag_methods)
    end
  end
end
