class CollaboratorPolicy < ApplicationPolicy
  attr_reader :user, :collaborator

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      if @user.admin_premium?
        scope.where(user.admin_premium?)
      end
    end
  end

  def initialize(user, collaborator)
    @user = user
    @collaborator = collaborator
  end

  def new?
    user.admin_premium?
  end

  def create?
    user.admin_premium?
  end

  def destroy?
    user.admin_premium?
  end

  def index?
    user.admin_premium?
  end
end
