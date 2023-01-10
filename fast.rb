#Lower = fast.

class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # * Get Message Speed
  #--------------------------------------------------------------------------
  def message_speed
    return 15 #Default: 10
  end
end

class Sprite_Battler < Sprite_Base
  #--------------------------------------------------------------------------
  # * Start Effect
  #--------------------------------------------------------------------------
  def start_effect(effect_type)
    @effect_type = effect_type
    case @effect_type
    when :appear
      @effect_duration = 8 #Default: 16
      @battler_visible = true
    when :disappear
      @effect_duration = 16 #Default: 32
      @battler_visible = false
    when :whiten
      @effect_duration = 8 #Default: 16
      @battler_visible = true
    when :blink
      @effect_duration = 10 #Default: 20
      @battler_visible = true
    when :collapse
      @effect_duration = 24 #Default: 48
      @battler_visible = false
    when :boss_collapse
      @effect_duration = bitmap.height
      @battler_visible = false
    when :instant_collapse
      @effect_duration = 8 #Default: 16
      @battler_visible = false
    end
    revert_to_normal
  end
end

class Scene_Base
  #--------------------------------------------------------------------------
  # * Get Transition Speed
  #--------------------------------------------------------------------------
  def transition_speed
    return 5 #Default: 10
  end
  
  #--------------------------------------------------------------------------
  # * Fade Out All Sounds and Graphics
  #--------------------------------------------------------------------------
  def fadeout_all(time = 500) #Default: 1000
    RPG::BGM.fade(time)
    RPG::BGS.fade(time)
    RPG::ME.fade(time)
    Graphics.fadeout(time * Graphics.frame_rate / 1000)
    RPG::BGM.stop
    RPG::BGS.stop
    RPG::ME.stop
  end
end

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Pre-Termination Processing
  #--------------------------------------------------------------------------
  def pre_terminate
    super
    Graphics.fadeout(30) if SceneManager.scene_is?(Scene_Map) #Default: 30
    Graphics.fadeout(30) if SceneManager.scene_is?(Scene_Title) #Default: 60
  end
end