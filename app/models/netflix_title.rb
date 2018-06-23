class NetflixTitle < ApplicationRecord
  has_and_belongs_to_many :genres
  validates :name, presence: true
  validates :type, presence: true

  def self.with_no_genres
    left_outer_joins(:genres).group('netflix_titles.id')
                             .having('count(netflix_title_id) = 0')
  end

  def self.with_genres
    joins(:genres).group('netflix_titles.id')
                  .having('count(netflix_title_id) > 0')
  end
end
