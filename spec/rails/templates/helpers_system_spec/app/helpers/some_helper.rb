module SomeHelper
  def excitedly(x)
    "#{x}!!!"
  end

  def say_how_awesome_it_is
    output_buffer << "super awesome!"
    "not at all awesome"
  end

  def reverse_it
    s = capture { yield "xx" }
    output_buffer << s.reverse
    "yy" + s
  end
end
