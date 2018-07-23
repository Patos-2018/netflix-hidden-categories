class AddNetflixTitlesCountToGenres < ActiveRecord::Migration[5.1]
  def change
    add_column :genres, :netflix_titles_count, :int, default: 0
  end
end
