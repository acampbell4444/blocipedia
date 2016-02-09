class WikiPolicy < ApplicationPolicy
  attr_reader :user, :wiki

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      if user.standard?
        scope.where(private: false)
      elsif user.admin_premium?
        scope.all
      end
    end
  end

  def initialize(user, wiki)
    @user = user
    @wiki = wiki
  end

  def create?
    crud_authorization
  end

  def edit?
    user.present?
  end

  def destroy?
    destroy_authorization
  end

  def show?
    crud_authorization
  end

  def index?
    crud_authorization
  end

  def crud_authorization # except destroy
    if wiki.private
      (user.premium? && (user == wiki.user)) || user.admin?
    else
      user.present?
    end
  end

  def destroy_authorization
    user == wiki.user || user.admin?
  end
end
