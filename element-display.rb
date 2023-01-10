module GRIGELEMENT
#==============================================================================
# Grig's Element Display v0.0.1
#==============================================================================
# * This script was specifically made for my current project, though may be
# useful to you, too. It makes the game display a configurable message based on
# the effectiveness of a skill/item, alongside playing a sound.
# * I've added several easy to use configurable variables below.
#==============================================================================
# ** Config:
#==============================================================================  
  WeakSE = "Skill3"  # The sound that plays when the enemy is weak to a skill.
  ResistSE = "Down3" # The sound that plays when the enemy resists a skill.
  Shake = true # Whether or not to shake the screen when the enemy is weak.
  WeakMessage = "\\*\\C[11]That's its weakness!\\*\\C[0]" # Weak message
  ResistMessage = "\\*\\C[1]It resists that!\\C[0]" # Resist message
  ImmuneMessage = "It was immune to that!" # Immune message (never actually triggers)
#==============================================================================
# ** End of Config
#==============================================================================  
  def self.playWeak
    RPG::SE.new(WeakSE, 75, 100).play
  end
  
  def self.playResist
    RPG::SE.new(ResistSE, 75, 100).play
  end
end

module RPG
  class Actor < BaseItem

    def element_icons
      return @element_icons unless @element_icons.nil?
      load_notetag_actor_element_icons
      return @element_icons
    end
  
    def load_notetag_actor_element_icons
      regex = /<element_icons:[ ](\d+)[ ](\d+)[ ](\d+)>/
      @element_icons = self.note
    end
  end

  class Enemy < BaseItem

    def element_icons
      return @element_icons unless @element_icons.nil?
      load_notetag_enemy_element_icons
      return @element_icons
    end
  
    def load_notetag_enemy_element_icons
      regex = /<element_icons:[ ](\d+)[ ](\d+)[ ](\d+)>/
      @element_icons = self.note
    end
  end
end

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :icon_weak
  attr_reader   :icon_resist
  attr_reader   :icon_immune
  #--------------------------------------------------------------------------
  # * Setup
  #--------------------------------------------------------------------------
  def setup(actor_id)
    @actor_id = actor_id
    @name = actor.name
    @nickname = actor.nickname
    init_graphics
    @class_id = actor.class_id
    @level = actor.initial_level
    @exp = {}
    @equips = []
    init_exp
    init_skills
    init_equips(actor.equips)
    clear_param_plus
    recover_all
    load_element_icons
  end
  #--------------------------------------------------------------------------
  # ** Load Element Icons
  #--------------------------------------------------------------------------
  def load_element_icons
    if $data_actors[actor_id].element_icons =~ /<element_icons:[ ](\d+)[ ](\d+)[ ](\d+)>/
      puts "Element Icons: ["+$1.to_s+","+$2.to_s+","+$3.to_s+"]"
      @icon_weak = $1.to_i
      @icon_resist = $2.to_i
      @icon_immune = $3.to_i
    end
  end
end

class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :icon_weak
  attr_reader   :icon_resist
  attr_reader   :icon_immune
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias :grigelement_initialize :initialize
  def initialize(index, enemy_id)
    grigelement_initialize(index, enemy_id)
    load_element_icons
  end
  #--------------------------------------------------------------------------
  # ** Load Element Icons
  #--------------------------------------------------------------------------
  def load_element_icons
    if $data_enemies[enemy_id].element_icons =~ /<element_icons:[ ](\d+)[ ](\d+)[ ](\d+)>/
      puts "Element Icons: ["+$1.to_s+","+$2.to_s+","+$3.to_s+"]"
      @icon_weak = $1.to_i
      @icon_resist = $2.to_i
      @icon_immune = $3.to_i
    end
  end
end

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Battle Action Processing
  #--------------------------------------------------------------------------
  alias grigelement_process_action process_action
  def process_action
    return if scene_changing?
    if !@subject || !@subject.current_action
      @subject = BattleManager.next_subject
    end
    return turn_end unless @subject
    if @subject.current_action
      @subject.current_action.prepare
      if @subject.current_action.valid?
        @status_window.open
        @log_window.set_subject(@subject)
        execute_action
      end
      @subject.remove_current_action
    end
    process_action_end unless @subject.current_action
  end
  
  #--------------------------------------------------------------------------
  # * Processing at End of Action
  #--------------------------------------------------------------------------
  alias grigelement_process_action_end process_action_end
  def process_action_end
    @subject.on_action_end
    refresh_status
    @log_window.clear_subject
    @log_window.display_auto_affected_status(@subject)
    @log_window.wait_and_clear
    @log_window.display_current_state(@subject)
    @log_window.wait_and_clear
    BattleManager.judge_win_loss
  end
end

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # * Apply Effect of Skill/Item
  #--------------------------------------------------------------------------
  alias grig_item_apply item_apply
  def item_apply(user, item)
    @result.clear
    @result.used = item_test(user, item)
    @result.missed = (@result.used && rand >= item_hit(user, item))
    @result.evaded = (!@result.missed && rand < item_eva(user, item))
    if @result.hit?
      unless item.damage.none?
        @result.critical = (rand < item_cri(user, item))
        make_damage_value(user, item)
        rate = item_element_rate_raw(user, item)
        @result.take_rate(rate)
        execute_damage(user)
      end
      item.effects.each {|effect| item_effect_apply(user, item, effect) }
      item_user_effect(user, item)
    end
  end
  
  #--------------------------------------------------------------------------
  # ** Raw Element Rate
  #--------------------------------------------------------------------------
  def item_element_rate_raw(user, item)
    if item.damage.element_id < 0
      #puts user.atk_elements
      user.atk_elements.empty? ? 1.0 : elements_max_rate(user.atk_elements)
    else
      element_rate(item.damage.element_id)
    end
  end
end
  
class Game_ActionResult
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :element_rate                # Element Rate
  
  #--------------------------------------------------------------------------
  # * Clear
  #--------------------------------------------------------------------------
  alias grig_clear clear
  def clear
    clear_hit_flags
    clear_damage_values
    clear_status_effects
    clear_element_rate
  end
  
  #--------------------------------------------------------------------------
  # ** Clear Element Rate
  #--------------------------------------------------------------------------
  def clear_element_rate
    @element_rate = 0
  end
  
  #--------------------------------------------------------------------------
  # ** Take Element Rate
  #--------------------------------------------------------------------------
  def take_rate(rate)
    @element_rate = rate
  end
  
  #--------------------------------------------------------------------------
  # * Create Damage
  #--------------------------------------------------------------------------
  alias grigelement_make_damage make_damage
  def make_damage(value, item)
    @critical = false if value == 0
    @hp_damage = value if item.damage.to_hp?
    @mp_damage = value if item.damage.to_mp?
    @mp_damage = [@battler.mp, @mp_damage].min
    @hp_drain = @hp_damage if item.damage.drain?
    @mp_drain = @mp_damage if item.damage.drain?
    @hp_drain = [@battler.hp, @hp_drain].min
    @success = true if item.damage.to_hp? || @mp_damage != 0
  end
  
end

class Window_BattleLog < Window_Selectable
  
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :subject                # Subject
  
  #--------------------------------------------------------------------------
  # ** Display Element
  #--------------------------------------------------------------------------
  def display_element(target,item)
    return if target.result.hp_damage == 0 && item && !item.damage.to_hp?
    rate = target.result.element_rate
    if target.result.hp_damage > 0
      if rate > 1
        add_text(sprintf(GRIGELEMENT::WeakMessage))
        GRIGELEMENT.playWeak
      elsif rate < 1 && rate > 0
        add_text(sprintf(GRIGELEMENT::ResistMessage))
        GRIGELEMENT.playResist
      elsif rate <= 0 && !target.result.missed && !target.result.evaded
        add_text(sprintf(GRIGELEMENT::ImmuneMessage))
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # ** Set Subject
  #--------------------------------------------------------------------------
  def set_subject(subject)
    @subject = subject
  end
  
  #--------------------------------------------------------------------------
  # ** Clear Subject
  #--------------------------------------------------------------------------
  def clear_subject
    @subject = ""
  end
  
  #--------------------------------------------------------------------------
  # * Display Action Results
  #--------------------------------------------------------------------------
  alias grig_display_action_results display_action_results
  def display_action_results(target, item)
    if target.result.used
      last_line_number = line_number
      display_critical(target, item)
      display_element(target, item)
      display_damage(target, item)
      display_affected_status(target, item)
      display_failure(target, item)
      wait if line_number > last_line_number
      back_to(last_line_number)
    end
  end
end