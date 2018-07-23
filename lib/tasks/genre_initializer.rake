namespace :genre_initializer do
  desc 'Set genre counter'
  task :set_counter => :environment do
    Genre.all.each do |genre|
      genre.update_counter
      genre.save
    end
  end

  desc 'Uri generator for genre'
  task :uri_generator => :environment do
    uri_base = 'https://www.netflix.com/browse/genre/'
    Genre.all.each do |genre|
      genre.update(uri: uri_base + genre.id.to_s)
    end
  end
end
