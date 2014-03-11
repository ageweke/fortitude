module SomeHelper
  def foo(x)
    "foo#{x}foo"
  end

  private
  def bar(x)
    output_buffer << "bar#{x}!"
  end
end
