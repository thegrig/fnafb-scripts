#==============================================================================
#  Easy Force Action by grig
#==============================================================================
#   Basically i took the code for the interpreter's force action and made it
# into a method you can easily call with a simple and easy to understand
# script call. I made this because finding out how to use a force action script
# call feels like some weird taboo topic, given how little info I could find.
#
#   I found out how to use the interpreter's version of force action, and so
# now you can use it, too. I also added the ability to force items!
#
# Credit grig, I guess.
#==============================================================================
# HOW TO USE:
# Use the script call:  force_action(Type, User, Skill, Target, Item)
# - Type is 0 if the user is an Enemy, and 1 if the user is an Actor.
# - User is the user's troop index, or actor id.
#   (troop indexes start at 0)
# - Skill is the ID of the skill/item you're trying to force.
# - Target works like User, but for the skill's target.
#   If you want to target randomly, use -1. If you want last target, use -2.
# - Item is 0 if you're using a Skill, but 1 if you're using an Item.
#==============================================================================
# NOTES:
# - The game appears to determine whether to target an actor or an enemy based
#  on the skill's scope. This means you can't attack an ally or use a healing
#  item on an enemy, by default.
#
# - Forcing items hasn't been extensively tested, but should work just fine.
#
# - Yes, this does mean you can make enemies use items. It's weird!
#==============================================================================
# EXAMPLES:
# force_action(1, 3, 1, 0, 0) = Actor 3 uses Skill 1 on Enemy A/Party Leader
#
# force_action(0, 2, 4, 1, 1) = Enemy C uses Item 4 on Enemy B/2nd Party Member
#
#==============================================================================
class Game_Interpreter
  def force_action(type, user, skill, target, item)
    iterate_battler(type, user) do |battler|
    next if battler.death_state?
    battler.force_action(skill, target) if item == 0
    battler.force_item(skill, target) if item == 1
    BattleManager.force_action(battler)
    Fiber.yield while BattleManager.action_forced?
    end
  end
end

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # * Force Item
  #--------------------------------------------------------------------------
  def force_item(item_id, target_index)
    clear_actions
    action = Game_Action.new(self, true)
    action.set_item(item_id)
    if target_index == -2
      action.target_index = last_target_index
    elsif target_index == -1
      action.decide_random_target
    else
      action.target_index = target_index
    end
    @actions.push(action)
  end
end