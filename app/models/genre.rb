class Genre < ApplicationRecord
  has_and_belongs_to_many :netflix_titles
  before_save :update_counter

  searchable do
    text :name
    string :sort_title do |genre|
      genre.name.downcase
    end
  end

  def self.with_titles
    joins(:netflix_titles).group('genres.id')
                          .having('count(genre_id) > 0')
  end

  def self.with_no_titles
    left_outer_joins(:netflix_titles).group('genres.id')
                                     .having('count(genre_id) = 0')
  end

  def update_counter
    self.netflix_titles_count = netflix_titles.size
  end
end
