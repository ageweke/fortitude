describe "Fortitude needs-building performance", :type => :system do
  CLASS_COUNT = 2_000
  NEEDS_NAMES = %w{foo bar baz quux marph}

  it "should build needs quickly" do
    skip "nope"

    widget_classes = [ ]

    puts "creating #{CLASS_COUNT} widget classes..."
    CLASS_COUNT.times do |i|
      klass = widget_class do
        def content
          "widget_class!"
        end
      end

      needs_count = rand(NEEDS_NAMES.length + 1)
      needs_count.times do |i|
        klass.send(:needs, NEEDS_NAMES[i] => "the_#{NEEDS_NAMES[i]}")
      end

      widget_classes << klass
    end

    start_time = Time.now
    widget_classes.each { |wc| wc.new }
    end_time = Time.now

    puts "Took #{end_time - start_time} seconds to instantiate all #{widget_classes.length} widget classes the first time."
    puts "total_time_spent: #{$total_time_spent}"

    start_time = Time.now
    widget_classes.each { |wc| wc.new }
    end_time = Time.now

    puts "Took #{end_time - start_time} seconds to instantiate all #{widget_classes.length} widget classes the second time."
  end
end
