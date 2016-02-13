require 'rails_helper'
include RandomData

RSpec.describe User, type: :model do
  let(:my_user) { create(:user) }

  it { should have_many(:wikis) }
  it { should have_many(:collaborators) }

  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }

  describe "attributes" do
    it "should respond to email" do
      expect(my_user).to respond_to(:email)
    end

    it "should respond to password" do
      expect(my_user).to respond_to(:password)
    end

    it "should respond to confirmed_at" do
      expect(my_user).to respond_to(:confirmed_at)
    end
  end
end
