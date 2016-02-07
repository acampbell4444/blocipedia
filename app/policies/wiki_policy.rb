class WikiPolicy < ApplicationPolicy
  attr_reader :user, :wiki

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      if user.admin_premium?
        scope.all
      else
        scope.where(private: false)
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

  def update?
     crud_authorization
  end

  def edit?
    crud_authorization
  end

  def destroy?
    crud_authorization
  end

  def show?
    crud_authorization
  end

  def crud_authorization
    user.admin? || user.premium? || (user.standard? && (!wiki.private))
  end




end
