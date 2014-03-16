class Views::ClassLoadingSystemSpec::UnderscoreWidget < Fortitude::Widget::Html5
  class << self
    def data
      "underscore widget!"
    end
  end

  def content
    p "hello, this is the underscore widget"
  end
end
