class Views::DataPassingSystemSpec::ExtraVariables < Fortitude::Widget
  needs :foo

  def content
    show_var(:foo)
    show_var(:bar)
    show_var(:baz)
  end

  def show_var(name)
    method_call = begin
      send(name)
    rescue => e
      e.class.name
    end
    method_call = method_call

    instance_var = instance_variable_get("@#{name}").inspect

    p "#{name} method call: #{method_call}"
    p "#{name} instance var: #{instance_var}"
  end
end
