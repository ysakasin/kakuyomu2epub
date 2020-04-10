require "nokogiri"

module Kakuyomu2Epub
  class Index
    def self.parse(html_path)
      index = Index.new(html_path)
      index.parse

      index
    end

    attr_reader :title, :author, :sections, :episodes
    def initialize(html_path)
      html = File.read(html_path)
      @doc = Nokogiri::HTML.parse(html, nil, nil)

      @chapters = []
      @sections = []
      @episodes = []
    end

    def parse
      @title = @doc.at_css("#workTitle").inner_text
      @author = @doc.at_css("#workAuthor-activityName").inner_text

      items = @doc.at_css("ol.widget-toc-items")
      # p items

      items.children.each do |node|
        if node.classes.include?("widget-toc-level1")
          add_chapter(node)
        elsif node.classes.include?("widget-toc-level2")
          add_section(node)
        elsif node.classes.include?("widget-toc-episode")
          add_episode(node)
        end
      end
    end

    def tocdata
      @sections.map(&:tocdata).inject([], :+)
    end

    private

    def add_chapter(node)
      @chapter = Chapter.new(node.inner_text.strip)
      @chapters.push(@chapter)
    end

    def add_section(node)
      @section = Section.new(node.inner_text.strip)
      @chapter.push(@section)
      @sections.push(@section)
    end

    def add_episode(node)
      title = node.at_css(".widget-toc-episode-titleLabel").inner_text.strip
      href = node.at_css("a")["href"]
      datetime = node.at_css(".widget-toc-episode-datePublished")["datetime"]
      episode = Episode.new(title, href, datetime)

      @section.push(episode)
      @episodes.push(episode)
    end

    class Chapter
      attr_reader :title, :sections
      def initialize(title)
        @title = title
        @sections = []
      end

      def push(section)
        if @sections.empty?
          section.chapter_title = @title
        end
        @sections.push(section)
      end
    end
  end
end
