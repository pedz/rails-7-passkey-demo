# == Route Map
#
#            Prefix Verb   URI Pattern                   Controller#Action
#        home_index GET    /home/index(.:format)         home#index
#  callback_session POST   /session/callback(.:format)   sessions#callback
#       new_session GET    /session/new(.:format)        sessions#new
#           session DELETE /session(.:format)            sessions#destroy
#                   POST   /session(.:format)            sessions#create
#              root GET    /                             home#index

Rails.application.routes.draw do
  get 'home/index'

  resource :session, only: %i[new create destroy] do
    post :callback
  end

  root 'home#index'
end
