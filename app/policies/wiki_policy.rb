class WikiPolicy < ApplicationPolicy
  attr_reader :user, :wiki

  def initialize(user, wiki)
    @user = user
    @wiki = wiki
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end
    
    #def resolve
    #end
  end

  def new?
    create_authorization
  end

  def create?
    create_authorization
  end

  def edit?
    edit_update_authorization if !user.nil?
  end

  def update?
    edit_update_authorization if !user.nil?
  end

  def destroy?
    destroy_authorization if !user.nil?
  end

  def show?
    show_authorization
  end

  def private_index?
    if !(user.nil?)
      user.admin_premium?
    else
      false
    end
  end

  def index?
    user.nil? || user.present?
  end

  def create_authorization
    wiki.private ? user.admin_premium? : user.present?
  end

  def show_authorization
    (user.present? && (private_show || !wiki.private)) || (user.nil? && !wiki.private)
  end

  def private_show
    collab_ids = wiki.collaborators.pluck("user_id")
    wiki.private && ((user.premium? && (user == wiki.user)) || user.admin?) || collab_ids.include?(user.id)
  end

  def edit_update_authorization
    collab_ids = wiki.collaborators.pluck("user_id")
    (!wiki.private && user.present?) || (user.premium? && (user == wiki.user)) || user.admin? || collab_ids.include?(user.id)
  end

  def destroy_authorization
    (user == wiki.user) || user.admin?
  end
end
