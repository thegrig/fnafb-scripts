$imported = {} if $imported.nil?
$imported['GrigCrits'] = true

puts 'Fancy Critical Hits by Grig'

module GRIGCRIT
  module CRITSFX
    CritSound = "eb_smash"
    CritPause = false
    CritShake = true
    ShakePow = 5
    ShakeSpd = 20
    ShakeDur = 5
    
    def self.screen
      $game_party.in_battle ? $game_troop.screen : $game_map.screen
    end
    
    def self.playCrit
      RPG::SE.new(CritSound, 100, 100).play
    end
    
    def self.shake
      screen.start_shake(ShakePow, ShakeSpd, ShakeDur)
    end
  end
end

class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # * Display Critical Hit
  #--------------------------------------------------------------------------
  alias grig_display_critical display_critical
  def display_critical(target, item)
    if target.result.critical
      GRIGCRIT::CRITSFX.playCrit
      GRIGCRIT::CRITSFX.shake
      text = target.actor? ? Vocab::CriticalToActor : Vocab::CriticalToEnemy
      add_text(text)
      if GRIGCRIT::CRITSFX::CritPause == true
        wait
      end
    end
  end
end