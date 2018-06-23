class AddTypeToNetflixTitles < ActiveRecord::Migration[5.1]
  def change
    add_column :netflix_titles, :type, :string
  end
end
