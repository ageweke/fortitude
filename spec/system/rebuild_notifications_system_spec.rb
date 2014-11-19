describe "Fortitude rebuilding notifications", :type => :system do
  before :each do
    @rebuild_notifications = [ ]
    rbn = @rebuild_notifications
    ActiveSupport::Notifications.subscribe("fortitude.rebuilding") do |name, start, finish, id, payload|
      if payload[:what] == :needs && [ ::Fortitude::Widget, ::SystemHelpers::TestWidgetClass ].include?(payload[:class])
        # So, here's the deal: needs get rebuilt on ::Fortitude::Widget and ::SystemHelpers::TestWidgetClass by
        # whatever example in this file is the *first* one to actually instantiate a widget, and then not past that
        # point, since we never change anything need-related on either of those classes. (Which is really important,
        # or we'd reconfigure Fortitude internally for *all other specs*.)
        #
        # As a result, it's much simpler and more reliable to simply ignore these notifications than try to keep track
        # of which is the first spec to cause these to be rebuilt. Specs below do check things like superclass-subclass
        # needs invalidation, so we're good there too.
      else
        rbn << [ name, start, finish, id, payload ]
      end
    end

    @invalidating_notifications = [ ]
    ivn = @invalidating_notifications
    ActiveSupport::Notifications.subscribe("fortitude.invalidating") do |name, start, finish, id, payload|
      ivn << [ name, start, finish, id, payload ]
    end

    @wc = widget_class
  end

  def expect_rebuild_notification(expected_payload)
    expected_payload = { :class => @wc, :originating_class => @wc }.merge(expected_payload)
    notification = @rebuild_notifications.detect do |(name, start, finish, id, payload)|
      payload == expected_payload
    end
    raise "Can't find rebuild notification with payload #{expected_payload.inspect}; have: #{@rebuild_notifications.inspect} (invalidating: #{@invalidating_notifications.inspect})" unless notification
    @rebuild_notifications.delete(notification)
  end

  def expect_no_more_rebuild_notifications!(what = nil)
    remaining = @rebuild_notifications
    remaining = remaining.select { |n| n[4][:what] == what } if what

    if remaining.length > 0
      raise "Had more rebuild notifications that we didn't expect: #{remaining.inspect}"
    end
  end

  def expect_invalidating_notification(expected_payload)
    expected_payload = { :class => @wc, :originating_class => @wc }.merge(expected_payload)
    notification = @invalidating_notifications.detect do |(name, start, finish, id, payload)|
      payload == expected_payload
    end
    raise "Can't find invalidating notification with payload #{expected_payload.inspect}; have: #{@invalidating_notifications.inspect} (rebuilding: #{@rebuild_notifications.inspect})" unless notification
    @invalidating_notifications.delete(notification)
  end

  def expect_no_more_invalidating_notifications!(what = nil)
    remaining = @invalidating_notifications
    remaining = remaining.select { |n| n[4][:what] == what } if what

    if remaining.length > 0
      raise "Had more invalidating notifications that we didn't expect: #{remaining.inspect}"
    end
  end

  describe "text methods" do
    it "should fire a notification when rebuilding because format_output has changed" do
      @wc.format_output true
      expect_rebuild_notification(:what => :text_methods, :why => :format_output_changed)
      expect_no_more_rebuild_notifications!(:text_methods)

      @wc.format_output false
      expect_rebuild_notification(:what => :text_methods, :why => :format_output_changed)
      expect_no_more_rebuild_notifications!(:text_methods)
    end
  end

  describe "needs" do
    it "should fire an notification when invalidating because a need was declared" do
      @wc.needs :foo
      expect_invalidating_notification(:what => :needs, :why => :need_declared)
      expect_no_more_invalidating_notifications!(:needs)

      @wc.needs :bar => :baz
      expect_invalidating_notification(:what => :needs, :why => :need_declared)
      expect_no_more_invalidating_notifications!(:needs)
    end

    it "should fire a notification when invalidating because extra_assigns was changed" do
      @wc.extra_assigns :use
      expect_invalidating_notification(:what => :needs, :why => :extra_assigns_changed)
      expect_no_more_invalidating_notifications!(:needs)

      @wc.extra_assigns :error
      expect_invalidating_notification(:what => :needs, :why => :extra_assigns_changed)
      expect_no_more_invalidating_notifications!(:needs)
    end

    it "should fire a notification when invalidating because use_instance_variables_for_assigns was changed" do
      @wc.use_instance_variables_for_assigns true
      expect_invalidating_notification(:what => :needs, :why => :use_instance_variables_for_assigns_changed)
      expect_no_more_invalidating_notifications!(:needs)

      @wc.use_instance_variables_for_assigns false
      expect_invalidating_notification(:what => :needs, :why => :use_instance_variables_for_assigns_changed)
      expect_no_more_invalidating_notifications!(:needs)
    end

    it "should only rebuild needs when a widget is actually instantiated" do
      expect_no_more_invalidating_notifications!(:needs)
      expect_no_more_rebuild_notifications!(:needs)

      @wc.new

      expect_no_more_invalidating_notifications!(:needs)
      expect_rebuild_notification(:what => :needs, :why => :invalid, :class => @wc, :originating_class => @wc)
      expect_no_more_rebuild_notifications!(:needs)
    end

    it "should only rebuild needs when a widget is actually instantiated the first time" do
      expect_no_more_invalidating_notifications!(:needs)
      expect_no_more_rebuild_notifications!(:needs)

      @wc.new

      expect_no_more_invalidating_notifications!(:needs)
      expect_rebuild_notification(:what => :needs, :why => :invalid, :class => @wc, :originating_class => @wc)
      expect_no_more_rebuild_notifications!(:needs)

      @wc.new
      expect_no_more_invalidating_notifications!(:needs)
      expect_no_more_rebuild_notifications!(:needs)
    end

    it "should invalidate multiple times, but not rebuild more than once if multiple things are changed" do
      @wc.new

      expect_no_more_invalidating_notifications!(:needs)
      expect_rebuild_notification(:what => :needs, :why => :invalid, :class => @wc, :originating_class => @wc)
      expect_no_more_rebuild_notifications!(:needs)

      @wc.needs :foobar
      @wc.use_instance_variables_for_assigns true

      expect_invalidating_notification(:what => :needs, :why => :need_declared, :class => @wc, :originating_class => @wc)
      expect_invalidating_notification(:what => :needs, :why => :use_instance_variables_for_assigns_changed, :class => @wc, :originating_class => @wc)
      expect_no_more_invalidating_notifications!(:needs)
    end

    it "should rebuild on both parent and child classes when a parent class is modified" do
      wc_child = widget_class(:superclass => @wc)

      expect_no_more_invalidating_notifications!(:needs)
      expect_no_more_rebuild_notifications!(:needs)

      @wc.needs :foobar

      expect_invalidating_notification(:what => :needs, :why => :need_declared, :class => @wc, :originating_class => @wc)
      expect_invalidating_notification(:what => :needs, :why => :need_declared, :class => wc_child, :originating_class => @wc)
      expect_no_more_invalidating_notifications!(:needs)
      expect_no_more_rebuild_notifications!(:needs)

      wc_child.new(:foobar => 12)

      expect_rebuild_notification(:what => :needs, :why => :invalid, :class => @wc, :originating_class => wc_child)
      expect_rebuild_notification(:what => :needs, :why => :invalid, :class => wc_child, :originating_class => wc_child)
      expect_no_more_rebuild_notifications!(:needs)
      expect_no_more_invalidating_notifications!(:needs)
    end
  end

  describe "run_content" do
    it "should fire a notification when rebuilding because an around_content filter was added" do
      @wc.around_content :around1
      expect_rebuild_notification(:what => :run_content, :why => :around_content_added)
      expect_no_more_rebuild_notifications!(:run_content)

      @wc.around_content :around2
      expect_rebuild_notification(:what => :run_content, :why => :around_content_added)
      expect_no_more_rebuild_notifications!(:run_content)
    end

    it "should fire a notification when rebuilding because an around_content filter was removed" do
      @wc.around_content :around1
      expect_rebuild_notification(:what => :run_content, :why => :around_content_added)
      expect_no_more_rebuild_notifications!(:run_content)

      @wc.remove_around_content :around1
      expect_rebuild_notification(:what => :run_content, :why => :around_content_removed)
      expect_no_more_rebuild_notifications!(:run_content)
    end

    it "should fire a notification when rebuilding because use_localized_content_methods was changed" do
      @wc.class_eval do
        use_localized_content_methods true
      end
      expect_rebuild_notification(:what => :run_content, :why => :use_localized_content_methods_changed)
      expect_no_more_rebuild_notifications!(:run_content)

      @wc.send(:use_localized_content_methods, false)
      expect_rebuild_notification(:what => :run_content, :why => :use_localized_content_methods_changed)
      expect_no_more_rebuild_notifications!(:run_content)
    end
  end

  describe "tag_methods" do
    it "should fire a notification when rebuilding because a tag was added" do
      @wc.tag :foo
      expect_rebuild_notification(:what => :tag_methods, :why => :tags_declared)
      expect_no_more_rebuild_notifications!(:tag_methods)
    end

    it "should fire a notification when rebuilding because format_output has changed" do
      @wc.format_output true
      expect_rebuild_notification(:what => :tag_methods, :why => :format_output_changed)
      expect_no_more_rebuild_notifications!(:tag_methods)

      @wc.format_output false
      expect_rebuild_notification(:what => :tag_methods, :why => :format_output_changed)
      expect_no_more_rebuild_notifications!(:tag_methods)
    end

    it "should fire a notification when rebuilding because enforce_element_nesting_rules has changed" do
      @wc.enforce_element_nesting_rules true
      expect_rebuild_notification(:what => :tag_methods, :why => :enforce_element_nesting_rules_changed)
      expect_no_more_rebuild_notifications!(:tag_methods)

      @wc.enforce_element_nesting_rules false
      expect_rebuild_notification(:what => :tag_methods, :why => :enforce_element_nesting_rules_changed)
      expect_no_more_rebuild_notifications!(:tag_methods)
    end

    it "should fire a notification when rebuilding because enforce_attribute_rules has changed" do
      @wc.enforce_attribute_rules true
      expect_rebuild_notification(:what => :tag_methods, :why => :enforce_attribute_rules_changed)
      expect_no_more_rebuild_notifications!(:tag_methods)

      @wc.enforce_attribute_rules false
      expect_rebuild_notification(:what => :tag_methods, :why => :enforce_attribute_rules_changed)
      expect_no_more_rebuild_notifications!(:tag_methods)
    end

    it "should fire a notification when rebuilding because enforce_id_uniqueness has changed" do
      @wc.enforce_id_uniqueness true
      expect_rebuild_notification(:what => :tag_methods, :why => :enforce_id_uniqueness_changed)
      expect_no_more_rebuild_notifications!(:tag_methods)

      @wc.enforce_id_uniqueness false
      expect_rebuild_notification(:what => :tag_methods, :why => :enforce_id_uniqueness_changed)
      expect_no_more_rebuild_notifications!(:tag_methods)
    end
  end

  describe "with a subclass" do
    before :each do
      @wc = widget_class
      @wc_subclass = widget_class(:superclass => @wc)
    end

    it "should fire with the right class for text methods" do
      @wc_subclass.format_output true
      expect_rebuild_notification(:what => :text_methods, :why => :format_output_changed, :class => @wc_subclass, :originating_class => @wc_subclass)
      expect_no_more_rebuild_notifications!(:text_methods)

      @wc.format_output true
      expect_rebuild_notification(:what => :text_methods, :why => :format_output_changed, :class => @wc, :originating_class => @wc)
      expect_rebuild_notification(:what => :text_methods, :why => :format_output_changed, :class => @wc_subclass, :originating_class => @wc)
      expect_no_more_rebuild_notifications!(:text_methods)
    end

    it "should fire with the right class for needs" do
      @wc_subclass.extra_assigns :use
      expect_invalidating_notification(:what => :needs, :why => :extra_assigns_changed, :class => @wc_subclass, :originating_class => @wc_subclass)
      expect_no_more_invalidating_notifications!(:needs)

      @wc.extra_assigns :error
      expect_invalidating_notification(:what => :needs, :why => :extra_assigns_changed, :class => @wc, :originating_class => @wc)
      expect_invalidating_notification(:what => :needs, :why => :extra_assigns_changed, :class => @wc_subclass, :originating_class => @wc)
      expect_no_more_invalidating_notifications!(:needs)
    end

    it "should fire with the right class for run_content" do
      @wc_subclass.around_content :around1
      expect_rebuild_notification(:what => :run_content, :why => :around_content_added, :class => @wc_subclass, :originating_class => @wc_subclass)
      expect_no_more_rebuild_notifications!(:run_content)

      @wc.around_content :around2
      expect_rebuild_notification(:what => :run_content, :why => :around_content_added, :class => @wc, :originating_class => @wc)
      expect_rebuild_notification(:what => :run_content, :why => :around_content_added, :class => @wc_subclass, :originating_class => @wc)
      expect_no_more_rebuild_notifications!(:run_content)
    end

    it "should fire with the right class for tag_methods" do
      @wc_subclass.format_output true
      expect_rebuild_notification(:what => :tag_methods, :why => :format_output_changed, :class => @wc_subclass, :originating_class => @wc_subclass)
      expect_no_more_rebuild_notifications!(:tag_methods)

      @wc.format_output true
      expect_rebuild_notification(:what => :tag_methods, :why => :format_output_changed, :class => @wc, :originating_class => @wc)
      expect_rebuild_notification(:what => :tag_methods, :why => :format_output_changed, :class => @wc_subclass, :originating_class => @wc)
      expect_no_more_rebuild_notifications!(:tag_methods)
    end
  end
end
