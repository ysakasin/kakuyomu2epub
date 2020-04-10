module Kakuyomu2Epub
  class Section
    def self.fetch_id
      @id ||= 0
      @id += 1
    end

    attr_reader :title, :id
    attr_writer :chapter_title

    def initialize(title)
      @title = title
      @id = self.class.fetch_id
      @episodes = []
      @chapter_title = nil
    end

    def push(episode)
      @episodes.push(episode)
    end

    def item_name
      "text/#{@id}.xhtml"
    end

    def item_name_section
      "text/#{@id}.xhtml##{@id}"
    end

    def xhtml
      <<~EOS
        <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja" lang="ja">
        <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <title>#{@title}</title>
        </head>
        <body>
        #{h1}
        #{h2}
        #{@episodes.map(&:html).join}
        </body>
        </html>
      EOS
    end

    def tocdata
      ret = []
      if @chapter_title
        ret.push({link: item_name, text: @chapter_title, level: 1})
      end

      ret.push({link: item_name_section, text: @title, level: 2})

      ret + @episodes.map {|e| e.tocdata(item_name)}
    end

    private

    def h1
      if @chapter_title
        "<h1>#{@chapter_title}</h1>"
      end
    end

    def h2
      "<h2 id=\"#{@id}\">#{@title}</h2>"
    end
  end
end
