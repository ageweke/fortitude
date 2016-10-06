app_class = "#{File.basename(Rails.root).camelize}::Application".constantize
app_class.routes.draw do
  get ':controller/:action'

  root 'home#index'
  get '/foo', :to => 'home#foo'
end
