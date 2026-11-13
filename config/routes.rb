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

  # バックグラウンドのジョブを一覧確認するようのルーティング
  mount MissionControl::Jobs::Engine, at: "/jobs"

  # letter_openerのチェック画面を見られるようにする（開発環境でのみアクセスを許可する）
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # cron-job.orgがアクセスする用のURL（通知日時更新ジョブを登録させるためのURL）
  namespace :cron do
    resource :notification, only: :create
  end
end
