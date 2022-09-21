class Market
  attr_reader :name, 
              :vendors
              

  def initialize(name)
    @name = name 
    @vendors = []
  end

  def add_vendor(vendor)
    vendors << vendor
  end

  def vendor_names
    vendors.map do |vendor|
      vendor.name
    end
  end

  def vendors_that_sell(item)
    vendors.find_all do |vendor|
      vendor.check_stock(item) > 0
      # vendor.inventory.include?(item)
    end
  end

  def total_inventory
    item_list = inventory_list 
    inventory_hash = Hash.new(0)
    item_list.each do |item|
      inventory_hash[item] = { quantity: total_item(item), 
                               vendors: vendors_that_sell(item) }
    end
    inventory_hash
  end

  def total_item(item)
    quantity_avail = 0
    vendors.each do |vendor|
      quantity_avail += vendor.check_stock(item)
    end
    quantity_avail
  end

  def inventory_list
    list = []
    vendors.each do |vendor|
      list << vendor.inventory.keys
    end
    list.flatten.uniq
  end

  def overstocked_items
    total_inventory.select do |item, details|
      details[:quantity] > 50 && details[:vendors].count >= 2
    end.keys
  end

  def sorted_item_list
    total_inventory.keys.map do |item|
      item.name
    end.sort
  end

  def date 
    # date = Date.today.to_s
    # "#{date[8..9]}/#{date[5..6]}/#{date[0..3]}"
    Date.today.strftime('%d/%m/%Y')
  end

  def sell(item, quantity)
    return false if sorted_item_list.none?(item.name)
    return false if total_inventory[item][:quantity] < quantity

    total_inventory[item][:vendors].each do |vendor|
      if vendor.inventory[item] < quantity
        quantity -= vendor.inventory[item]
        vendor.inventory[item] = 0
      else
        vendor.inventory[item] -= quantity
        break
      end
    end
    true
  end

end