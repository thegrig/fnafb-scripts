#==============================================================================
# ** DataManager
#------------------------------------------------------------------------------
#  This module manages the database and game objects. Almost all of the 
# global variables used by the game are initialized by this module.
#==============================================================================

module DataManager
  #--------------------------------------------------------------------------
  # * Set Up Extras Menu
  #--------------------------------------------------------------------------
  def self.setup_extras
    create_game_objects
    $game_party.setup_starting_members
    $game_map.setup(17) #set to map id you want
    $game_player.moveto(0, 12)
    $game_player.refresh
    Graphics.frame_count = 0
  end
end
#==============================================================================
# ** Window_TitleCommand
#------------------------------------------------------------------------------
#  This window is for selecting New Game/Continue on the title screen.
#==============================================================================

class Window_TitleCommand < Window_Command
  def make_command_list
    add_command(Vocab::new_game, :new_game)
    add_command(Vocab::continue, :continue, continue_enabled)
    add_command("Extras", :extras)# "Extras" to name you want
    add_command(Vocab::shutdown, :shutdown)
  end
end
#==============================================================================
# ** Scene_Title
#------------------------------------------------------------------------------
#  This class performs the title screen processing.
#==============================================================================

class Scene_Title < Scene_Base
  #--------------------------------------------------------------------------
  # * Create Command Window
  #--------------------------------------------------------------------------
  def create_command_window
    @command_window = Window_TitleCommand.new
    @command_window.set_handler(:new_game, method(:command_new_game))
    @command_window.set_handler(:continue, method(:command_continue))
    @command_window.set_handler(:extras, method(:command_extras))
    @command_window.set_handler(:shutdown, method(:command_shutdown))
  end
  
  #--------------------------------------------------------------------------
  # * [Extras] Command
  #--------------------------------------------------------------------------
  def command_extras
    DataManager.setup_extras
    close_command_window
    fadeout_all
    $game_map.autoplay
    SceneManager.goto(Scene_Map)
  end
end