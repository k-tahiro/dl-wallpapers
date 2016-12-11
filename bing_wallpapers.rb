require 'open-uri'
require 'FileUtils'
require 'nokogiri'
require 'capybara'
require 'capybara/poltergeist'

def save_image(url, category)
    fileName = File.basename(url)
    dirName = './images/' + category + '/'
    filePath = dirName + fileName
    FileUtils.mkdir_p(dirName) unless FileTest.exist?(dirName)
    open(filePath, 'wb') do |output|
        open(url) do |data|
	        output.write(data.read)
	    end
    end
end

#poltergistの設定
Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, {:js_errors => false, :timeout => 1000 }) #追加のオプションはググってくださいw
end
Capybara.default_selector = :css
session = Capybara::Session.new(:poltergeist)
#自由にUser-Agent設定してください。
session.driver.headers = { 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X)' } 
session.visit 'http://www.bing.com/gallery/'

expand_button = session.find('#categories > div.sectionBar > div.expandButton.kbSelect')
expand_button.click
base_page = Nokogiri::HTML.parse(session.html)

base_page.css('#categories > ul > li.choice.kbSelect').each_with_index{|li,i|
    label = li.css('.label').text
    label_link = session.find(li.css_path)
    label_link.click
    sleep (1)
    category_page = Nokogiri::HTML.parse(session.html)

    index = 0
    loop {
        image_div = category_page.css('#grid > .tile.kbSelect')[index]
        if image_div.nil?
            break
        end
        image_link = session.find(image_div.css_path)
        image_link.click
        sleep (1)
        detail_page = Nokogiri::HTML.parse(session.html)

        image_url = 'http:' + detail_page.css('.detailImage').attribute('src').text
        save_image(image_url, label)

        close_link = session.find('#detailInner > div > div.detailClose.kbSelect')
        close_link.click
        sleep (1)
        category_page = Nokogiri::HTML.parse(session.html)

        index += 1
    }

    label_link.click
    sleep (1)
}
