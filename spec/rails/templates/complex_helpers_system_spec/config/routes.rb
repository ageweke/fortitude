app_class = "#{File.basename(Rails.root).camelize}::Application".constantize
app_class.routes.draw do
  resources :carryover

  get ':controller/:action'
end
