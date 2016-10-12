$stderr.puts "LOADED AT:\n    #{caller.join("\n    ")}"

initial = "class ViewPathsSystemSpec::AddedViewPathFromControllerWithImposs"

rest = <<-EOS
ibleToGuessName < Fortitude::Widgets::Html5
  def content
    p "from an added view path from the controller with an impossible-to-guess name"
  end
end
EOS

total = initial.strip + rest.strip
eval(total)
