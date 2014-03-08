class SimpleRc < Fortitude::RenderingContext
  def initialize(options)
    @the_value = options.delete(:the_value)
    @start_end_calls = [ ]
    super(options)
  end

  attr_reader :the_value, :start_end_calls

  def start_widget!(widget)
    @start_end_calls << [ :start, widget ]
  end

  def end_widget!(widget)
    @start_end_calls << [ :end, widget ]
  end
end
