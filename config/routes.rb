Rails.application.routes.draw do
  devise_for :users
  root "static_pages#top"

  get "mypage", to: "mypages#show"
end
