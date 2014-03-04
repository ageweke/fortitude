class SimpleRc < Fortitude::RenderingContext
  def initialize(options)
    @the_value = options.delete(:the_value)
    super(options)
  end

  attr_reader :the_value
end
