class Collaborator < ActiveRecord::Base
  belongs_to :user
  belongs_to :wiki

  validates :wiki_id, presence: true
  validates :user_id, presence: true
end
