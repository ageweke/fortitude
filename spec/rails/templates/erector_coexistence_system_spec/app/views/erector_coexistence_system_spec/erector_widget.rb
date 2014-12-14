class Views::ErectorCoexistenceSystemSpec::ErectorWidget < ::Erector::Widget
  needs :name

  def content
    p "this is an Erector widget, #{@name}"
  end
end
