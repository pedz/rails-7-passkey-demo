# frozen_string_literal: true

# == Route Map
#
#                Prefix Verb   URI Pattern                      Controller#Action
#            home_index GET    /home/index(.:format)            home#index
# callback_registration POST   /registration/callback(.:format) registrations#callback
#      new_registration GET    /registration/new(.:format)      registrations#new
#                       POST   /registration(.:format)          registrations#create
#      callback_session POST   /session/callback(.:format)      sessions#callback
#           new_session GET    /session/new(.:format)           sessions#new
#               session DELETE /session(.:format)               sessions#destroy
#                       POST   /session(.:format)               sessions#create
#                  root GET    /                                home#index

Rails.application.routes.draw do
  get 'home/index'

  resource :registration, only: %i[new create] do
    post :callback
  end

  resource :session, only: %i[new create destroy] do
    post :callback
  end

  root 'home#index'
end
