require 'rails_helper'
include RandomData

RSpec.describe Wiki, type: :model do
  let(:my_user) { create(:user) }
  let(:my_wiki1) { create(:wiki, user: my_user) }

  it { should belong_to(:user) }

  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:body) }
  it { should validate_presence_of(:user) }
  it { should validate_length_of(:title).is_at_most(150) }
  it { should validate_length_of(:body).is_at_most(500) }

  describe "attributes" do
    it "should respond to title" do
      expect(my_wiki1).to respond_to(:title)
    end

    it "should respond to body" do
      expect(my_wiki1).to respond_to(:body)
    end
  end
end
