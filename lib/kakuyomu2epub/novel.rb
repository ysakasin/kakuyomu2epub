require "fileutils"
require "uri"
require 'gepub'

module Kakuyomu2Epub
  class Novel
    def self.from_url(url)
      novel = Novel.new(url)
      novel.parse
    end

    attr_reader :title, :author, :index

    def initialize(url)
      @url = url
      @id = url.split("/").last
      @cache_dir = File.join("cache", @id)
    end

    def parse
      FileUtils.makedirs(@cache_dir)

      path_index = File.join(@cache_dir, "index.html")
      fetch_html_if_absent(@url, path_index)

      @index = Index.parse(path_index)

      @title = @index.title
      @author = @index.author

      @index.episodes.each do |ep|
        url = URI.join(@url, ep.path)
        path = File.join(@cache_dir, "#{ep.id}.html")
        fetch_html_if_absent(url, path)

        ep.parse(path)
      end

      self
    end

    def to_epub(file_name)
      gbook = GEPUB::Book.new do |book|
        book.identifier = @url
        book.title = @title
        book.creator = @author
        book.language = 'ja'
      
        book.ordered do
          @index.sections.each do |section|
            book.add_item(section.item_name).add_content(StringIO.new(section.xhtml))
          end
        end

        book.add_tocdata(@index.tocdata())
      end
      
      gbook.generate_epub(file_name)
    end

    private

    def fetch_html_if_absent(url, path)
      unless File.exist?(path)
        `curl #{url} > #{path}`
        sleep(0.5)
      end
    end
  end
end
