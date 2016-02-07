class Wiki < ActiveRecord::Base
  belongs_to :user

  validates :title, length: { maximum: 40 }, presence: true
  validates :body, length: {maximum: 250 }, presence: true
  validates :user, presence: true


end
