class Operation < Sequel::Model
  many_to_one :user
  one_to_many :products
end
