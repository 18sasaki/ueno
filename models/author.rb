
class Author < ActiveRecord::Base
  def self.get_all(sort_params='')
    order_str = case sort_params
                when 'i' then 'initial'
                when 's' then 'sex, name_kana'
                when 'k' then 'name_kana'
                else          ''
                end
    Author.all.order(order_str)
  end
end
