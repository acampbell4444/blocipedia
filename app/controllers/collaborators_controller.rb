class CollaboratorsController < ApplicationController
  # ##refactor
  # /wikis/:wiki_id/collaborators/:id(.:format)

  def index
    @wiki = Wiki.find(params[:wiki_id])
    user = @wiki.user
    @collaborators = nil || User.where.not(role: 'standard', id: current_user.id)
  end

  def destroy
    @wiki = Wiki.find(params[:wiki_id])
    @collaborator = Collaborator.find_by(user_id: params[:id])

    if @collaborator.delete
      flash[:notice] = "Collaborator removed"
      redirect_to wiki_collaborators_path(@wiki)
    else
      flash[:notice] = "There was an error removing the Collaborator."
      redirect_to edit_wiki_path(@wiki)
    end
  end

  def create
    @user = User.find(params[:id])
    @wiki = Wiki.find(params[:wiki_id])
    @collaborator = Collaborator.new(user: @user, wiki: @wiki)

    if @collaborator.save
      flash[:notice] = "Collaborators have been saved."
      redirect_to wiki_collaborators_path(@wiki)
    else
      flash[:error] = "An error occured we were unable to save the collaborators"
      redirect_to edit_wiki_path(@wiki)
    end
  end
end
