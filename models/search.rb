#coding: utf-8

class Search
  extend RaiseCatch

  def self.get_result_hash(type, *params)
    data_list = case type
                when :isbn  then search_by_isbn(*params)
                when :title then search_by_title(*params)
                end

    if data_list.present?
      { data_list: data_list }
    else
      { error: '該当する書籍が見つかりませんでした' }
    end
  end

  def self.search_by_isbn(isbn_str)
    item = Amazon::Ecs.item_lookup(isbn_str,
                                   { IdType: 'ISBN',
                                     SearchIndex: 'Books',
                                     ResponseGroup: 'ItemAttributes'}).first_item
    item ? [ make_data_hash(item) ] : []
  end

  def self.search_by_title(title_str)
    items = Amazon::Ecs.item_search(title_str,
                                    { search_index: 'Books',
                                      response_group: 'ItemAttributes'}).items
    items.map{ |item| make_data_hash(item) }
  end

  def self.make_data_hash(item)
    if item
      title, label = make_title_and_label(item.get('ItemAttributes/Title'))
      isbn = item.get('ItemAttributes/ISBN')
      registered_book = Book.get_by_isbn(isbn)
      {
        isbn:             isbn,
        title:            title,
        author_name:      item.get('ItemAttributes/Author'),
        label_name:       label,
        registered_title: registered_book.try(:name)
      }
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
