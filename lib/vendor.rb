class Vendor 
  attr_reader :name,
              :inventory

  def initialize(name)
    @name = name
    @inventory = {}
  end

  def check_stock(item)
    return 0 if inventory[item] == nil
    inventory[item]
  end

  def stock(item, quantity)
    if inventory[item] == nil
      inventory[item] = quantity
    else inventory[item] += quantity
    end
  end
end