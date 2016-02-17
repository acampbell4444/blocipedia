require 'rails_helper'

RSpec.describe Collaborator, type: :model do
  let(:my_user) { create(:user) }
  let(:my_wiki) { create(:wiki, user: my_user) }
  let(:collaborator) { Collaborator.create!(wiki: my_wiki, user: my_user) }

  it { is_expected.to belong_to(:wiki) }
  it { is_expected.to belong_to(:user) }
end
