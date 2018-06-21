class CreateJoinTableGenresNetflixTitles < ActiveRecord::Migration[5.1]
  def change
    create_join_table :genres, :netflix_titles do |t|
      # t.index [:genre_id, :netflix_title_id]
      # t.index [:netflix_title_id, :genre_id]
    end
  end
end
