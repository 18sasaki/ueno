

class Search < ActiveRecord::Base
  extend RaiseCatch

  def self.search_by_isbn(isbn_str)
    item = Amazon::Ecs.item_lookup(isbn_str, {IdType: 'ISBN', SearchIndex: 'Books'}).first_item

    {
      isbn:      isbn_str,
      title:     item.get('ItemAttributes/Title'),
      author:    item.get('ItemAttributes/Author'),
      publisher: item.get('ItemAttributes/Manufacturer')
    }
  end
end
