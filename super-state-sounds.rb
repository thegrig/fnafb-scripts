module GStSfx
#==============================================================================
# * grig's super state sounds script v1.0.0
#==============================================================================
#   * this script allows you to set a sound to play when a good or bad state
#     is applied to a battler. this sound is played when the message log shows
#     that the state was applied.
#==============================================================================
# * HOW TO USE:
#
#   use the notetags below, and configure the BSfx and GSfx variables below.
#==============================================================================
# * TAGS:
#==============================================================================
# <bad_state>
# when used, causes it to play the bad state sound (BSfx) when said state is
# applied to a battler.
#
#------------------------------------------------------------------------------
# <good_state>
# when used, causes it to play the good state sound (GSfx) when said state is
# applied to a battler. the <bad_state> tag will be ignored if this one is
# applied to a state.
#
#------------------------------------------------------------------------------
# <custom_sfx: n, v, p>
# when used, causes it to play a custom sound when said state is applied to a
# battler. the format is n = name, v = volume, and p = pitch. the other two
# tags will be ignored if this one is applied to a state for obvious reasons.
#
# EXAMPLE: <custom_sfx: "funny_noise", 90, 100>
#
#==============================================================================
# * AWESOME VARIABLES!!!
#==============================================================================
  BSfx  = ["battle_status0",90,100] #name, volume, pitch
  GSfx  = ["battle_status1",90,100] #name, volume, pitch
#==============================================================================
# * this concludes the AWESOME VARIABLES!!!.
#==============================================================================
# * OVERWRITTEN METHODS:
#   - display_added_states;  Window_BattleLog
#==============================================================================
end
#==============================================================================
# * the everything else
#==============================================================================
module DataManager
  class <<self; alias load_database_stsfx load_database; end
  def self.load_database
    load_database_stsfx
    load_notetags_stsfx
  end

  def self.load_notetags_stsfx
    groups = [$data_states]
    for group in groups
      for obj in group
        next if obj.nil?
        obj.load_notetags_stsfx
      end
    end
  end
end

class RPG::State < RPG::BaseItem
  attr_accessor   :morality
  attr_accessor   :custom_sfx

  def load_notetags_stsfx
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when /<bad_state>/
        @morality = 1
      when /<good_state>/
        @morality = 2
      when /<custom_sfx:[ ]"(.+)",[ ](\d+),[ ](\d+)>/
        @custom_sfx = []
        @custom_sfx.push($1.to_s, $2.to_i, $3.to_i)
        puts "Custom SFX: " + @custom_sfx.to_s
      end
    }
  end
  
  def get_morality
    res = self.morality
    res = 0 if res.nil?
    return res
  end
end

class Window_BattleLog < Window_Selectable
  def display_added_states(target)
    target.result.added_state_objects.each do |state|
      state_msg = target.actor? ? state.message1 : state.message2
      target.perform_collapse_effect if state.id == target.death_state_id
      next if state_msg.empty?
      if state.get_morality == 1 && state.custom_sfx.nil?
        RPG::SE.new(GStSfx::BSfx[0], GStSfx::BSfx[1], GStSfx::BSfx[2]).play
      elsif state.get_morality == 2 && state.custom_sfx.nil?
        RPG::SE.new(GStSfx::GSfx[0], GStSfx::GSfx[1], GStSfx::GSfx[2]).play
      elsif !state.custom_sfx.nil?
        sfx = state.custom_sfx
        RPG::SE.new(sfx[0], sfx[1], sfx[2]).play
      end
      replace_text(target.name + state_msg)
      wait
      wait
      wait_for_effect
    end
  end
end
