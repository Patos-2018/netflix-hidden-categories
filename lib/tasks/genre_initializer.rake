namespace :genre_initializer do
  desc 'Set genre counter'
  task :set_counter => :environment do
    Genre.all.each do |genre|
      genre.update_counter
      genre.save
    end
  end
end