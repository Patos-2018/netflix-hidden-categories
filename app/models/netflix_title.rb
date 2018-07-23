class NetflixTitle < ApplicationRecord
  has_and_belongs_to_many :genres
  validates :name, presence: true
  validates :type, presence: true
  validates :code, uniqueness: true
  before_destroy :decrease_count

  def self.with_no_genres
    left_outer_joins(:genres).group('netflix_titles.id')
                             .having('count(netflix_title_id) = 0')
  end

  def self.with_genres
    joins(:genres).group('netflix_titles.id')
                  .having('count(netflix_title_id) > 0')
  end

  def decrease_count
    genres.update_all('netflix_titles_count = netflix_titles_count - 1')
  end
end
