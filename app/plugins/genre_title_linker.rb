class GenreTitleLinker
  def self.run(type = 'NetflixTitle')
    browser = Watir::Browser.new :firefox, headless: false
    browser.goto('https://www.netflix.com/cl-en/login')
    login_netflix(browser)
    iterate_on_titles(browser, type)
    browser.close
  end

  def self.login_netflix(browser)
    browser.text_field(name: 'email').set(ENV['NETFLIX_EMAIL'])
    browser.text_field(name: 'password').set(ENV['NETFLIX_PASSWORD'])
    browser.button(class: 'login-button').click
    profile = browser.link(class: 'profile-link').href
    browser.goto(profile)
  end

  def self.iterate_on_titles(browser, type)
    browser.button(class: 'searchTab').click
    # Get all the titles with no genre associations
    title_type = Object.const_get(type)
    titles = title_type.with_no_genres
    titles.each_with_index do |title, index|
      ap "Proccesing #{type} #{index + 1}/#{titles.length}"
      process_title(title, browser)
    end
  end

  def self.process_title(title, browser)
    browser.text_field('data-uia' => 'search-box-input').set(title.name)
    result_xpath = '//div[@id="row-0"]//div[contains(@class,"slider-item-0")]'
    wait_for_div(result_xpath, browser)
    return unless result.present?
    show_details(browser, result_xpath)
    process_html(title, browser.html)
  rescue StandardError => e
    ap "Processing failed: #{e.message}"
  end

  def self.show_details(browser, xpath)
    sleep 2
    result = browser.div(xpath: xpath)
    result.hover
    browser.link(class: 'bob-jaw-hitzone').click
    sleep 2
  end

  def self.process_html(title, html)
    page = Nokogiri::HTML(html)
    check_result_and_update(title, page)
  end

  def self.check_result_and_update(title, page)
    scraped_name = scrape_title_name(page)
    return if Genre.find_by(name: scraped_name)
    if wrong_name?(scraped_name, title)
      ap 'Enter action'
      action = gets.chomp
      return if action != 'y'
      correct_title_name(page, title)
    end
    update_title(title, page)
  end

  def self.update_title(title, page)
    title_data = scrape_title_data(page)
    genres = Genre.where(id: title_data[:genre_ids])
    title.genres = genres
    title.update(code: title_data[:code])
  end

  def self.correct_title_name(page, title)
    result_name = scrape_title_name(page)
    return if NetflixTitle.find_by(name: result_name)
    title.name = result_name
    title.save
  end

  def self.scrape_title_data(page)
    {
      genre_ids: scrape_genres(page),
      code: scrape_title_code(page)
    }
  end

  def self.scrape_genres(page)
    page.xpath('//p[contains(@class,"genres")]
                        /span[@class="list-items"]/a/@href')
        .map(&:content)
        .map { |l| l.split('/').last }
  end

  def self.scrape_title_code(page)
    page.at_xpath('//a[@class="jawbone-title-link"]/@href')
        .content
        .split('/')
        .last
        .to_i
  rescue StandardError
    nil
  end

  def self.scrape_title_name(page)
    result = page.at_xpath('//a[@class="jawbone-title-link"]')
    if result.content.blank?
      result.at_xpath('.//img/@alt').content
    else
      result.content
    end
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

  def self.wrong_name?(scraped_name, title)
    # Check if found equals to searched
    ap "Found #{scraped_name}/ Expected #{title.name}[#{title.id}]"
    !scraped_name.casecmp(title.name).zero?
  end
end
