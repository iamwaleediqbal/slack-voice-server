Rails.application.routes.draw do
  mount ActionCable.server => '/cable'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :calls
  resources :slack_users
  resources :slack_auth do
   collection do
      get 'call_back'
      post 'send_to_slack'
    end
  end
  root 'welcome#index'
end
