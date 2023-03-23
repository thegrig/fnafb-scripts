#==============================================================================
# * grig's inventory save script v0.0.0
#==============================================================================
#   * this script lets you save and load the player's inventory
#     using script calls
#==============================================================================
# CALLS:
#     - inven_save(type)      this saves the current player inventory.
#                             "type" refers to the type of inventory you
#                             want to save.
#
#     - inven_load(type)      this loads the saved inventory, overwriting
#                             the current one in the process.
#
#     - inven_nuke(type)      this purges the current player inventory.
#                             use with caution.
#
#     - print_invfo           this prints the "invfo" (inventory info)
#                             to the debug console.
#------------------------------------------------------------------------------
# TYPES:
#     - "all"                 items, armors, and weapons.
#     - "items"               items.
#     - "armors"              armors.
#     - "weapons"             weapons.
#     - "equip"               armors and weapons.
#------------------------------------------------------------------------------
# EXAMPLES:
#     - inven_save("all")     saves the entire inventory.
#     - inven_load("items")   loads all saved items.
#     - inven_nuke("weapons") removes all weapons from the inventory.
#==============================================================================
module InvenGrig
  Debug_Print   =   false #if true, will print info to debug console.
  Debug_Detail  =   false #if true, calls "print_invfo" when a script call is used.
end
#==============================================================================
# * end of things you probably care about.
#==============================================================================

class Game_Party
  attr_accessor :saved_items
  attr_accessor :saved_armors
  attr_accessor :saved_weapons
  
  alias :initialize_invgrig :initialize
  def initialize
    initialize_invgrig
    @saved_items    =  {}
    @saved_armors   =  {}
    @saved_weapons  =  {}
  end
  
  def print0
    return InvenGrig::Debug_Print
  end
  
  def print1
    return InvenGrig::Debug_Detail
  end
  
  def printInfo
    puts "#==================================="
    puts "# Saved Items: "  + @saved_items.to_s
    puts "#-----------------------------------"
    puts "# Saved Armors: " + @saved_armors.to_s
    puts "#-----------------------------------"
    puts "# Saved Weapons: "+ @saved_weapons.to_s
    puts "#==================================="
    puts "# Current Items: "  + @items.to_s
    puts "#-----------------------------------" 
    puts "# Current Armors: " + @armors.to_s
    puts "#-----------------------------------"
    puts "# Current Weapons: " + @weapons.to_s
    puts "#==================================="
    puts ""
  end
  
  def inven_save(type)
    case type
    when "items"
      @saved_items = item_container(RPG::Item).clone
      puts "Items Saved." if print0
    when "armors"
      @saved_armors = item_container(RPG::Armor).clone
      puts "Armors Saved." if print0
    when "weapons"
      @saved_weapons = item_container(RPG::Weapon).clone
      puts "Weapons Saved." if print0
    when "all"
      @saved_items = item_container(RPG::Item).clone
      @saved_armors = item_container(RPG::Armor).clone
      @saved_weapons = item_container(RPG::Weapon).clone
      puts "Inventory Saved." if print0
    end
    printInfo if print1
  end
  
  def inven_load(type)
    inven_nuke(type)
    case type
    when "items"
      @items = @saved_items.clone
      puts "Items Loaded." if print0
    when "armors"
      @armors = @saved_armors.clone
      puts "Armors Loaded." if print0
    when "weapons"
      @weapons = @saved_weapons.clone
      puts "Weapons Loaded." if print0
    when "all"
      @items = @saved_items.clone
      @armors = @saved_armors.clone
      @weapons = @saved_weapons.clone
      puts "Inventory Loaded." if print0
    end
    printInfo if print1
  end
  
  def inven_nuke(type)
    case type
    when "items"
      @items = {}
      puts "Items Cleared." if print0
    when "armors"
      @armors = {}
      puts "Armors Cleared." if print0
    when "weapons"
      @weapons = {}
      puts "Weapons Cleared." if print0
    when "all"
      @items = {}
      @armors = {}
      @weapons = {}
      puts "Inventory Cleared." if print0
    end
    printInfo if print1
  end
  
  def inven_load_f(type)
    inven_nuke(type)
    inven_load(type)
  end
end

class Game_Interpreter
  def inven_save(type)
    $game_party.inven_save(type)
  end
  
  def inven_load(type)
    $game_party.inven_load_f(type)
  end
  
  def inven_nuke(type)
    $game_party.inven_nuke(type)
  end
  
  def print_invfo
    $game_party.printInfo
  end
end
