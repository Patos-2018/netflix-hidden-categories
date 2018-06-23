class TvshowsCrawler
  def self.gather_titles
    agent = Mechanize.new
    page = agent.get('https://www.finder.com/cl/netflix-tv-shows')
    page.xpath('//tr/td[1]//b')
        .map(&:content)
  end

  def self.populate_database
    titles = gather_titles
    titles.each do |title|
      TvShow.create!(name: title)
    end
  end
end
