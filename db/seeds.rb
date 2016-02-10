require "faker"


  5.times do
  user = User.new(
    email: Faker::Internet.email,
    name:  Faker::Name.name,
    password: 'password',
    password_confirmation: 'password',
    role: 'standard'
  )
  user.skip_confirmation!
  user.save!
  end
  users = User.all

  50.times do
  wiki = Wiki.create!(
    user: users.sample,
    title: Faker::Hipster.sentence,
    body: Faker::Hipster.paragraph,
    private: false
  )
  end

  50.times do
  wiki = Wiki.create!(
    user: users.sample,
    title: Faker::Hipster.sentence,
    body: Faker::Hipster.paragraph,
    private: true
  )
  end
  wikis = Wiki.all

  user = User.first
  user.skip_reconfirmation!
  user.update_attributes!(
  name: 'admin',
  email: 'admin@example.com',
  password: 'password',
  role: 'admin'
)

  user = User.second
  user.skip_reconfirmation!
  user.update_attributes!(
  name: 'premium',
  email: 'premium@example.com',
  password: 'password',
  role: 'premium'
)

user = User.third
user.skip_reconfirmation!
user.update_attributes!(
  name: 'standard',
  email: 'standard@example.com',
  password: 'password',
  role: 'standard'
)
 puts "#{User.count} users created"
 puts "#{Wiki.count} wikis created"
