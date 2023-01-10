#===============================================================================
#
#                           *** FNaFb Basic v0.0.4***
#                 (A pile of useful script junk for FNaFb games!)
#
#                   !!!HAS NOT BEEN TESTED WITH OTHER SCRIPTS!!!  
#
#===============================================================================
# - Compiled and edited by Grig
# - Tint, Font, Heal on Level-Up, and Title Reposition by Unknown Author(s)
# - Icon Drops presumably by Sivelos
# - Enemy Target Fix and Glyph Fix by Lone Wolf
# - Everything else by Grig
#===============================================================================

$imported = {} if $imported.nil?
$imported['FNaFbBasic'] = true

puts 'FNaFb Basic by Grig'

module FNAFB
  #Title Stuff
  TITLEX = 32 #(Title command X.)
  TITLEY = 290 #(Title command Y.)
  
  # Misc Stuff
  TINTSWITCH = 1 #(Switch ID for turning tint on in battle. Off by default.)
  WINDOWSKIN = "Window" #(The name of the default in-game window skin.)
  WINDOWOPACITY = 255 #(The opacity of in-game windows. 255 Recommended.)
  BATTELOGOPACITY = 255 #(The opacity of the in-game battle log. 255 Recommended.)
  FADEOUTTIME = 30 #(How many frames it takes for "Fadeout Screen" to finish.)
  FADEINTIME = 30 #(How many frames it takes for "Fadein Screen" to finish.)
  HEALONLVL = true #(Whether actors should be healed when they level-up.)

  # Font Stuff
  FONTNAME = "Courier New" #(The name of the default font.)
  FONTSIZE = 20 #(The default font size.)
  FONTBOLD = true #(Whether or not the font is bold.)
  FONTITAL = false #(Whether or not the font is italicized. (slanted))
  FONTSHADOW = false #(Whether or not the font has a shadow.)
  FONTOUTLINE = false #(Whether or not the font has an outline.)
  FONTRGBA = Color.new(255,255,255,255) #(The font's color, using RGBA)
  FONTOUTRGBA = Color.new(0,0,0,255) #(The font's outline color, using RGBA)
  
  # Battle Stuff
  STARTTP = 15 #(The TP amount you start with.)
  CRITMOD = 2 #(The critical hit damage multiplier. Default is 3.)
  SPDVAR = false #(Whether or not to use action speed variance.)
    #(Action speed variance is adding more rng to the game, basically. By default,
    #the variance is present, and it makes the AGI stat highly inconsistent.)
    
  # Timer Stuff
  TIMERX = 225 #(The position the timer is on the X axis.)
  TIMERY = 25 #(The position the timer is on the Y axis.)
    
  # Drop Icon Stuff
  DROPICONS = false #(Whether or not enemy drops use icons.)
  DROPCOLOR = 6 #(The text color index (from the window skin) for enemy drops.)
  DROPMSG = "%s%s%s%s found!" #(The drop message shown if icons are enabled.)
  #^^^ !!!THIS ALL REQUIRES THE GLOBAL TEXT CODES SCRIPT BY modern algebra!!!
  # https://rmrk.net/index.php?topic=44810.0 <--- link
end

#===============================================================================
# ** Change Font
#===============================================================================

Font.default_name = FNAFB::FONTNAME
Font.default_size = FNAFB::FONTSIZE
Font.default_bold = FNAFB::FONTBOLD
Font.default_italic = FNAFB::FONTITAL
Font.default_shadow = FNAFB::FONTSHADOW
Font.default_outline = FNAFB::FONTOUTLINE
Font.default_color = FNAFB::FONTRGBA
Font.default_out_color = FNAFB::FONTOUTRGBA

#===============================================================================
# ** No Screen Tint in Battles
#===============================================================================

class Spriteset_Battle
  #TINT_SWITCH = 13	  #<--- Switch ID

  # If switch is ON, the battle will use the map's tint
  # If switch is OFF, the battle will not use a tint
  # You can also leave the switch ID at 0 to disable battle tints altogether.

  def update_viewports
		  unless $game_switches[FNAFB::TINTSWITCH]
		  @viewport1.tone.set(0, 0, 0, 0)
		  else
		  @viewport1.tone.set($game_troop.screen.tone)
		  end
		@viewport1.ox = $game_troop.screen.shake
		@viewport2.color.set($game_troop.screen.flash_color)
		@viewport3.color.set(0, 0, 0, 255 - $game_troop.screen.brightness)
		@viewport1.update
		@viewport2.update
		@viewport3.update
  end
end

class Game_Interpreter

  alias_method :command_283_orig_kal, :command_283
  def command_283
	command_283_orig_kal
    if SceneManager.scene.is_a?(Scene_Battle)
      scene = SceneManager.scene
      scene.spriteset.dispose_battleback1
      scene.spriteset.dispose_battleback2
      scene.spriteset.create_battleback1
      scene.spriteset.create_battleback2
    end
  end
end

#===============================================================================
# ** Reposition Title Elements
#===============================================================================

class Scene_Battle
  attr_reader :spriteset
end

class Window_TitleCommand < Window_Command
  def update_placement
    self.x = FNAFB::TITLEX # X co-ordinate here
    self.y = FNAFB::TITLEY # Y co-ordinate here
  end
end

#===============================================================================
# ** Window Opacity
#===============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias FNAFB_initialize initialize
  def initialize(x, y, width, height)
    super
    self.windowskin = Cache.system(FNAFB::WINDOWSKIN)
    self.back_opacity = FNAFB::WINDOWOPACITY
    update_padding
    update_tone
    create_contents
    @opening = @closing = false
  end
end

class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Fadeout Screen
  #--------------------------------------------------------------------------
  alias FNAFB_command_221 command_221
  def command_221
    Fiber.yield while $game_message.visible
    screen.start_fadeout(FNAFB::FADEOUTTIME)
    wait(FNAFB::FADEOUTTIME)
  end
  #--------------------------------------------------------------------------
  # * Fadein Screen
  #--------------------------------------------------------------------------
  alias FNAFB_command_222 command_222
  def command_222
    Fiber.yield while $game_message.visible
    screen.start_fadein(FNAFB::FADEINTIME)
    wait(FNAFB::FADEINTIME)
  end
end

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # * Apply Critical
  #--------------------------------------------------------------------------
  alias FNAFB_apply_critical apply_critical
  def apply_critical(damage)
      damage * FNAFB::CRITMOD
  end
    
  #--------------------------------------------------------------------------
  # * Initialize TP
  #--------------------------------------------------------------------------
  alias FNAFB_init_tp init_tp
  def init_tp
    self.tp = FNAFB::STARTTP
  end
end

class Game_Action
  #--------------------------------------------------------------------------
  # * Calculate Action Speed
  #--------------------------------------------------------------------------
  alias FNAFB_speed speed
  def speed
    if FNAFB::SPDVAR == true
      speed = subject.agi + rand(5 + subject.agi / 4)
    else
      speed = subject.agi
    end
    speed += item.speed if item
    speed += subject.atk_speed if attack?
    speed
  end
end

module Vocab
  #ObtainItem      = "%s found!"
  #ObtainItemIcon      = "%s%s%s%s found!"
end

module BattleManager
  def self.gain_drop_items
    if FNAFB::DROPICONS == true && !$imported[:MAGlobalTextCodes]
      msgbox("Add Global Text Codes by modern algebra, or set DROPICONS to false.
      DROPICONS does not work without Global Text Codes.")
  exit
end
    $game_troop.make_drop_items.each do |item|
      $game_party.gain_item(item, 1)
      icon = '\\*\\i[' + item.icon_index.to_s + ']'
      colorcodeA = '\\*\\c[' + FNAFB::DROPCOLOR.to_s + ']'
      colorcodeB = '\\*\\c[0]'
      if FNAFB::DROPICONS == true && $imported && $imported[:MAGlobalTextCodes]
        $game_message.add(sprintf(FNAFB::DROPMSG,icon,colorcodeA,item.name,colorcodeB))
      else
        $game_message.add(sprintf(Vocab::ObtainItem, item.name))
      end
    end
    wait_for_message
  end
end

class Window_BattleLog < Window_Selectable

  alias hidden_battle_log_initialize initialize
  def initialize
    hidden_battle_log_initialize
    self.contents_opacity = FNAFB::BATTELOGOPACITY
  end

  def back_opacity
    return FNAFB::BATTELOGOPACITY
  end
end

#===============================================================================
# ** Fix Scrunch
#===============================================================================
class Window_Base
  def draw_item_name(item, x, y, enabled = true, width = 500)
    return unless item
    draw_icon(item.icon_index, x, y, enabled)
    change_color(normal_color, enabled)
    draw_text(x + 28, y, width, line_height, item.name)
  end
end
 
class Window_ItemList < Window_Selectable
  def col_max
    return 1
  end
end
 
class Window_SkillList < Window_Selectable
  def col_max
    return 1
  end
end

#===============================================================================
# ** Relocate Timer
#===============================================================================
class Sprite_Timer < Sprite
  # Overwrite
  def update_position
    self.x = FNAFB::TIMERX
    self.y = FNAFB::TIMERY
    self.z = 200
  end
end

#===============================================================================
# ** Heal on Level-Up
#===============================================================================
class Game_Actor < Game_Battler
  attr_reader :actor_id
  
  alias cp_gv_level_up level_up unless $@
  def level_up
      tmp1 = mhp
      tmp2 = mmp
      cp_gv_level_up
      heal1 = mhp - tmp1
      heal2 = mmp - tmp2
    if FNAFB::HEALONLVL == true
      self.hp += 9999
      self.mp += 9999
    end
  end
end

#===============================================================================
# ** Fix Enemy Targeting Bug
#===============================================================================
class Game_Action
  def targets_for_friends
	if item.for_user?
	  [subject]
	elsif item.for_dead_friend?
	  if item.for_one?
		[friends_unit.smooth_dead_target(@target_index)]
	  else
		friends_unit.dead_members
	  end
	elsif item.for_friend?
	  if item.for_one?
		if @target_index < 0
		  [friends_unit.random_target]
		else
		  [friends_unit.smooth_target(@target_index)]
		end
	  else
		friends_unit.alive_members
	  end
	end
  end
end

#===============================================================================
# ** Fix Glyphs
#===============================================================================
class Window_Base
  alias :process_normal_character_vxa :process_normal_character
  def process_normal_character(c, pos)
	return unless c >= ' ' #skip drawing if c is not a displayable character
	process_normal_character_vxa(c, pos)
  end
end