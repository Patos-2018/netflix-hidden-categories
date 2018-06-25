class GenreTitleLinker
  def self.run(type = 'NetflixTitle')
    Watir.default_timeout = 5
    browser = Watir::Browser.new :chrome, headless: false
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
    # Get all the titles with no genre associations
    title_type = Object.const_get(type)
    titles = title_type.with_no_genres
    titles.each_with_index do |title, index|
      ap "Proccesing #{type} #{index + 1}/#{titles.length}"
      process_title(title, browser)
    end
  end

  def self.process_title(title, browser)
    search_box = browser.text_field('data-uia' => 'search-box-input')
    browser.button(class: 'searchTab').click unless search_box.present?
    search_box.set(title.name)
    result_id = 'title-card-0-0'
    wait_for_div(result_id, browser)
    show_details(browser, result_id)
    process_html(title, browser.html)
  rescue StandardError => e
    ap "Processing failed: #{e.message}"
    ap e.backtrace[0..9]
  end

  def self.show_details(browser, div_id)
    max_times = 3
    begin
      sleep 2
      try_to_show_details(browser, div_id)
      wait_for_genres(browser)
    rescue StandardError
      max_times -= 1
      ap "RETRY ##{3 - max_times}"
      browser.refresh
      retry unless max_times.zero?
    end
  end

  def self.try_to_show_details(browser, div_id)
    result = browser.div(id: div_id)
    result.hover if result.present?; sleep 1
    details_button = browser.li(id: 'tab-ShowDetails')
    browser.link(class: 'bob-jaw-hitzone').click unless details_button.present?
    sleep 1; details_button.click
  end

  def self.process_html(title, html)
    page = Nokogiri::HTML(html)
    check_result_and_update(title, page)
  end

  def self.check_result_and_update(title, page)
    title_data = scrape_title_data(page)
    if wrong_result?(title_data, title)
      ap 'Enter action'
      action = '' # gets.chomp
      return if action != 'y'
      correct_title_name(title_data, title)
    end
    update_title(title, title_data)
  end

  def self.update_title(title, title_data)
    genres = get_genres(title_data[:genres])
    title.genres = genres unless genres.blank?
    title.update(code: title_data[:code])
  end

  def self.correct_title_name(title_data, title)
    return if NetflixTitle.find_by(name: title_data[:name])
    title.name = title_data[:name]
    title.save
  end

  def self.scrape_title_data(page)
    {
      genres: scrape_title_genres(page),
      name: scrape_title_name(page),
      code: scrape_title_code(page)
    }
  end

  def self.scrape_title_genres(page)
    page.xpath('//h4[text()="Géneros"]
                /following-sibling::ul/li/a')
        .map do |l|
          {
            id: l.at_xpath('./@href').content.split('/').last,
            name: l.content
          }
        end
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

  def self.get_genres(genres_data)
    genres = []
    genres_data.each do |genre_data|
      genre = Genre.create_with(name: genre_data[:name])
                   .find_or_create_by(id: genre_data[:id])
      genres << genre
    end
    genres
  end

  def self.wait_for_div(div_id, browser, max_time = 5)
    max_time.times do
      return if browser.div(id: div_id).present?
      sleep 1
    end
  end

  def self.wait_for_genres(browser, max_time = 5)
    max_time.times do
      return if browser.div(class: 'detailsTags').present?
      sleep 1
    end
    raise StandardError.new, 'No genres loaded'
  end

  def self.wrong_result?(title_data, title)
    ap "Found #{title_data[:name]}/ Expected #{title.name}[#{title.id}]"
    return title_data[:code] != title.code if title.code.present?
    !title_data[:name].casecmp(title.name).zero?
  end
end
