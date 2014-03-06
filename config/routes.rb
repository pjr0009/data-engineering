Boilerplate::Application.routes.draw do

  devise_for :users
  # I usually work with rails resources, but I'm just going to set these up
  # for brevity, because it's only about 3-4 routes.
  get  'upload' => 'reports#upload'
  get  'reports' => 'reports#browse'
  get  'details/:id' => "reports#details"
  post 'process_report' => 'reports#process_report'


  root :to => "static#index"

  get ':action' => 'static#:action'

end
