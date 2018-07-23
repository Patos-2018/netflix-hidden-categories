class AddUriToGenres < ActiveRecord::Migration[5.1]
  def change
    add_column :genres, :uri, :string
  end
end
