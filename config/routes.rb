Boilerplate::Application.routes.draw do

  devise_for :users

  get 'dashboard' => 'dashboard#index', :as => 'dashboard'

  root :to => "static#index"

  get ':action' => 'static#:action'

end
