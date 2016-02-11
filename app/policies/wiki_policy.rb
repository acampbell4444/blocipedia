class WikiPolicy < ApplicationPolicy
  attr_reader :user, :wiki

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      if user.nil? || user.standard?
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

  def new?
    create_authorization
  end

  def create?
    create_authorization
  end

  def edit?
    edit_update_authorization
  end

  def update?
    edit_update_authorization
  end

  def destroy?
    destroy_authorization
  end

  def show?
    show_authorization
  end

  def private_index?
    user.admin_premium?
  end

  def index?
    user.nil? || user
  end

  def create_authorization
    user.present?
  end

  def show_authorization
    if !(wiki.private)
      true
    else
      if !(user.present?) || user.standard?
        false
      elsif ((user.premium? && (user == wiki.user)) || user.admin?)
        true
      end
    end
  end

  def edit_update_authorization
    if !(wiki.private)
      if user.present?
        true
      else
        false
      end
    else
      if !(user.present?) || user.standard?
        false
      elsif
        ((user.premium? && (user == wiki.user)) || user.admin?)
        true
      end
    end
  end

  def destroy_authorization
    user == wiki.user || user.admin?
  end
end
