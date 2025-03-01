# frozen_string_literal: true


p 'Deleting join tables'
InfluencerCategory.destroy_all
NodeCategory.destroy_all

p 'Deleting influencers'
Influencer.destroy_all

p 'Deleting nodes'
Node.destroy_all

p 'Deleting categories'
Category.destroy_all

p 'Adding influencers'
50.times do
  picture = HTTParty.get('https://randomuser.me/api')['results'].first['picture']['thumbnail']
  name = Faker::Name.name
  username = Faker::Internet.user_name(name)
  inf = Influencer.new(
    followers_count: rand(20_000),
    following_count: rand(1200),
    email: "inw.bergmann@gmail.com",
    full_name: name,
    username: username,
    external_url: "wwww.#{username}.com",
    remote_photo_url: picture
  )
  inf.save!
end

p 'Adding categories'
Category.create(name: 'Animal Rights')
Category.create(name: 'Environment')
Category.create(name: 'Vegan')

p 'Adding nodes'
30.times do
  name = Faker::Book.publisher
  next if Node.find_by(name: name).present?
  url = Faker::Internet.user_name(name)
  node = Node.new(
    name: name,
    url: url,
    igid: rand(999_999).to_s
  )
  node.categories << Category.all.sample
  node.save!
end

p 'Randomly adding categories to nodes'
12.times do
  node = Node.all.sample
  node.categories << Category.all.sample
  node.save!
end

p 'Adding random categories to users'
500.times do
  influencer = Influencer.all.sample
  node = Node.all.sample

  node.categories.each do |category|
    random_match = InfluencerCategory.create!(
      category: category,
      influencer: influencer
    )
  end
end
