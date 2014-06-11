class Views::AutoloadNamespace::AutoloadWidget < Fortitude::Widgets::Html5
  class << self
    def is_here
      "autoload_widget is here!"
    end
  end

  def content
    p "hello, world"
  end
end
