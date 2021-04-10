User.create!(name:  "Tomohiko OSHIMA (Admin)",
  email: "admin@example.com",
  password:              "password",
  password_confirmation: "password",
  admin: true,
  activated: true,
  activated_at: Time.zone.now)

# 追加のユーザーをまとめて生成する
99.times do |n|
name  = Faker::Name.name
email = "sample-#{n+1}@example.com"
password = "password"
User.create!(name:  name,
    email: email,
    password:              password,
    password_confirmation: password,
    activated: true,
    activated_at: Time.zone.now)
end

users = User.order(:created_at).take(6)
50.times do
  content = Faker::Lorem.sentence(word_count: 5)
  users.each do |user|
    user.microposts.create!(content: content)
  end
end

users = User.all
user = users.first
following = users[2..50]
followers = users[3..40]
following.each do |followed|
  user.follow(followed)
end
followers.each do |follower|
  follower.follow(user)
end