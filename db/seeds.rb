# -*- coding:utf-8 -*-

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'faker'

10.times do |i| # 0始まり
  locale = case i
           when 0..2; 'en-GB'
           when 3..5; 'ja'
           when 6..7; 'zh-TW'
           when 8..9; 'fr'
           end
  Faker::Config.locale = locale

  FakeUser.create!(
    name:     Faker::Name.name,
    email:    Faker::Internet.email,
    email_verified: false,
    address:  Faker::Address.full_address,
    profile:  Faker::Internet.url,
    locale:   locale,
    phone_number: Faker::PhoneNumber.phone_number
  )
end

# Scope Values
Scope.create! [
  {name: 'openid' },
  {name: 'profile'},
  {name: 'email'  },
  {name: 'address'},
  {name: 'phone'}
]

