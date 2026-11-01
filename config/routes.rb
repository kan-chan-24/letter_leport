Rails.application.routes.draw do
  devise_for :users
  root "static_pages#top"

  get "mypage", to: "mypages#show"

  resources :groups, only: [ :new, :create, :show ]

  # 招待ページ
  resources :invitations, only: [ :show ], param: :token
end
