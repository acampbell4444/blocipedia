require "random_data"
include RandomData

FactoryGirl.define do
  factory :wiki do
    title RandomData.random_sentence
    body RandomData.random_paragraph
  end
end
