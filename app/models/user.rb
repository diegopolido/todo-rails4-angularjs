class User < ActiveRecord::Base
  devise :token_authenticatable, :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:facebook, :google_oauth2]

  has_many :task_lists, foreign_key: :owner_id

  after_create :create_task_list

  def clear_authentication_token!
    update_attribute(:authentication_token, nil)
  end

  def create_task_list
    task_lists.create!(name: "My first list")
  end

  def first_list
    task_lists.first
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
    end
  end
end
