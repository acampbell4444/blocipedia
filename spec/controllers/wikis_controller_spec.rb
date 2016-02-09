require 'rails_helper'

RSpec.describe WikisController, type: :controller do
  let(:my_user) { create(:user) }
  let(:my_wiki1) { create(:wiki, user: my_user) }
  let(:my_wiki2) { create(:wiki, user: my_user) }

  context 'unauthorized user' do
    describe 'GET #show' do
      it 'returns http redirect' do
        get :show, id: my_wiki1.id
        expect(response).to have_http_status(:redirect)
      end

      it "can't display wiki to unauthorized user" do
        get :show, id: my_wiki1.id
        expect(assigns(:wiki)).to eq(nil)
      end
    end

    describe "GET #index" do
      it 'returns http redirect' do
        get :index
        expect(response).to have_http_status(:redirect)
      end

      it "can't display wikis to unauthorized user" do
        get :index
        expect(assigns(:wikis)).to eq(nil)
      end
    end

    describe "GET #new" do
      it "returns http redirect" do
        get :new
        expect(response).to have_http_status(:redirect)
      end
    end

    describe "POST create" do
      it "returns http redirect" do
        post :create, user_id: my_user.id, post: my_wiki1
        expect(response).to have_http_status(:redirect)
      end
    end

    describe "GET #edit" do
      it "returns http redirect" do
        get :edit, id: my_wiki1.id
        expect(response).to have_http_status(:redirect)
      end
    end

    describe "PUT update" do
      it "returns http redirect" do
        new_title = RandomData.random_sentence
        new_body = RandomData.random_paragraph
        put :update, user_id: my_user.id, id: my_wiki1.id, post: { title: new_title, body: new_body }
        expect(response).to have_http_status(:redirect)
      end
    end

    describe "DELETE destroy" do
      it "returns http redirect" do
        delete :destroy, user_id: my_user.id, id: my_wiki1.id
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  context 'authorized user' do
    before(:each) do
      sign_in my_user
    end

    describe 'GET #show' do
      it 'returns http success' do
        get :show, id: my_wiki1.id
        expect(response).to have_http_status(:success)
      end

      it 'raises RecordNotFound when not found' do
        assert_raises(ActiveRecord::RecordNotFound) do
          get :show, id: 1234
        end
      end

      it "can display wiki to authorized user" do
        get :show, id: my_wiki1.id
        expect(assigns(:wiki)).to eq(my_wiki1)
      end
    end

    describe "GET #index" do
      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it "displays wikis to authorized user" do
        get :index
        expect(assigns(:wikis)).to eq([my_wiki1, my_wiki2])
      end
    end

    describe "GET #new" do
      it "returns http success" do
        get :new
        expect(response).to have_http_status(:success)
      end
    end

    describe "POST create" do
      it "increases the number of wikis by 1" do
        expect { post :create, wiki: { title: RandomData.random_sentence, body: RandomData.random_paragraph } }.to change(Wiki, :count).by(1)
      end

      it "redirects to the new wiki" do
        post :create, wiki: { title: RandomData.random_sentence, body: RandomData.random_paragraph }
        expect(response).to redirect_to Wiki.last
      end
    end

    describe "GET #edit" do
      it "returns http success" do
        get :edit, id: my_wiki1.id
        expect(response).to have_http_status(:success)
      end

      it 'raises RecordNotFound when not found' do
        assert_raises(ActiveRecord::RecordNotFound) do
          get :edit, id: 1234
        end
      end
    end

    describe "PUT update" do
      it "updates wiki with expected attributes" do
        new_title = RandomData.random_sentence
        new_body = RandomData.random_paragraph

        put :update, id: my_wiki1.id, wiki: { title: new_title, body: new_body }

        updated_wiki = assigns(:wiki)
        expect(updated_wiki.id).to eq my_wiki1.id
        expect(updated_wiki.title).to eq new_title
        expect(updated_wiki.body).to eq new_body
      end
    end

    describe "DELETE destroy" do
      it "deletes the wiki" do
        delete :destroy, id: my_wiki1.id
        count = Wiki.where(id: my_wiki1.id).size
        expect(count).to eq 0
      end

      it "redirects to wikis index" do
        delete :destroy, id: my_wiki1.id
        expect(response).to redirect_to wikis_path
      end

      it 'raises RecordNotFound when not found' do
        assert_raises(ActiveRecord::RecordNotFound) do
          delete :destroy, id: 1234
        end
      end
    end
  end

  context 'standard user' do
    before(:each) do
      sign_in my_user
    end
    describe 'GET #show' do
      it 'returns http success' do
        get :show, id: my_wiki1.id
        expect(response).to be_success
      end

      it 'renders the #show view' do
        get :show, id: my_wiki1.id
        expect(response).to render_template :show
      end

      it 'assigns my_wiki1 to @wiki' do
        get :show, id: my_wiki1.id
        expect(assigns(:wiki)).to eq(my_wiki1)
      end
    end

    describe 'GET #index' do
      it 'responds successfully with an HTTP 200 status code' do
        get :index
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it 'renders the index template' do
        get :index
        expect(response).to render_template('index')
      end

      it 'loads all of the wikis into @wikis' do
        get :index
        expect(assigns(:wikis)).to match_array([my_wiki1, my_wiki2])
      end
    end
  end
end
