class User < ActiveRecord::Base
  include Techbang::UserProfileMethods

  attr_accessible :login, :name, :nickname, :email, :fb_user_id, :email_hash , :avatar_file_name , :profile_attributes
  has_many :notifications
end

# == Schema Information
#
# Table name: users
#
#  id               :integer(4)      not null, primary key
#  login            :string(40)
#  name             :string(100)     default("")
#  nickname         :string(40)
#  slug             :string(40)
#  sex              :string(255)
#  email            :string(100)
#  fb_user_id       :integer(8)
#  email_hash       :string(255)
#  avatar_file_name :string(255)
#  role_id          :integer(4)
#  is_agreed        :boolean(1)
#  created_at       :datetime
#  updated_at       :datetime
#

