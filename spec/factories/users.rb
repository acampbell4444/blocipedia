require "random_data"
include RandomData

FactoryGirl.define do
  factory :user do
    name 'example'
    password 'password'
    email 'example@example.com'
    confirmed_at Date.today
  end
end
