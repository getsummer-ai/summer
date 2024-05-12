# frozen_string_literal: true

class User < ApplicationRecord
  include Trackable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :timeoutable,
         :lockable,
         :trackable,
         :omniauthable,
         omniauth_providers: %i[google_oauth2]

  enum :locale, { en: 'en' }, default: :en, validate: true

  has_many :all_events, class_name: 'Event', as: :author, dependent: :restrict_with_exception
  has_many :projects, dependent: :restrict_with_exception
  belongs_to :default_project, -> { available }, class_name: 'Project', optional: true, inverse_of: :user

  def self.from_omniauth(auth, locale = nil)
    user =
      where(email: auth.info.email).first_or_create do |u|
        u.provider = auth.provider
        u.uid = auth.uid
        u.avatar_url = auth.info.image
        u.name = auth.info.name
        u.password = Devise.friendly_token
        u.locale = locale if User.locales.value?(locale.to_s)
      end
    user.update(provider: auth.provider, uid: auth.uid) if user.provider.blank?
    user
  end

  def send_reset_password_instructions
    return errors.add(:base, I18n.t('errors.messages.you_use_google_oauth2')) if provider == 'google_oauth2'
    if reset_password_sent_at.present? && reset_password_sent_at > 30.minutes.ago
      wait_for = (reset_password_sent_at + 30.minutes - Time.zone.now) / 1.minute
      return errors.add(:base, I18n.t('errors.messages.reset_pass_delay', minutes: wait_for.round))
    end
    super
  end

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  # instead of deleting, indicate the user requested a delete & timestamp it
  def soft_delete
    update_attribute(:deleted_at, Time.current)
  end

  # ensure user account is active
  def active_for_authentication?
    super && !deleted_at
  end

  def remember_me
    super.nil? ? '1' : super
  end

  # provide a custom message for a deleted account
  def inactive_message
    deleted_at ? :deleted_account : super
  end

  def decorate
    UserDecorator.new(self)
  end
end

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  avatar_url             :text
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  deleted_at             :datetime
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  failed_attempts        :integer          default(0), not null
#  is_admin               :boolean          default(FALSE), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  locale                 :enum             default("en"), not null
#  locked_at              :datetime
#  name                   :string
#  provider               :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  uid                    :string
#  unconfirmed_email      :string
#  unlock_token           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  default_project_id     :bigint
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_default_project_id    (default_project_id)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (default_project_id => projects.id) ON DELETE => nullify ON UPDATE => cascade
#
