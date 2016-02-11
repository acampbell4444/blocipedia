class Wiki < ActiveRecord::Base
  belongs_to :user

  validates :title, length: { maximum: 150 }, presence: true
  validates :body, length: { maximum: 500 }, presence: true
  validates :user, presence: true

  default_scope { order('title ASC') }
end
