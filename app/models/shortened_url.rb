class ShortenedUrl < ActiveRecord::Base
  validates :long_url, presence: true
  validates :submitter_id, presence: true

  belongs_to :submitter,
    class_name: "User",
    foreign_key: :submitter_id,
    primary_key: :id

  has_many :visits,
    class_name: "Visit",
    foreign_key: :short_url_id,
    primary_key: :id

  has_many :visitors,
    -> { distinct },
    through: :visits,
    source: :visitor

  def self.random_code
    short_url = SecureRandom::urlsafe_base64
    until !ShortenedUrl.exists?(short_url)
      short_url = SecureRandom::urlsafe_base64
    end
    short_url
  end

  def self.create_for_user_and_long_url!(user, long_url)
    ShortenedUrl.create!(submitter: user, long_url: long_url,
      short_url: self.random_code)
  end

  def num_clicks
    visits.count
  end

  def num_uniques
    visitors.count
  end

  def num_recent_uniques
    ten_minutes_ago = Time.now - 10.minutes
    visitors.where("visits.created_at" => (10.minutes.ago..Time.now)).distinct.length
  end

end
