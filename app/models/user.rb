class User < ActiveRecord::Base
  has_many :roles
  has_many :wikis, through: :collaborators
  has_many :collaborators

  validates :name, length: { maximum: 12 }

  before_create :set_default_role
  after_initialize :downgrade
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  def standard?
    role == 'standard'
  end

  def premium?
    role == 'premium'
  end

  def admin?
    role == 'admin'
  end

  def admin_premium?
    role == 'premium' || role == 'admin'
  end

  def standard!
    update(role: 'standard')
  end

  def premium!
    update(role: 'premium')
  end

  def admin!
    update(role: 'admin')
  end

  def downgrade
    if role == 'standard'
      Wiki.where(user: self, private: true).update_all(private: false)
    end
  end

  private

  def set_default_role
    self.role ||= 'standard'
  end
end
