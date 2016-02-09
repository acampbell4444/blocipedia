class WikisController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_policy_scoped, only: :index

  def index
    @wikis = policy_scope(Wiki).where(private: false)
  end

  def private
    @wikis = policy_scope(Wiki).where(private: true)
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
    @user = current_user
    @wiki = Wiki.new(wiki_params)
    @wiki.user = current_user
    authorize @wiki

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

    if @wiki.delete
      flash[:notice] = "\"#{@wiki.title}\" was deleted successfully."
      redirect_to action: :index
    else
      flash.now[:alert] = 'There was an error deleting the topic.'
      render :show
    end
  end

  private

  def wiki_params
    params.require(:wiki).permit(:title, :body, :private)
  end
end
