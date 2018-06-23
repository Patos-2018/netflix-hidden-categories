class GenreTitleLinker
  def self.run
    browser = Watir::Browser.new :firefox, headless: false
    browser.goto('https://www.netflix.com/cl-en/login')
    login_netflix(browser)
    iterate_on_titles(browser)
    browser.close
  end

  def self.login_netflix(browser)
    browser.text_field(name: 'email').set(ENV['NETFLIX_EMAIL'])
    browser.text_field(name: 'password').set(ENV['NETFLIX_PASSWORD'])
    browser.button(class: 'login-button').click
    profile = browser.link(class: 'profile-link').href
    browser.goto(profile)
  end

  def self.iterate_on_titles(browser)
    browser.button(class: 'searchTab').click
    # Get all the titles with no genre associations
    titles = NetflixTitle.with_no_genres
    titles.each_with_index do |title, index|
      ap "Proccesing title #{index + 1}/#{titles.length}"
      process_title(title, browser)
    end
  end

  def self.process_title(title, browser)
    browser.text_field('data-uia' => 'search-box-input').set(title.name)
    sleep 2
    result_xpath = '//div[@id="row-0"]//div[contains(@class,"slider-item-0")]'
    result = wait_for_div(result_xpath, browser)
    return unless result.present?
    show_details(browser, result, result_xpath)
    process_html(title, browser.html)
  end

  def self.show_details(browser, _result, xpath)
    sleep 2
    result = wait_for_div(xpath, browser)
    result.hover
    browser.link(class: 'bob-jaw-hitzone').click
    sleep 2
  end

  def self.process_html(title, html)
    page = Nokogiri::HTML(html)
    return if bad_result(page, title)
    title_data = scrape_title_data(page)
    genres = Genre.where(id: title_data[:genre_ids])
    title.genres = genres
  end

  def self.scrape_title_data(page)
    genres = page.xpath('//p[contains(@class,"genres")]
                        /span[@class="list-items"]/a/@href')
                 .map(&:content)
                 .map { |l| l.split('/').last }
    { genre_ids: genres }
  end

  # util

  def self.wait_for_div(div_xpath, browser, max_time = 5)
    sleep 1
    max_time.times do
      result = browser.div(xpath: div_xpath)
      return result if result.present? && result.visible?
      sleep 1
    end
    nil
  end

  def self.bad_result(page, title)
    result = page.at_xpath('//a[@class="jawbone-title-link"]')
    result_name = if result.content.blank?
                    result.at_xpath('.//img/@alt').content
                  else
                    result.content
                  end
    ap "Found #{result_name}/ Expected #{title.name}[#{title.id}]"
    !result_name.casecmp(title.name).zero? # Check if found equals to searched
  rescue StandardError
    true
  end
end
