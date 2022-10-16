require 'open-uri'
require 'nokogiri'
require 'date'

def scrape(url)
  serialized_html = URI.open(url).read
  doc = Nokogiri::HTML(serialized_html)

  # create new folder to store text + images
  date = doc.search('.bd--hd__date').text.split[0].split(".").join
  title = doc.search('.bd--hd h1').text.strip
  member = title.split(/　　*/)[-1]
  file_name = "#{member} #{date}"
  Dir.mkdir(file_name) unless Dir.exist?(file_name)

  save_txt(doc, file_name, title)
  save_pics(doc, file_name)
end

def save_txt(doc, file_name, title)
  text = doc.search('.bd--edit').text
  File.open("./#{file_name}/#{title}.txt","wb") do |f|
    f.write(title)
    f.write(text)
  end
end

def save_pics(doc, file_name)
  pics = doc.search('.bd--edit img').each do |pic|
    pic_url = pic.attribute("src").value
    URI.open("https://www.nogizaka46.com" + pic_url) do |image|
      File.open("./#{file_name}/#{pic_url.split("/")[-1]}","wb") do |file|
        file.write(image.read)
      end
    end
  end
end

puts "Enter the url"
url = gets.chomp
scrape(url)
