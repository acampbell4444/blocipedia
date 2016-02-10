require "random_data"
include RandomData

FactoryGirl.define do
  factory :user do
    name (RandomData.random_word)
    password RandomData.random_word + RandomData.random_word + RandomData.random_word
    email RandomData.random_email
    confirmed_at Time.zone.today
  end
end
