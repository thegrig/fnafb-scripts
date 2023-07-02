=begin
#==============================================================================
# * grig's text sound script v2.0
#==============================================================================
# * How to Setup:
#==============================================================================
  For each faceset, you add to a "Hash".
  An example of a valid addition is as follows:

    "New Thing" => ["Thing", 69, "Thing2", 420]

  As you can see, it has a name "New Thing" and contains four different things.
  For the sake of this script, the way you'll set it up is as follows:

    "Faceset Name" = [["Sound Name", Volume, Pitch Min, Pitch Max]]

  Each face's information in the faceset is stored as an "Array", here.
  For the sake of readability, set each face as a new line, and put the ending
  square bracket on its own line.
  
  An example of a completed faceset is as follows:

    "Actor1" => [                  #Faceset Name
      ["Book1", 75, 150, 175],     #Index 0
      ["Cancel2", 80, 135, 160],   #Index 1
      ["Attack2", 85, 90, 110],    #Index 2
      ["Bow2", 60, 75, 150],       #Index 3
      ["Book1", 75, 150, 175],     #Index 4
      ["Cancel2", 80, 135, 160],   #Index 5
      [],                          #Index 6
      ["Bow2", 60, 75, 150],       #Index 7
    ],                             #End of Faceset

  As you can see, Index 6 is completely empty. If you leave an index empty, no
  text sound will be used. Make sure to keep the empty Array brackets, though.
  
  Without the empty array brackets, it would just use the next Array instead.
  We don't want that.

#==============================================================================
# * Misc Notes:
#==============================================================================
  - Facesets that aren't established will fallback on the generic sound if one
    exists. Otherwise it will simply use no text sounds at all.
#==============================================================================
# * END OF EXPLANATION   
#==============================================================================
=end
module TeSe
  TxtSe = { # do not touch this
#==============================================================================
# * Text Sound Setup:
#==============================================================================
# * Actor1
#==============================================================================
"Actor1" => [                  #Faceset Name
  ["Book1", 75, 150, 175],     #Index 0
  ["Cancel2", 80, 135, 160],   #Index 1
  ["Attack2", 85, 90, 110],    #Index 2
  ["Bow2", 60, 75, 150],       #Index 3
  ["Book1", 75, 150, 175],     #Index 4
  ["Cancel2", 80, 135, 160],   #Index 5
  [],                          #Index 6
  ["Bow2", 60, 75, 150],       #Index 7
],                             #End of Faceset                         
#==============================================================================
# * Actor2
#==============================================================================
"Actor2" => [                  #Faceset Name
  ["Book1", 75, 150, 175],     #Index 0
  ["Cancel2", 80, 135, 160],   #Index 1
  ["Attack2", 85, 90, 110],    #Index 2
  ["Bow2", 60, 75, 150],       #Index 3
  ["Book1", 75, 150, 175],     #Index 4
  ["Cancel2", 80, 135, 160],   #Index 5
  [],                          #Index 6
  ["Bow2", 60, 75, 150],       #Index 7
],                             #End of Faceset
#add more here

} # do not touch this
#==============================================================================
# * Misc Config:
#==============================================================================
# The ID for the switch that, when on, silences text sounds.
  OffSwitch = 1
# The text sound will play every x characters. The default is 4.
  Interval  = 4
# Play while fastforwarding? This creates a really loud noise, but maybe you
# want it to exist for some reason.
  PlayFF    = false
# Generic text sound for when no other sound is defined. Leave the Array empty
# for no generic text sound. #Gen = ["Cursor1", 80, 75, 125]
  Gen = ["Cursor1", 80, 75, 125]
#==============================================================================
# * END OF SETUP
#==============================================================================
# * the actual code:
#==============================================================================
TxtSe.default = ""
  def self.play_tese
    return if $game_switches[OffSwitch]
    name = $game_message.face_name
    index = $game_message.face_index
    play_generic if TxtSe[name] == ""; return if TxtSe[name] == ""
    return if TxtSe[name][index][0].nil? || TxtSe[name].empty?
    file, volume = "Audio/SE/" + TxtSe[name][index][0], TxtSe[name][index][1]
    pitch1, pitch2 = TxtSe[name][index][2], TxtSe[name][index][3]
    pitch = pi_ran(pitch1, pitch2)
    Audio.se_play(file, volume, pitch)
  end
  
  def self.play_generic
    return if Gen.empty?
    file, volume, pitch1, pitch2 = "Audio/SE/" + Gen[0], Gen[1], Gen[2], Gen[3]
    pitch = pi_ran(pitch1, pitch2)
    Audio.se_play(file, volume, pitch)
  end
  
  def self.pi_ran(pitch0, pitch1)
    pitchRand = rand(pitch1 - pitch0) + pitch0
    return pitchRand
  end
end

class Window_Message < Window_Base
#--------------------------------------------------------------------------
# * Object Initialization
#--------------------------------------------------------------------------
  alias tese_init initialize unless $@
  def initialize
    tese_init
    @character = 0
  end
#--------------------------------------------------------------------------
# * Normal Character Processing
#--------------------------------------------------------------------------
  alias tese_process_normal_character process_normal_character unless $@
  def process_normal_character(c, pos)
    tese_process_normal_character(c, pos)
    TeSe.play_tese if @character % TeSe::Interval == 0 && should_play
    @character += 1
  end
#--------------------------------------------------------------------------
# ** Determine if Text Sound should Play
#--------------------------------------------------------------------------
  def should_play
    if @show_fast && !TeSe::PlayFF
      return false
    else
      return true
    end
  end
#--------------------------------------------------------------------------
# * New Page Character Processing
#--------------------------------------------------------------------------
  alias tese_process_new_page process_new_page unless $@
  def process_new_page(text, pos)
    tese_process_new_page(text, pos)
    @character = 0
  end
end
