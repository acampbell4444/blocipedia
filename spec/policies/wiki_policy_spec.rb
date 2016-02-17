# require 'spec_helper'
# describe WikiPolicy do
#   subject { WikiPolicy.new(user, wiki)}
#
#   let(:resolved_scope) {WikiPolicy::Scope.new(user, Wiki.all).resolve}
#   let(:wiki) {Wiki.create}
#
#   context "being a visitor" do
#     let(:user) { nil }
#
#     it { should forbid_action(:private_index)}
#     it { should forbid_action(:create)}
#     it { should forbid_action(:new)}
#     it { should forbid_action(:edit)}
#     it { should forbid_action(:update)}
#     it { should forbid_action(:destroy)}
#
#     it { should permit_action(:show) }
#     it { should permit_action(:index) }
#   end
#
#   context "premium user" do
#     let(:user) { User.create(role: 'premium')}
#
#
#
#   end
# end
