#==============================================================================
# * grig's exp control script v0.0.0
#==============================================================================
# * this script gives you cool "equal exp" powers n stuff.
#==============================================================================
# CALLS:
#     - equal_leader(all?)        use this to make actor exp equal to the exp
#                                 of the current party leader. "all?" should
#                                 be true or false. if true, EVERY actor in
#                                 the game will be affected. else, only those
#                                 who are already in the party.
#
#     - equal_index(index, all?)  this sets the exp of actors to the exp of
#                                 the party member with the index provided.
#                                 index 0 = leader, index 1 = member 2, etc.
#                                 "all?" is the same as before.
#
#     - equal_actor(id, all?)     this sets the exp of actors to the exp
#                                 of the actor with the same id as the one in 
#                                 the call. "all?" is the same as before.
#
#     - equal_value(value, all?)  this sets the exp of actors to the exp
#                                 specified with "value". "all?" is the same
#                                 as before.
#------------------------------------------------------------------------------
# EXAMPLES:
#     - equal_leader(true)        all actors are set to the party leader's exp.
#     - equal_index(1, false)     all party members are set to member 2's exp.
#     - equal_actor(3, true)      all actors are set to actor 3's exp.
#     - equal_value(100, false)   all party members now have 100 exp.
#------------------------------------------------------------------------------
# NOTES:
#     - if you use equal_index without the appropriate party member present,
#       the game will crash. be careful.
#
#     - only equals exp. it CAN equal levels if every actor has the same exp
#       curve, but that's all up to you to do.
#==============================================================================
module XpCon
  SkipEmpty = true    #if true, "all?" will ignore nameless actors.
  ShowMsg   = false   #if true, will show level-up message when using the calls.
  AutoEqual = false   #if true, new members are given leader exp automatically.
  AutoEqAll = false   #"all?" but for auto equal.
#==============================================================================
# * ALIASED METHODS:
#   - command_129;  Game_Interpreter
#==============================================================================
# * end of things you probably care about.
#==============================================================================
  def self.skip(actor)
    return true if actor && actor.name.empty? && SkipEmpty else return false
  end
end

class Game_Interpreter
#------------------------------------------------------------------------------
# * Equal EXP (the base method)
#------------------------------------------------------------------------------
  def equal_exp(value, all)
    exp, show = value, XpCon::ShowMsg
#ALL = true
    if all
      $data_actors.each do |actor|
        skip = XpCon.skip(actor)
        $game_actors[actor.id].change_exp(exp, show) if actor && !skip
      end
    else
#ALL = false
      $game_party.members.each do |actor|
        skip = XpCon.skip(actor)
        $game_actors[actor.id].change_exp(exp, show) if actor && !skip
      end
    end
  end
#------------------------------------------------------------------------------
# * Equal Party Leader
#------------------------------------------------------------------------------
  def equal_leader(all)
    value = $game_party.members[0].exp
    equal_exp(value, all)
  end
#------------------------------------------------------------------------------
# * Equal Party Index
#------------------------------------------------------------------------------
  def equal_index(index, all)
    value = $game_party.members[index].exp
    equal_exp(value, all)
  end
#------------------------------------------------------------------------------
# * Equal Actor
#------------------------------------------------------------------------------
  def equal_actor(index, all)
    value = $game_actors[index].exp
    equal_exp(value, all)
  end
#------------------------------------------------------------------------------
# * Equal Value
#------------------------------------------------------------------------------
  def equal_value(value, all)
    equal_exp(value, all)
  end
#--------------------------------------------------------------------------
# ** Change Party Member (Aliased)
#--------------------------------------------------------------------------
  alias :command_129_lvlcon :command_129
  def command_129
    command_129_lvlcon
    equal_leader(XpCon::AutoEqAll) if @params[1] == 0 && XpCon::AutoEqual
  end
end
