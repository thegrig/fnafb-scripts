=begin
#==============================================================================
# * grig's map bgm control script
#==============================================================================
  for some reason it took me this long to make this script. i have needed it
  exactly two times already, and finally went and made it real.
#==============================================================================
# * what the fuck is this
#==============================================================================
  this a script that allows you to change the bgm track currently assigned to
  the overworld... FROM BATTLE!
  
  yes, that's right. if you needed a completely different song to be playing
  than the one that was playing on the map when a battle started, you can now
  make that happen seamlessly with script calls.
#==============================================================================
# * script calls!
#==============================================================================
  - set_map_bgm("name", volume, pitch)
      this call allows you to set the map bgm track from battle.
      i don't think i have to explain what these parameters mean. just make sure
      that the "name" parameter REMAINS in quotes.
      
  - clear_map_bgm
      this is basically just set_map_bgm's evil twin brother. rather than
      setting the bgm, it clears it, turning the overworld track to silence.
#==============================================================================
# * end of explanation
#==============================================================================
=end

module BattleManager
  def self.clear_map_bgm
    @map_bgm = RPG::BGM.new("", 0, 0)
  end
  
  def self.set_map_bgm(file, vol, pitch)
    @map_bgm = RPG::BGM.new(file, vol, pitch)
  end
end

class Game_Interpreter
  def clear_map_bgm
    return unless $game_party.in_battle
    BattleManager.clear_map_bgm
  end
  
  def set_map_bgm(file, vol, pitch)
    return unless $game_party.in_battle
    BattleManager.set_map_bgm(file, vol, pitch)
  end
end