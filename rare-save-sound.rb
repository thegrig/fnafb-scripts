#play a goofy sound sometimes (rare)
module GRIGRARESAVE
  RareSound = ["hamburger",100,100,5]
              #sound name, volume, pitch, chance out of 100
  
  def self.play_rare
    RPG::SE.new(RareSound[0],RareSound[1],RareSound[2]).play
  end
end

class Scene_Save < Scene_File
  #--------------------------------------------------------------------------
  # * Processing When Save Is Successful
  #--------------------------------------------------------------------------
  def on_save_success
    rando = rand(100)
    if rando <= GRIGRARESAVE::RareSound[3]
      GRIGRARESAVE.play_rare
    else
      Sound.play_save
    end
      return_scene
  end
end