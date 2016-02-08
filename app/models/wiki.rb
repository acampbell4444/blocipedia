class Wiki < ActiveRecord::Base
  belongs_to :user

  validates :title, length: { maximum: 100 }, presence: true
  validates :body, length: { maximum: 500 }, presence: true
  validates :user, presence: true
end
