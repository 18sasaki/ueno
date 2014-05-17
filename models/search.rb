

class Search < ActiveRecord::Base
  extend RaiseCatch

  def self.search_by_isbn(isbn_str)
    item = Amazon::Ecs.item_lookup(isbn_str, {IdType: 'ISBN', SearchIndex: 'Books', ResponseGroup: 'ItemAttributes'}).first_item

    {
      isbn_str:  isbn_str,
      isbn:      item.get('ItemAttributes/ISBN'),
      title:     item.get('ItemAttributes/Title'),
      author:    item.get('ItemAttributes/Author'),
      publisher: item.get('ItemAttributes/Manufacturer')
    }
  end
end
