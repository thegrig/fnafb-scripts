################################################################################
# v1
# Made by mobychan, slightly edited by Bird Eater, then heavily edited by grig.
# Give mobychan the cookies.
# http://forums.rpgmakerweb.com/index.php?/topic/3463-mss-text-se/
################################################################################
module TSE
  
# NM is the variable ID that stores the name of the faceset.
# ID is the variable ID that stores the face index (starting from 0).
# OFF is the switch ID for the off switch. If the switch is on, no text sounds.
# DEFAULT is the switch ID for the default sounds. If on, default sounds are on.
NM = 1
ID = 2
OFF = 1
DEFAULT = 2

#You can enable a default sound to play if no face is shown.
DESE = "beep"
DEPI = [100, 100]
DEVOL = 80


# The pitch range of the file being played, change them however you like.
# [start pitch, end pitch]
# start and end pitch can be the same to have a static pitch
Pitch1 = [100, 100] #Static pitch
Pitch2 = [80, 100] #Deeper
Pitch3 = [50, 60] #VERY deep
Pitch4 = [100, 150] #Very high, and varied!
#Pitch5 = [90,100] #You can also add as many extras as you want.

# The volume of the file being played
Volume1 = 100
Volume2 = 90
Volume3 = 80
#Volume4 = 70 #You can also add as many extras as you want.

# The interval at which the sound is being played, every x characters.
Interval = 4
end
#==============================================================================
# ** Sound
#==============================================================================
module Sound
# System Sound Effect

#==============================================================================
# ** Pitch Random
#==============================================================================
  def self.pitchRandom(pitch0, pitch1)
    pitchRand = rand(pitch1 - pitch0) + pitch0
    #puts pitchRand
    return pitchRand
  end

#==============================================================================
# ** Play Text SE
#==============================================================================
  def self.play_text_se
    if $game_switches[TSE::OFF] == false #if the switch here is on, no text sounds
  #---#
      case $game_variables[TSE::NM]
      #Using the examples provided below, edit the code to your liking.
#==============================================================================
# ** Mario. (faceset)
#==============================================================================
        when "faces" #this is checking the file name for the faceset
          case $game_variables[TSE::ID]
            when 0 #Mario.
                file = "Audio/SE/beep"
                pitch = Sound.pitchRandom(TSE::Pitch1[0], TSE::Pitch1[1])
                Audio.se_play(file, TSE::Volume1, pitch)
          end
#==============================================================================
# ** GOD HIMSELF (faceset)
#==============================================================================
        when "godhimself" #this is checking the file name for the faceset
          case $game_variables[TSE::ID]
            when 1 #Jaming Jolteon.
                file = "Audio/SE/jaming"
                pitch = Sound.pitchRandom(TSE::Pitch3[0], TSE::Pitch3[1])
                Audio.se_play(file, TSE::Volume2, pitch)
            when 3 #Jerma.
                file = "Audio/SE/erma"
                pitch = Sound.pitchRandom(TSE::Pitch2[0], TSE::Pitch2[1])
                Audio.se_play(file, TSE::Volume3, pitch)
          end
              #continue here#
#==============================================================================
# ** Default
#==============================================================================
        else
          if $game_switches[TSE::DEFAULT] == true
            file = "Audio/SE/" + TSE::DESE.to_s
            pitch = Sound.pitchRandom(TSE::DEPI[0], TSE::DEPI[1])
            Audio.se_play(file, TSE::DEVOL, pitch)
          end
      end
    end
  end
end

#==============================================================================
# ** Window_Message
#==============================================================================
  class Window_Message < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
    alias tse_init initialize unless $@
    def initialize
      tse_init
      @character = 0
    end
#--------------------------------------------------------------------------
# * Normal Character Processing
#--------------------------------------------------------------------------
    alias tse_process_normal_character process_normal_character unless $@
    def process_normal_character(c, pos)
      tse_process_normal_character(c, pos)
      Sound.play_text_se if @character % TSE::Interval == 0 && !@line_show_fast
      #p @character if @character % TSE::Interval == 0 && !@line_show_fast
      @character += 1
    end
#--------------------------------------------------------------------------
# * New Page Character Processing
#--------------------------------------------------------------------------
    alias tse_process_new_page process_new_page unless $@
    def process_new_page(text, pos)
      tse_process_new_page(text, pos)
      @character = 0
    end
  end



#==============================================================================
# ** Window_Base
#------------------------------------------------------------------------------
#  This is a super class of all windows within the game.
#==============================================================================

  class Window_Base < Window

#--------------------------------------------------------------------------
# * Draw Face Graphic
#     enabled : Enabled flag. When false, draw semi-transparently.
#--------------------------------------------------------------------------
  alias tse_draw_face draw_face unless $@
  def draw_face(face_name, face_index, x, y, enabled = true)
    $game_variables[TSE::NM] = face_name
    $game_variables[TSE::ID] = face_index
    bitmap = Cache.face(face_name)
    rect = Rect.new(face_index % 4 * 96, face_index / 4 * 96, 96, 96)
    contents.blt(x, y, bitmap, rect, enabled ? 255 : translucent_alpha)
    bitmap.dispose
  end
end