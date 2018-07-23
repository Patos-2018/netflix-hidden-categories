class UriGenerator
  def self.run
    genres = Genre.all
    uri_base = 'https://www.netflix.com/browse/genre/'
    genres.each do |genre|
      genre.update(uri: uri_base + genre.id.to_s)
    end
  end
end
