class TitlesCrawler
  def self.gather_titles
    agent = Mechanize.new
    page = agent.get('https://www.finder.com/cl/netflix-movies')
    page.xpath('//tr/td[1]')[1..-1]
        .map(&:content)
  end

  def self.populate_titles
    titles = gather_titles
    titles.each do |title|
      NetflixTitle.create!(name: title)
    end
  end
end
