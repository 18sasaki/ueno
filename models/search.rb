
class Search
  extend RaiseCatch

  def self.search_by_isbn(isbn_str)
    if item = Amazon::Ecs.item_lookup(isbn_str, {IdType: 'ISBN', SearchIndex: 'Books', ResponseGroup: 'ItemAttributes'}).first_item
      title, label = make_title_and_label(item.get('ItemAttributes/Title'))
      {
        isbn:        item.get('ItemAttributes/ISBN'),
        title:       title,
        author_name: item.get('ItemAttributes/Author'),
        label_name:  label
      }
    else
      {}
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
