require 'rails_helper'

RSpec.describe WikisController, type: :controller do
  let(:my_user) { create(:user) }
  let(:my_user2) { create(:user, email: 'bob@example.com') }
  let(:my_user_premium) { create(:user, email: 'premium@example.com', role: 'premium') }
  let(:my_user_admin) { create(:user, email: 'admin@example.com', role: 'admin') }
  let(:my_wiki1) { create(:wiki, user: my_user) }
  let(:my_wiki2) { create(:wiki, user: my_user) }
  let(:my_wiki3) { create(:wiki, user: my_user2) }
  let(:premium_wiki) { create(:wiki, user: my_user_premium) }
  let(:admin_wiki) { create(:wiki, user: my_user_admin) }

  context 'unauthorized user' do
    describe 'GET #show' do
      it 'returns http success' do
        get :show, id: my_wiki1.id
        expect(response).to have_http_status(:success)
      end

      it "can display wiki to unauthorized user" do
        get :show, id: my_wiki1.id
        expect(assigns(:wiki)).to eq(my_wiki1)
      end
    end

    describe "GET #index" do
      it 'returns http redirect' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it "can display wikis to unauthorized user" do
        get :index
        expect(assigns(:wikis)).to eq([my_wiki1, my_wiki2])
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

  context 'standard user' do
    before(:each) do
      sign_in my_user
    end

    it 'users should have default role of standard' do
      expect(my_user.role).to eq('standard')
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

      it "can display wiki to standard user" do
        get :show, id: my_wiki1.id
        expect(assigns(:wiki)).to eq(my_wiki1)
      end
    end

    describe "GET #index" do
      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it "displays wikis to standard user" do
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

      it "returns http success when trying to edit other user's wiki" do
        get :edit, id: my_wiki3.id
        expect(response).to have_http_status(:success)
      end

      it 'raises RecordNotFound when not found' do
        assert_raises(ActiveRecord::RecordNotFound) do
          get :edit, id: 1234
        end
      end
    end

    describe "PUT update" do
      it "updates users own wiki with expected attributes" do
        new_title = RandomData.random_sentence
        new_body = RandomData.random_paragraph

        put :update, id: my_wiki1.id, wiki: { title: new_title, body: new_body }

        updated_wiki = assigns(:wiki)
        expect(updated_wiki.id).to eq my_wiki1.id
        expect(updated_wiki.title).to eq new_title
        expect(updated_wiki.body).to eq new_body
      end

      it "updates other users wikis with expected attributes" do
        new_title = RandomData.random_sentence
        new_body = RandomData.random_paragraph

        put :update, id: my_wiki3.id, wiki: { title: new_title, body: new_body }

        updated_wiki = assigns(:wiki)
        expect(updated_wiki.id).to eq my_wiki3.id
        expect(updated_wiki.title).to eq new_title
        expect(updated_wiki.body).to eq new_body
      end
    end

    describe "DELETE destroy" do
      it "deletes users own wiki" do
        delete :destroy, id: my_wiki1.id
        count = Wiki.where(id: my_wiki1.id).size
        expect(count).to eq 0
      end

      it "wont delete other users wikis" do
        assert_raises(Pundit::NotAuthorizedError) do
          delete :destroy, id: my_wiki3.id
        end
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

  context 'premium user' do
    before(:each) do
      sign_in my_user_premium
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

      it "can display wiki to premium user" do
        get :show, id: my_wiki1.id
        expect(assigns(:wiki)).to eq(my_wiki1)
      end
    end

    describe "GET #index" do
      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it "displays wikis to premium users" do
        get :index
        expect(assigns(:wikis)).to eq([my_wiki1, my_wiki2, premium_wiki])
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
        get :edit, id: premium_wiki.id
        expect(response).to have_http_status(:success)
      end

      it "returns http success when trying to edit other user's wiki" do
        get :edit, id: my_wiki3.id
        expect(response).to have_http_status(:success)
      end

      it 'raises RecordNotFound when not found when tring to edit non-existent wiki' do
        assert_raises(ActiveRecord::RecordNotFound) do
          get :edit, id: 1234
        end
      end
    end

    describe "PUT update" do
      it "updates users own wiki with expected attributes" do
        new_title = RandomData.random_sentence
        new_body = RandomData.random_paragraph

        put :update, id: premium_wiki.id, wiki: { title: new_title, body: new_body }

        updated_wiki = assigns(:wiki)
        expect(updated_wiki.id).to eq premium_wiki.id
        expect(updated_wiki.title).to eq new_title
        expect(updated_wiki.body).to eq new_body
      end

      it "updates other users wikis with expected attributes" do
        new_title = RandomData.random_sentence
        new_body = RandomData.random_paragraph

        put :update, id: my_wiki3.id, wiki: { title: new_title, body: new_body }

        updated_wiki = assigns(:wiki)
        expect(updated_wiki.id).to eq my_wiki3.id
        expect(updated_wiki.title).to eq new_title
        expect(updated_wiki.body).to eq new_body
      end
    end

    describe "DELETE destroy" do
      it "deletes users own wiki" do
        delete :destroy, id: premium_wiki.id
        count = Wiki.where(id: premium_wiki.id).size
        expect(count).to eq 0
      end

      it "wont delete other users wikis" do
        assert_raises(Pundit::NotAuthorizedError) do
          delete :destroy, id: my_wiki3.id
        end
      end

      it "redirects to wikis index" do
        delete :destroy, id: premium_wiki.id
        expect(response).to redirect_to wikis_path
      end

      it 'raises RecordNotFound when not found' do
        assert_raises(ActiveRecord::RecordNotFound) do
          delete :destroy, id: 1234
        end
      end
    end
  end

  context 'admin user' do
    before(:each) do
      sign_in my_user_admin
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

      it "can display wiki to an admin user" do
        get :show, id: my_wiki1.id
        expect(assigns(:wiki)).to eq(my_wiki1)
      end
    end

    describe "GET #index" do
      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it "displays wikis to admin users" do
        get :index
        expect(assigns(:wikis)).to eq([my_wiki1, my_wiki2, admin_wiki])
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
        get :edit, id: admin_wiki.id
        expect(response).to have_http_status(:success)
      end

      it "returns http success when trying to edit other user's wiki" do
        get :edit, id: my_wiki3.id
        expect(response).to have_http_status(:success)
      end

      it 'raises RecordNotFound when not found when tring to edit non-existent wiki' do
        assert_raises(ActiveRecord::RecordNotFound) do
          get :edit, id: 1234
        end
      end
    end

    describe "PUT update" do
      it "updates users own wiki with expected attributes" do
        new_title = RandomData.random_sentence
        new_body = RandomData.random_paragraph

        put :update, id: admin_wiki.id, wiki: { title: new_title, body: new_body }

        updated_wiki = assigns(:wiki)
        expect(updated_wiki.id).to eq admin_wiki.id
        expect(updated_wiki.title).to eq new_title
        expect(updated_wiki.body).to eq new_body
      end

      it "updates other users wikis with expected attributes" do
        new_title = RandomData.random_sentence
        new_body = RandomData.random_paragraph

        put :update, id: my_wiki3.id, wiki: { title: new_title, body: new_body }

        updated_wiki = assigns(:wiki)
        expect(updated_wiki.id).to eq my_wiki3.id
        expect(updated_wiki.title).to eq new_title
        expect(updated_wiki.body).to eq new_body
      end
    end

    describe "DELETE destroy" do
      it "deletes users own wiki" do
        delete :destroy, id: admin_wiki.id
        count = Wiki.where(id: admin_wiki.id).size
        expect(count).to eq 0
      end

      it "deletes other users wikis" do
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
end
