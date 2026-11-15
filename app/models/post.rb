class Post < ApplicationRecord
  belongs_to :user
  belongs_to :group
  belongs_to :timeline_period
end
