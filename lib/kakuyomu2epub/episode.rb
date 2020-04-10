require "nokogiri"

module Kakuyomu2Epub
  class Episode
    attr_reader :title, :path, :id, :datetime, :body

    def initialize(title, path, datetime)
      @title = title
      @path = path
      @id = path.split("/").last
      @datetime = datetime
    end

    def parse(html_path)
      html = File.read(html_path)
      doc = Nokogiri::HTML.parse(html, nil, nil)

      paragraphs = [[]]
      doc.at_css(".widget-episodeBody").css("p").each do |node|
        if node["class"] == "blank"
          paragraphs.push([])
        else
          paragraphs.last.push(node.inner_html)
        end
      end

      if paragraphs.last == []
        paragraphs.pop
      end


      paragraphs.map! do |para|
        inner_html = para.join("<br />")
        "<p>#{inner_html}</p>"
      end

      @body = paragraphs.join
    end

    def tocdata(link)
      {
        link: [link, @id].join("#"),
        text: @title,
        level: 3
      }
    end

    def html
      <<~EOS
        <h3 id="#{@id}">#{@title}</h3>
        #{@body}
      EOS
    end
  end
end
