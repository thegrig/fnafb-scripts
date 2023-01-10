#-------------------------------------------------------------------------------
# Credit grig or you will be disintegrated instantly.
#
# Use the notetag <anim: x> in an Actor/Enemy's notes.
# x = the animation id you want.
# If no animation is defined this way, weapon animations take priorty, and for
# enemies, no animation will play.
#
# Use the notetag <anim_skill: x y> in an Actor/Enemy's notes.
# x = the skill id, and y = the animation id you want.
# If no animation is defined this way, skill animations take priority.
#-------------------------------------------------------------------------------
module RPG
class Actor < BaseItem

  def alt_anim
    return @alt_anim unless @alt_anim.nil?
    load_notetag_actor_alt_anim
    return @alt_anim
  end
  
  def load_notetag_actor_alt_anim
    regex = /<anim:[ ](\d+)>/
    @alt_anim = self.note
  end
end

class Enemy < BaseItem

  def alt_anim
    return @alt_anim unless @alt_anim.nil?
    load_notetag_enemy_alt_anim
    return @alt_anim
  end
  
  def load_notetag_enemy_alt_anim
    regex = /<anim:[ ](\d+)>/
    @alt_anim = self.note
  end
end
end

class Game_Actor < Game_Battler
  alias grig_actor_animation atk_animation_id1
  
  def atk_animation_id1
    if dual_wield?
      return weapons[0].animation_id if weapons[0]
      return weapons[1] ? 0 : 1
    elsif $data_actors[actor.id].alt_anim =~ /<anim:[ ](\d+)>/
      return $1.to_i
    else
      #puts "Anim: " + $data_actors[actor.id].alt_anim.to_s
      return weapons[0] ? weapons[0].animation_id : 1
    end
    grig_actor_animation
  end
  
end

class Scene_Battle < Scene_Base
  alias grig_enemy_animation show_attack_animation
  
  def show_attack_animation(targets)
    if @subject.actor?
      show_normal_animation(targets, @subject.atk_animation_id1, false)
      show_normal_animation(targets, @subject.atk_animation_id2, true)
    elsif $data_enemies[@subject.enemy_id].alt_anim =~ /<anim:[ ](\d+)>/
      show_normal_animation(targets, $1.to_i, false)
    else
      Sound.play_enemy_attack
      abs_wait_short
    end
  end
  
  alias grig_use_item use_item
  
  def use_item
    item = @subject.current_action.item
    @log_window.display_use_item(@subject, item)
    #puts @subject
    @subject.use_item(item)
    refresh_status
    targets = @subject.current_action.make_targets.compact
    show_animation(targets, item.animation_id)
    targets.each {|target| item.repeats.times { invoke_item(target, item) } }
  end
  
  alias grig_show_animation show_animation
  
  def show_animation(targets, animation_id)
    #puts @subject.current_action
    item2 = @subject.current_action.item
    if item2.animation_id < 0
      show_attack_animation(targets)
    elsif @subject.actor? && $data_actors[@subject.id].note =~ /<anim_skill:[ ](\d+)[ ](\d+)>/
      if @subject.actor? && $1.to_i == item2.id && item2 == RPG::Skill
        show_normal_animation(targets, $2.to_i)
      else
        show_normal_animation(targets, animation_id)
      end
    elsif @subject.enemy? && $data_enemies[@subject.enemy_id].note =~ /<anim_skill:[ ](\d+)[ ](\d+)>/
      if @subject.enemy? && $1.to_i == item2.id && item2.class == RPG::Skill
        show_normal_animation(targets, $2.to_i)
      else
        show_normal_animation(targets, animation_id)
      end
    else
      show_normal_animation(targets, animation_id)
    end
    @log_window.wait
    wait_for_animation
  end
end