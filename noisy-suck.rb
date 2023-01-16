#this script makes drain damage play a noise, instead of pure silence
#:)
#v1.1
module NOISYSUCK
  ActorHPDrainSE = ["Absorb1",100,100] #Name, Volume, Pitch
  ActorMPDrainSE = ["Absorb1",100,120]
  EnemyHPDrainSE = ["Absorb2",100,100]
  EnemyMPDrainSE = ["Absorb2",100,120]
  
  def self.play_actorHPDrain
    RPG::SE.new(ActorHPDrainSE[0],ActorHPDrainSE[1],ActorHPDrainSE[2]).play
  end
  
  def self.play_actorMPDrain
    RPG::SE.new(ActorMPDrainSE[0],ActorMPDrainSE[1],ActorMPDrainSE[2]).play
  end
  
  def self.play_enemyHPDrain
    RPG::SE.new(EnemyHPDrainSE[0],EnemyHPDrainSE[1],EnemyHPDrainSE[2]).play
  end
  
  def self.play_enemyMPDrain
    RPG::SE.new(EnemyMPDrainSE[0],EnemyMPDrainSE[1],EnemyMPDrainSE[2]).play
  end
end

class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # * Display HP Damage
  #--------------------------------------------------------------------------
  def display_hp_damage(target, item)
    return if target.result.hp_damage == 0 && item && !item.damage.to_hp? && !item.damage.drain?
    if target.result.hp_drain > 0
      target.suck_perform_damage_effect(1)
    elsif target.result.mp_drain > 0
      target.suck_perform_damage_effect(2)
    elsif target.result.hp_damage > 0
      target.perform_damage_effect
    else
    end
    Sound.play_recovery if target.result.hp_damage < 0
    add_text(target.result.hp_damage_text) if target.result.mp_drain == 0
    wait
  end
end

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # * Execute Damage Effect
  #--------------------------------------------------------------------------
  def suck_perform_damage_effect(type)
    $game_troop.screen.start_shake(5, 5, 10)
    @sprite_effect_type = :blink
    case type
      when 0
      Sound.play_actor_damage
      when 1
      NOISYSUCK.play_actorHPDrain
      when 2
      NOISYSUCK.play_actorMPDrain
      else
    end
  end
end

class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # * Execute Damage Effect
  #--------------------------------------------------------------------------
  def suck_perform_damage_effect(type)
    @sprite_effect_type = :blink
    case type
      when 0
      Sound.play_enemy_damage
      when 1
        NOISYSUCK.play_enemyHPDrain
      when 2
        NOISYSUCK.play_enemyMPDrain
      else
    end
  end
end
