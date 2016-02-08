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
          get :show, {id: my_wiki1.id}
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
