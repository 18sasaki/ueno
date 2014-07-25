#coding: utf-8

class Search
  extend RaiseCatch

  def self.search_by_isbn(isbn_str)
    begin
      item = Amazon::Ecs.item_lookup(isbn_str, {IdType: 'ISBN', SearchIndex: 'Books', ResponseGroup: 'ItemAttributes'}).first_item
    rescue SocketError => e
      p ">>>>>>>>>>>>> error : #{e}"
      return { error: 'amazonへの問い合わせ中にエラーが発生しました' }
    rescue => e
      p ">>>>>>>>>>>>> error : #{e}"
      return { error: 'エラーが発生しました' }
    end

    if item
      title, label = make_title_and_label(item.get('ItemAttributes/Title'))
      isbn = item.get('ItemAttributes/ISBN')
      registered_book = Book.get_by_isbn(isbn)
      {
        isbn:             isbn,
        title:            title,
        author_name:      item.get('ItemAttributes/Author'),
        label_name:       label,
        registered_title: (registered_book ? registered_book.name : nil)
      }
    else
      { error: '該当する書籍が見つかりませんでした' }
    end
  end

  def self.make_title_and_label(amazon_title)
    amazon_title =~ /^(.+)\(([^\)]+)\)$/
    return $1, $2
  end

  def self.get_author_id(name)
    author_data = Author.find_by_name(name.gsub(/\s/, ''))

    # 同姓同名はいないものとする
    author_data.id if author_data
  end

  def self.get_label_id(name)
    label_data = Label.find_by_name(name.gsub(/\s/, ''))

    # 同名社はないものとする
    label_data.id if label_data
  end
end
