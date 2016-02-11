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
  let(:private_wiki_admin) { create(:wiki, user: my_user_admin, private: true) }
  let(:private_wiki_premium) { create(:wiki, user: my_user_premium, private: true) }

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

      it "cannot display private wiki to unauthorized user" do
        assert_raises(Pundit::NotAuthorizedError) do
          get :show, id: private_wiki_premium.id
        end
      end
    end

    describe "GET #private" do
      it 'returns http redirect' do
        get :private_index
        expect(response).to have_http_status(:redirect)
      end

      it "cannot display private wikis to unauthorized user" do
        get :private_index
        expect(assigns(:wikis)).to eq(nil)
      end
    end

    describe "GET #index" do
      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it "can display wikis to unauthorized user" do
        get :index
        expect(assigns(:wikis)).to eq([my_wiki1, my_wiki2])
      end

      it "can not display  private wikis to unauthorized user" do
        get :index
        expect(assigns(:wikis)).not_to eq([my_wiki1, my_wiki2, private_wiki_premium])
      end
    end

    describe "GET #new" do
      it "returns http redirect" do
        get :new
        expect(response).to have_http_status(:redirect)
      end
    end

    describe "POST create" do
      it "does not allow unauthorized users to create posts" do
        expect { post :create, wiki: { title: RandomData.random_sentence, body: RandomData.random_paragraph } }.to change(Wiki, :count).by(0)
      end

      it "returns http redirect" do
        post :create, title: RandomData.random_sentence, body: RandomData.random_paragraph
        expect(response).to have_http_status(:redirect)
      end
    end

    describe "GET #edit" do
      it "returns http redirect when non-authorized tries to edit wiki" do
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

      it "fails to update wikis" do
        new_title = RandomData.random_sentence
        new_body = RandomData.random_paragraph
        put :update, id: my_wiki1.id, wiki: { title: new_title, body: new_body }
        updated_wiki = assigns(:wiki)
        expect(updated_wiki).to eq nil
      end
    end

    describe "DELETE destroy" do
      it "returns http redirect" do
        delete :destroy, user_id: my_user.id, id: my_wiki1.id
        expect(response).to have_http_status(:redirect)
      end

      it "will not delete wikis" do
        delete :destroy, id: my_wiki1.id
        count = Wiki.where(id: my_wiki1.id).size
        expect(count).to eq 1
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
      it 'returns http success on own wikis' do
        get :show, id: my_wiki1.id
        expect(response).to have_http_status(:success)
      end

      it "returns http success on other user's public wikis" do
        get :show, id: my_wiki3.id
        expect(response).to have_http_status(:success)
      end

      it "raises pundit error on other user's private wikis" do
        assert_raises(Pundit::NotAuthorizedError) do
          get :show, id: private_wiki_premium.id
        end
      end

      it 'raises RecordNotFound when not found' do
        assert_raises(ActiveRecord::RecordNotFound) do
          get :show, id: 1234
        end
      end

      it "can display public wiki to standard user" do
        get :show, id: my_wiki1.id
        expect(assigns(:wiki)).to eq(my_wiki1)
      end
    end

    describe "GET #private" do
      it 'raises pundit error when trying to access private index' do
        assert_raises(Pundit::NotAuthorizedError) do
          get :show, id: private_wiki_premium.id
        end
      end

      it "cannot display private wikis to standard user" do
        assert_raises(Pundit::NotAuthorizedError) do
          get :private_index
        end
      end
    end

    describe "GET #index" do
      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it "displays public wikis to standard user" do
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
      it "increases the number of public wikis by 1" do
        expect { post :create, wiki: { title: RandomData.random_sentence, body: RandomData.random_paragraph } }.to change(Wiki, :count).by(1)
      end

      it "redirects to the new wiki" do
        post :create, wiki: { title: RandomData.random_sentence, body: RandomData.random_paragraph }
        expect(response).to redirect_to Wiki.last
      end

      it "raises and error when standard tries to create wiki as private" do
        assert_raises(ActionController::UnpermittedParameters) do
          post :create, wiki: { title: RandomData.random_sentence, body: RandomData.random_paragraph, private: true, user: my_user }
        end
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

      it "wont privatize another users posts" do
        new_title = RandomData.random_sentence
        new_body = RandomData.random_paragraph
        assert_raises(ActionController::UnpermittedParameters) do
          put :update, id: my_wiki1.id, wiki: { title: new_title, body: new_body, private: true }
        end
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
      it 'returns http success for other users public wikis' do
        get :show, id: my_wiki1.id
        expect(response).to have_http_status(:success)
      end

      it 'raises RecordNotFound when wiki not found' do
        assert_raises(ActiveRecord::RecordNotFound) do
          get :show, id: 1234
        end
      end

      it "can display another user's public wiki" do
        get :show, id: my_wiki1.id
        expect(assigns(:wiki)).to eq(my_wiki1)
      end

      it "can display current user's private wiki" do
        get :show, id: private_wiki_premium.id
        expect(assigns(:wiki)).to eq(private_wiki_premium)
      end

      it "does not display another user's private wiki" do
        assert_raises(Pundit::NotAuthorizedError) do
          get :show, id: private_wiki_admin.id
        end
      end
    end

    describe "GET #private_index" do
      it 'displays users own private wiki' do
        get :show, id: private_wiki_premium.id
        expect(assigns(:wiki)).to eq(private_wiki_premium)
      end

      it "does not display other user's private wikis" do
        assert_raises(Pundit::NotAuthorizedError) do
          get :show, id: private_wiki_admin.id
        end
      end

      it "has http status success" do
        get :private_index
        expect(response).to have_http_status(:success)
      end

      it "does not display other public wikis" do
        get :private_index
        expect(assigns(:wikis)).not_to eq([my_wiki1, my_wiki2])
      end

      it "does not display own public wikis" do
        get :private_index
        expect(assigns(:wikis)).not_to eq([premium_wiki])
      end
    end

    describe "GET #index" do
      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it "displays all public wikis to premium users" do
        get :index
        expect(assigns(:wikis)).to eq([my_wiki1, my_wiki2, premium_wiki])
      end

      it "does not display private wikis" do
        get :index
        expect(assigns(:wikis)).not_to eq([my_wiki1, my_wiki2, private_wiki_premium])
      end
    end

    describe "GET #new" do
      it "returns http success" do
        get :new
        expect(response).to have_http_status(:success)
      end
    end

    describe "POST create" do
      it "increases the number of public wikis by 1" do
        expect { post :create, wiki: { title: RandomData.random_sentence, body: RandomData.random_paragraph } }.to change(Wiki, :count).by(1)
      end

      it "redirects to the new public wiki" do
        post :create, wiki: { title: RandomData.random_sentence, body: RandomData.random_paragraph }
        expect(response).to redirect_to Wiki.last
      end

      it "increases the number of private wikis by 1" do
        expect { post :create, wiki: { title: RandomData.random_sentence, body: RandomData.random_paragraph, private: true } }.to change(Wiki, :count).by(1)
      end

      it "redirects to the new private wiki" do
        post :create, wiki: { title: RandomData.random_sentence, body: RandomData.random_paragraph, private: true }
        expect(response).to redirect_to Wiki.last
      end
    end

    describe "GET #edit" do
      it "returns http success for own public wiki" do
        get :edit, id: premium_wiki.id
        expect(response).to have_http_status(:success)
      end

      it "returns http success when trying to edit other user's public wiki" do
        get :edit, id: my_wiki3.id
        expect(response).to have_http_status(:success)
      end

      it "raises authorization error when trying edit other's user's private wiki" do
        assert_raises(Pundit::NotAuthorizedError) do
          get :edit, id: private_wiki_admin
        end
      end

      it "returns http success when trying to edit own private wiki" do
        get :edit, id: private_wiki_premium.id
        expect(response).to have_http_status(:success)
      end

      it 'raises RecordNotFound when not found when tring to edit non-existent wiki' do
        assert_raises(ActiveRecord::RecordNotFound) do
          get :edit, id: 1234
        end
      end
    end

    describe "PUT update" do
      it "updates users own public wiki with expected attributes" do
        new_title = RandomData.random_sentence
        new_body = RandomData.random_paragraph

        put :update, id: premium_wiki.id, wiki: { title: new_title, body: new_body }

        updated_wiki = assigns(:wiki)
        expect(updated_wiki.id).to eq premium_wiki.id
        expect(updated_wiki.title).to eq new_title
        expect(updated_wiki.body).to eq new_body
      end

      it "updates other users public wikis with expected attributes" do
        new_title = RandomData.random_sentence
        new_body = RandomData.random_paragraph

        put :update, id: my_wiki3.id, wiki: { title: new_title, body: new_body }

        updated_wiki = assigns(:wiki)
        expect(updated_wiki.id).to eq my_wiki3.id
        expect(updated_wiki.title).to eq new_title
        expect(updated_wiki.body).to eq new_body
      end

      it "updates own private wikis with expected attributes" do
        new_title = RandomData.random_sentence
        new_body = RandomData.random_paragraph

        put :update, id: private_wiki_premium.id, wiki: { title: new_title, body: new_body }

        updated_wiki = assigns(:wiki)
        expect(updated_wiki.id).to eq private_wiki_premium.id
        expect(updated_wiki.title).to eq new_title
        expect(updated_wiki.body).to eq new_body
      end

      it "raises authorization error when attempting to update other's private wikis" do
        new_title = RandomData.random_sentence
        new_body = RandomData.random_paragraph

        assert_raises(Pundit::NotAuthorizedError) do
          put :update, id: private_wiki_admin.id, wiki: { title: new_title, body: new_body }
        end
      end
    end

    describe "DELETE destroy" do
      it "deletes users own public wiki" do
        delete :destroy, id: premium_wiki.id
        count = Wiki.where(id: premium_wiki.id).size
        expect(count).to eq 0
      end

      it "wont delete other users public wikis" do
        assert_raises(Pundit::NotAuthorizedError) do
          delete :destroy, id: my_wiki3.id
        end
      end

      it "redirects to wikis index after deleting own public wiki" do
        delete :destroy, id: premium_wiki.id
        expect(response).to redirect_to wikis_path
      end

      it "deletes users own private wiki" do
        delete :destroy, id: private_wiki_premium.id
        count = Wiki.where(id: private_wiki_premium.id).size
        expect(count).to eq 0
      end

      it "wont delete other users private wikis" do
        assert_raises(Pundit::NotAuthorizedError) do
          delete :destroy, id: private_wiki_admin
        end
      end

      it "redirects to wikis private_index after deleting own private wiki" do
        delete :destroy, id: private_wiki_premium.id
        expect(response).to redirect_to wikis_private_index_path
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
      it 'returns http success for other users public wikis' do
        get :show, id: my_wiki1.id
        expect(response).to have_http_status(:success)
      end

      it 'raises RecordNotFound when wiki not found' do
        assert_raises(ActiveRecord::RecordNotFound) do
          get :show, id: 1234
        end
      end

      it "can display current user's public wiki" do
        get :show, id: admin_wiki.id
        expect(assigns(:wiki)).to eq(admin_wiki)
      end

      it "can display another user's public wiki" do
        get :show, id: my_wiki1.id
        expect(assigns(:wiki)).to eq(my_wiki1)
      end

      it "can display current user's private wiki" do
        get :show, id: private_wiki_admin.id
        expect(assigns(:wiki)).to eq(private_wiki_admin)
      end

      it "displays another user's private wiki" do
        get :show, id: private_wiki_premium.id
        expect(assigns(:wiki)).to eq(private_wiki_premium)
      end
    end

    describe "GET #private_index" do
      it 'displays users own private wiki' do
        get :show, id: private_wiki_admin.id
        expect(assigns(:wiki)).to eq(private_wiki_admin)
      end

      it 'displays other users private wiki' do
        get :show, id: private_wiki_premium.id
        expect(assigns(:wiki)).to eq(private_wiki_premium)
      end

      it "has http status success" do
        get :private_index
        expect(response).to have_http_status(:success)
      end

      it "does not display other public wikis" do
        get :private_index
        expect(assigns(:wikis)).not_to eq([my_wiki1, my_wiki2])
      end

      it "does not display own public wikis" do
        get :private_index
        expect(assigns(:wikis)).not_to eq([premium_wiki])
      end
    end

    describe "GET #index" do
      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it "displays all public wikis to admin users" do
        get :index
        expect(assigns(:wikis)).to eq([my_wiki1, my_wiki2, premium_wiki, admin_wiki])
      end

      it "does not display private wikis" do
        get :index
        expect(assigns(:wikis)).not_to eq([my_wiki1, my_wiki2, private_wiki_premium])
      end
    end

    describe "GET #new" do
      it "returns http success" do
        get :new
        expect(response).to have_http_status(:success)
      end
    end

    describe "POST create" do
      it "increases the number of public wikis by 1" do
        expect { post :create, wiki: { title: RandomData.random_sentence, body: RandomData.random_paragraph } }.to change(Wiki, :count).by(1)
      end

      it "redirects to the new public wiki" do
        post :create, wiki: { title: RandomData.random_sentence, body: RandomData.random_paragraph }
        expect(response).to redirect_to Wiki.last
      end

      it "increases the number of private wikis by 1" do
        expect { post :create, wiki: { title: RandomData.random_sentence, body: RandomData.random_paragraph, private: true } }.to change(Wiki, :count).by(1)
      end

      it "redirects to the new private wiki" do
        post :create, wiki: { title: RandomData.random_sentence, body: RandomData.random_paragraph, private: true }
        expect(response).to redirect_to Wiki.last
      end
    end

    describe "GET #edit" do
      it "returns http success for own public wiki" do
        get :edit, id: admin_wiki.id
        expect(response).to have_http_status(:success)
      end

      it "returns http success when trying to edit other user's public wiki" do
        get :edit, id: my_wiki3.id
        expect(response).to have_http_status(:success)
      end

      it "allows admin to access edit for other user's private wiki" do
        get :edit, id: premium_wiki.id
        expect(response).to have_http_status(:success)
      end

      it "returns http success when trying to edit own private wiki" do
        get :edit, id: private_wiki_admin.id
        expect(response).to have_http_status(:success)
      end

      it 'raises RecordNotFound when not found when tring to edit non-existent wiki' do
        assert_raises(ActiveRecord::RecordNotFound) do
          get :edit, id: 1234
        end
      end
    end

    describe "PUT update" do
      it "updates users own public wiki with expected attributes" do
        new_title = RandomData.random_sentence
        new_body = RandomData.random_paragraph

        put :update, id: admin_wiki.id, wiki: { title: new_title, body: new_body }

        updated_wiki = assigns(:wiki)
        expect(updated_wiki.id).to eq admin_wiki.id
        expect(updated_wiki.title).to eq new_title
        expect(updated_wiki.body).to eq new_body
      end

      it "updates other users public wikis with expected attributes" do
        new_title = RandomData.random_sentence
        new_body = RandomData.random_paragraph

        put :update, id: my_wiki3.id, wiki: { title: new_title, body: new_body }

        updated_wiki = assigns(:wiki)
        expect(updated_wiki.id).to eq my_wiki3.id
        expect(updated_wiki.title).to eq new_title
        expect(updated_wiki.body).to eq new_body
      end

      it "updates own private wikis with expected attributes" do
        new_title = RandomData.random_sentence
        new_body = RandomData.random_paragraph

        put :update, id: private_wiki_admin.id, wiki: { title: new_title, body: new_body }

        updated_wiki = assigns(:wiki)
        expect(updated_wiki.id).to eq private_wiki_admin.id
        expect(updated_wiki.title).to eq new_title
        expect(updated_wiki.body).to eq new_body
      end

      it "updates other's private wikis with expected attributes" do
        new_title = RandomData.random_sentence
        new_body = RandomData.random_paragraph

        put :update, id: private_wiki_premium.id, wiki: { title: new_title, body: new_body }

        updated_wiki = assigns(:wiki)
        expect(updated_wiki.id).to eq private_wiki_premium.id
        expect(updated_wiki.title).to eq new_title
        expect(updated_wiki.body).to eq new_body
      end
    end

    describe "DELETE destroy" do
      it "deletes users own public wiki" do
        delete :destroy, id: admin_wiki.id
        count = Wiki.where(id: admin_wiki.id).size
        expect(count).to eq 0
      end

      it "deletes other user's public wikis" do
        delete :destroy, id: premium_wiki.id
        count = Wiki.where(id: premium_wiki.id).size
        expect(count).to eq 0
      end

      it "redirects to wikis index after deleting own public wiki" do
        delete :destroy, id: admin_wiki.id
        expect(response).to redirect_to wikis_path
      end

      it "deletes users own private wiki" do
        delete :destroy, id: private_wiki_admin.id
        count = Wiki.where(id: private_wiki_admin.id).size
        expect(count).to eq 0
      end

      it "deletes other users private wikis" do
        delete :destroy, id: private_wiki_premium.id
        count = Wiki.where(id: private_wiki_premium.id).size
        expect(count).to eq 0
      end

      it "redirects to wikis private_index after deleting a private wiki" do
        delete :destroy, id: private_wiki_premium.id
        expect(response).to redirect_to wikis_private_index_path
      end

      it 'raises RecordNotFound when not found' do
        assert_raises(ActiveRecord::RecordNotFound) do
          delete :destroy, id: 1234
        end
      end
    end
  end
end
