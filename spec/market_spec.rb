require 'date'
require './lib/item'
require './lib/vendor'
require './lib/market'

RSpec.describe Market do
  before(:each) do
    @market = Market.new("South Pearl Street Farmers Market")
    @vendor1 = Vendor.new("Rocky Mountain Fresh")
    @vendor2 = Vendor.new("Ba-Nom-a-Nom")
    @vendor3 = Vendor.new("Palisade Peach Shack")
    @item1 = Item.new({name: 'Peach', price: "$0.75"})
    @item2 = Item.new({name: 'Tomato', price: "$0.50"})
    @item3 = Item.new({name: "Peach-Raspberry Nice Cream", price: "$5.30"})
    @item4 = Item.new({name: "Banana Nice Cream", price: "$4.25"})
    @item5 = Item.new({name: 'Onion', price: '$0.25'})
  end

    it 'exists' do 
      expect(@market).to be_a Market
    end

    it 'has attribues' do 
      expect(@market.name).to eq("South Pearl Street Farmers Market")
      expect(@market.vendors).to eq([])
    end

  describe '#add_vendor' do
    it 'adds a vendor to the market vendor array' do
      @market.add_vendor(@vendor1)
      @market.add_vendor(@vendor2)
      @market.add_vendor(@vendor3)
      expect(@market.vendors).to eq([@vendor1, @vendor2, @vendor3])
    end

    it 'the vendors can have an inventory' do
      @vendor1.stock(@item1, 35)
      @vendor1.stock(@item2, 7)
      expect(@vendor1.inventory).to eq({ @item1 => 35, @item2 => 7 })
      
      @vendor2.stock(@item4, 50)
      @vendor2.stock(@item3, 25)
      expect(@vendor2.inventory).to eq({ @item4 => 50, @item3 => 25 })
      
      @vendor3.stock(@item1, 65)
      expect(@vendor3.inventory).to eq({ @item1 => 65 })
    end
  end

  describe '#vendor_names' do 
    it 'returns an arrary of the vendors names' do 
      @market.add_vendor(@vendor1)
      @market.add_vendor(@vendor2)
      @market.add_vendor(@vendor3)
      expect(@market.vendors).to eq([@vendor1, @vendor2, @vendor3])
      expect(@market.vendor_names).to eq([@vendor1.name, @vendor2.name, @vendor3.name])
    end
  end

  describe '#vendors_that_sell(item)' do 
    it 'returns an array of vendors that sell a particular item' do
      @market.add_vendor(@vendor1)
      @vendor1.stock(@item1, 35)
      @vendor1.stock(@item2, 7)
      @market.add_vendor(@vendor2)
      @vendor2.stock(@item4, 50)
      @vendor2.stock(@item3, 25)
      @market.add_vendor(@vendor3)
      @vendor3.stock(@item1, 65)

      expect(@market.vendors_that_sell(@item1)).to eq([@vendor1, @vendor3])
      expect(@market.vendors_that_sell(@item4)).to eq([@vendor2])
    end
  end

  describe '#total_inventory' do 
    it 'returns a hash of market items as keys and a sub-hash as
        values. sub-hash should have two key-value pairs
        quantity pointing to total inventory for that item and 
        vendors pointing to an array of vendors that sell that item' do
          @market.add_vendor(@vendor1)
          @vendor1.stock(@item1, 35)
          @vendor1.stock(@item2, 7)
          @market.add_vendor(@vendor2)
          @vendor2.stock(@item4, 50)
          @vendor2.stock(@item3, 25)
          @market.add_vendor(@vendor3)
          @vendor3.stock(@item1, 65)
          @vendor3.stock(@item3, 10)

          expected_hash = { 
            @item1 => { 
              quantity: 100, 
              vendors: [@vendor1, @vendor3] 
              },
            @item2 => { 
              quantity: 7, 
              vendors: [@vendor1] 
              },
            @item4 => { 
              quantity: 50, 
              vendors: [@vendor2] 
              },
            @item3 => { 
              quantity: 35, 
              vendors: [@vendor2, @vendor3] 
              }
          }

          expect(@market.total_inventory).to eq(expected_hash)
    end
  end

  describe '#overstocked_items' do 
    it 'returns overstocked items. an item is overstocked
        if it is sold by more than 1 vendor and the total
        quantity is greater than 50.' do
          @market.add_vendor(@vendor1)
          @vendor1.stock(@item1, 35)
          @vendor1.stock(@item2, 7)
          @market.add_vendor(@vendor2)
          @vendor2.stock(@item4, 50)
          @vendor2.stock(@item3, 25)
          @market.add_vendor(@vendor3)
          @vendor3.stock(@item1, 65)
          @vendor3.stock(@item3, 10)

        expect(@market.overstocked_items).to eq([@item1])
    end
  end

  describe '#sorted_item_list' do 
    it 'returns a list of names of all items the vendors have
        in stock, sorted alphabetically, no duplicates.' do 
          @market.add_vendor(@vendor1)
          @vendor1.stock(@item1, 35)
          @vendor1.stock(@item2, 7)
          @market.add_vendor(@vendor2)
          @vendor2.stock(@item4, 50)
          @vendor2.stock(@item3, 25)
          @market.add_vendor(@vendor3)
          @vendor3.stock(@item1, 65)
          @vendor3.stock(@item3, 10)

          expect(@market.sorted_item_list).to eq(["Banana Nice Cream", "Peach", "Peach-Raspberry Nice Cream", "Tomato"])
        end
  end

  describe '#date' do
    it 'return a date for the market' do 
      allow(Date).to receive(:today).and_return(Date.new(2022, 9, 20))
      expect(@market.date).to eq('20/09/2022')
    end
  end

  describe '#sell' do
    it 'returns false if the market does not have enough of the item 
        in stock to satisfy the given quantity, or returns true if the
        market has enough stock to satisfy the given quantity. Reduces the
        stock of the vendors in the order that the vendors were added.' do
          @vendor1.stock(@item1, 35)
          @vendor1.stock(@item2, 7)
          @vendor2.stock(@item4, 50)
          @vendor2.stock(@item3, 25)
          @vendor3.stock(@item1, 65)
          
          @market.add_vendor(@vendor1)
          @market.add_vendor(@vendor2)
          @market.add_vendor(@vendor3)
          
          expect(@market.sell(@item1, 200)).to eq(false)
          expect(@market.sell(@item5, 1)).to eq(false)
          expect(@market.sell(@item4, 5)).to eq(true)
          expect(@vendor2.check_stock(@item4)).to eq(45)
          expect(@market.sell(@item1, 40)).to eq(true)
          expect(@vendor1.check_stock(@item1)).to eq(0)
          expect(@vendor3.check_stock(@item1)).to eq(60)

        end
  end
end