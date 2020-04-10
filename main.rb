require_relative "lib/kakuyomu2epub"

novel = Kakuyomu2Epub::Novel.from_url("https://kakuyomu.jp/works/1177354054883808252")
puts novel.title
puts novel.author

novel.to_epub("iseniho.epub")
