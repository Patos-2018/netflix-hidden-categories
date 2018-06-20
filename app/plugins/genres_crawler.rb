class GenresCrawler
  def self.gather_genres
    agent = Mechanize.new
    page = agent.get('https://www.finder.com/netflix/genre-list')
    raw_genres = page.xpath('//script')[17]
                     .content
                     .remove('window.genreList = ')
    JSON.parse(raw_genres)
  end

  def self.populate_genres
    genres = gather_genres
    genres.each do |genre|
      Genre.create!(genre)
    end
  end
end
