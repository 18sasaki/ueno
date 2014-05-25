
class Search
  extend RaiseCatch

  def self.search_by_isbn(isbn_str)
    item = Amazon::Ecs.item_lookup(isbn_str, {IdType: 'ISBN', SearchIndex: 'Books', ResponseGroup: 'ItemAttributes'}).first_item

    {
      isbn_str:       isbn_str,
      isbn:           item.get('ItemAttributes/ISBN'),
      title:          item.get('ItemAttributes/Title'),
      author_name:    item.get('ItemAttributes/Author'),
      publisher_name: item.get('ItemAttributes/Manufacturer')
    }
  end

  def self.get_author_id(name)
    author_data = Author.find_by_name(name.gsub(/\s/, ''))

    # 同姓同名はいないものとする
    author_data.id if author_data
  end

  def self.get_publisher_id(name)
    publisher_data = Publisher.find_by_name(name.gsub(/\s/, ''))

    # 同名社はないものとする
    publisher_data.id if publisher_data
  end
end
