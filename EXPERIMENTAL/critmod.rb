#==============================================================================
# * grig critmod script
#==============================================================================
#   * this script lets you define a skill's crit mod with notetags.
#     if no critmod is set, it uses the default, instead.
#     you can also set the default.
#==============================================================================
# * INCOMPATIBILITIES:
#     - probably will not like anything that changes the damage formula, and
#       anything that does so will also likely not like this script.
#==============================================================================
# TAGS:
#     - <critmod: MOD>      gives skill/item a crit mod of MOD.
#                           MOD needs to be a decimal (2.0 = x2)
#==============================================================================
module CritMod
  DefaultMod = 2  #The default critical hit modifier. 3 is the Maker default.
end
#==============================================================================
# * end of things you probably care about.
#==============================================================================
module DataManager
  class <<self; alias load_database_crit load_database; end
  def self.load_database
    load_database_crit
    load_notetags_crit
  end

  def self.load_notetags_crit
    groups = [$data_skills, $data_items]
    for group in groups
      for obj in group
        next if obj.nil?
        obj.load_notetags_crit
      end
    end
  end
end
  
class RPG::UsableItem < RPG::BaseItem
  attr_reader   :critmod
  
  def load_notetags_crit
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when /<critmod:[ ](\d+[.]\d+)>/
        @critmod = $1.to_f
        puts "Critmod: " + @critmod.to_s
      end
    }
  end
end

class Game_Battler
#--------------------------------------------------------------------------
# * Calculate Damage
#--------------------------------------------------------------------------
  def make_damage_value(user, item)
    value = item.damage.eval(user, self, $game_variables)
    value = [[value, 99].min, 1].max if !item.damage.recover?
    value *= item_element_rate(user, item)
    value *= pdr if item.physical?
    value *= mdr if item.magical?
    value *= rec if item.damage.recover?
    if item.critmod.nil?
      value = apply_critical(value) if @result.critical
    else
      value = apply_critmod(value, item.critmod)  if @result.critical
    end
    value = apply_variance(value, item.damage.variance)
    value = apply_guard(value)
    value = [[value, 99].min, 1].max if !item.damage.recover?
    @result.make_damage(value.to_i, item)
  end
  
  def apply_critical(damage)
    damage * 2
  end
  
  def apply_critmod(damage, critmod)
    damage * critmod
  end
end
