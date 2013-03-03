Boilerplate::Application.routes.draw do

  devise_for :users

  match 'dashboard' => 'dashboard#index', :as => 'dashboard'

  root :to => "static#index"

  match ':action' => 'static#:action'

end
