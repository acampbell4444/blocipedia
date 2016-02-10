class User < ActiveRecord::Base
  has_many :roles
  has_many :wikis

  before_create :set_default_role
  after_save :downgrade
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
    if self.standard?
      self.wikis.where(private: true).update_all(private: false)
    end
  end

  private

  def set_default_role
    self.role ||= 'standard'
  end
end
