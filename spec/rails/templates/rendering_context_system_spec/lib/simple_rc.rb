class SimpleRc < Fortitude::RenderingContext
  def initialize(options)
    super
    @the_value = options[:the_value]
  end

  attr_reader :the_value
end
