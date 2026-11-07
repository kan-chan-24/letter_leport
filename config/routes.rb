Rails.application.routes.draw do
  devise_for :users
  root "static_pages#top"

  get "mypage", to: "mypages#show"

  resources :groups, only: [ :new, :create, :show, :edit, :update ] do
    resources :group_members, only: [ :destroy ]
  end

  # 招待ページ
  resources :invitations, only: [ :show ], param: :token do
    # 参加先のグループidに紐づくgroup_membersルーティングを生成
    resources :group_members, only: [ :create ]
  end
end
