class WikisController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  after_action :verify_policy_scoped, only: [:private_index]

  def index
    @wikis = Wiki.where(private: false)
    authorize @wikis
  end

  def private_index
    @wikis = policy_scope(Wiki)
  end

  def show
    @wiki = Wiki.find(params[:id])
    authorize @wiki
  end

  def new
    @user = current_user
    @wiki = Wiki.new
    authorize @wiki
  end

  def edit
    @wiki = Wiki.find(params[:id])
    authorize @wiki
  end

  def create
    @wiki = Wiki.create(create_params)
    @wiki.user = current_user
    authorize@wiki

    if @wiki.save
      flash[:notice] = 'Wiki was saved.'
      redirect_to wiki_path(@wiki)
    else
      flash.now[:alert] = 'There was an error saving the wiki. Please try again.'
      render new_wiki_path
    end
  end

  def update
    @wiki = Wiki.find(params[:id])
    @wiki.assign_attributes(wiki_params)
    authorize @wiki

    if @wiki.save
      flash[:notice] = 'Wiki was saved.'
      redirect_to wiki_path(@wiki)
    else
      flash.now[:alert] = 'There was an error saving the wiki. Please try again.'
      render edit_wiki_path
    end
  end

  def destroy
    @wiki = Wiki.find(params[:id])
    authorize @wiki

    if !@wiki.private && @wiki.delete
      flash[:notice] = "\"#{@wiki.title}\" was deleted successfully."
      redirect_to action: :index
    elsif @wiki.private && @wiki.delete
      flash[:notice] = "\"#{@wiki.title}\" was deleted successfully."
      redirect_to wikis_private_index_path
    else
      flash.now[:alert] = 'There was an error deleting the wiki.'
      render :show
    end
  end

  private

  def wiki_params
    if current_user.admin? || (current_user.premium? && (@wiki.user == current_user))
      params.require(:wiki).permit(:title, :body, :private)
    else
      params.require(:wiki).permit(:title, :body)
    end
  end

  def create_params
    if current_user.admin_premium?
      params.require(:wiki).permit(:title, :body, :private)
    elsif current_user.standard?
      params.require(:wiki).permit(:title, :body)
    end
  end

  def permitted_attributes
    if current_user.admin_premium? && (@wiki.user == current_user)
      [:title, :body, :private]
    else
      [:title, :body]
    end
  end
end
