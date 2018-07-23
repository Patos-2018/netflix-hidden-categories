class Genre < ApplicationRecord
  has_and_belongs_to_many :netflix_titles

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
end
