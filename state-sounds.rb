module GRIGSTATESFX
    BadStates = [5,6,7,8,9,10]
    BadSound = "Blind"
    BadVolume = 75
    BadPitch = 200
    
    GoodStates = []
    GoodSound = "Saint5"
    GoodVolume = 75
    GoodPitch = 200
end
  
  
class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # * Display Added State
  #--------------------------------------------------------------------------
  alias grig_display_added_states display_added_states
  def display_added_states(target)
    target.result.added_state_objects.each do |state|
      state_msg = target.actor? ? state.message1 : state.message2
      target.perform_collapse_effect if state.id == target.death_state_id
      next if state_msg.empty?
      if GRIGSTATESFX::BadStates.include?(state.id)
        RPG::SE.new(GRIGSTATESFX::BadSound, GRIGSTATESFX::BadVolume, GRIGSTATESFX::BadPitch).play
      elsif GRIGSTATESFX::GoodStates.include?(state.id)
        RPG::SE.new(GRIGSTATESFX::GoodSound, GRIGSTATESFX::GoodVolume, GRIGSTATESFX::GoodPitch).play
      end
      replace_text(target.name + state_msg)
      wait
      wait
      wait_for_effect
    end
  end
end