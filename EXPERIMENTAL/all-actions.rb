module AllAction
#==============================================================================
# * grig's all actions script
#==============================================================================
# * allows you to set actor skills to use every action. meaning if actors
#   have 2 actions, you can make a skill use them all, instead of allowing
#   them to use 2 actions that turn. same goes for... 200 actions.
#==============================================================================
# * Config
#==============================================================================
  ActArray = [2,3]
# any skill you put in this array will use all actor actions.
#==============================================================================
# * everything else
#==============================================================================
end

module BattleManager
  include AllAction
  def self.next_command
    all_action = false
    if actor
      for i in actor.actions
        next if i.item.nil?
        if i && ActArray.include?(i.item.id) && i.item.is_a?(RPG::Skill)
          actor.actions.clear
          action = Game_Action.new(actor, false)
          action.set_skill(i.item.id)
          actor.actions.push(action)
          all_action = true
          break
        end
      end
    end
    begin
      if !actor || !actor.next_command || all_action
        @actor_index += 1
        return false if @actor_index >= $game_party.members.size
      end
    end until actor.inputable?
    return true
  end
end

class Game_Battler
  include AllAction
  alias :make_speed_allact :make_speed
  def make_speed
    make_speed_allact
    all_action = false
    if actor?
      for i in @actions
        next if i.item.nil?
        if i && ActArray.include?(i.item.id) && i.item.is_a?(RPG::Skill)
          all_action = true
          actid = i.item.id
          break
        end
      end
    end
    @speed = $data_skills[actid].speed if all_action
  end
end
