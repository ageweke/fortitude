$_show_module_nesting = Module.nesting

class Views::ClassLoadingSystemSpec::ShowModuleNesting < Fortitude::Widgets::Html5
  def content
    text "module_nesting: #{$_show_module_nesting.inspect}"
  end
end
