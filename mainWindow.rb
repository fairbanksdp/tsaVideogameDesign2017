require 'gosu'
require 'chipmunk'
require "./Pres.rb"
require "./zOrder.rb"

class GameWindow < Gosu::Window
  attr_accessor :space
  def initialize
    super 640, 360, true
    self.caption = "Gosu Test"
    @space = CP::Space.new()
    @dt = 1/60.0
    @space.gravity = vec2(0, 10.0)
    @ground = CP::Shape::Segment.new(CP::Body.new_static(), vec2(0,250), vec2(665,250), 1)
    @wallLeft = CP::Shape::Segment.new(CP::Body.new_static(), vec2(0,0), vec2(0,350), 1)
    @wallRight = CP::Shape::Segment.new(CP::Body.new_static(), vec2(640,0), vec2(665,350), 1)
    @ground.u = 0.05
    @ground.e = 0
    @wallLeft.e = 0
    @wallRight.e = 0
    @space.add_shape(@ground)
    @space.add_shape(@wallLeft)
    @space.add_shape(@wallRight)
    @player1 = Pres.new("George",true,self)
    @player2 = Pres.new("Abe",false,self)
    
    @background_image = Gosu::Image.new("media/whiteHouse.png", :tileable => true)
    @titleScreen = Gosu::Image.new("media/Title.png", :tileable => true)
		@titleLock = true
		@creditScreen = false
    @titleButtonLock = false
    @font = Gosu::Font.new(20)
    @Title = Gosu::Font.new(40)
    @startButtonActive = 0
    @upButtonLock = false
    @downButtonLock = false

    @songs = [
      Gosu::Song.new(self,"media/Alestorm - Drink.WAV"),
      Gosu::Song.new(self,"media/patriotic-medley.WAV"),
      Gosu::Song.new(self,"media/stars_and_stripes.WAV"),
      Gosu::Song.new(self,"media/we-are-the-champions.WAV"),
      Gosu::Song.new(self,"media/william-tell-overture.WAV"),
			Gosu::Song.new(self,"media/1812-overture.WAV")
    ]
    @fightSong = rand(@songs.length-1)
    @songs[5].play

		@space.add_collision_func(:player, :hitBox) do |player, hitBox|
			a = hitBox.group
			v = player.group
      #print("#{a}")
      #print("#{v}")
      a.hitBoxes.each_pair do |key, value|
        if value == hitBox  
      	  d = (v.rigidBody.p.x - a.rigidBody.p.x)/((v.rigidBody.p.x - a.rigidBody.p.x).abs)
			    if -(a.dir/(a.dir.abs)) == d
						str = key[0..2]
						#print("#{(a.curAnim == a.anims[str]) && !a.attackLock[str]} ")
            #print("#{a.curAnim == a.anims[str]} ")
						#print("buttonLock: #{a.buttonLock[str]} ")
						#print("attackLock: #{a.attackLock[str]}\n")
						if (a.curAnim == a.anims[str]) && !a.attackLock[str]
            	v.takeHit(5)
            	a.attackLock[str] = true
						end
          end
        end
			end
		end
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
    if id == Gosu::KbTab && !@titleButonLock
      @titleButtonLock = true
      if @titleLock
        @titleLock = false
      else
        @titleLock = true
      end
    end
    if id == Gosu::KB_RETURN && !@titleButonLock && @titleLock 
      @titleButtonLock = true
      if @startButtonActive == 0
        @titleLock = false
      elsif @startButtonActive == 1
        if @creditScreen
          @creditScreen = false
        else
          @creditScreen = true
        end
      else
        close
      end
    end
  end

  def button_up(id)
    if id == Gosu::KbTab 
      @titleButtonLock = false
    end
    if id == Gosu::KbReturn 
      @titleButtonLock = false
    end
    if id == Gosu::KbUp
      @upButtonLock = false
    end
    if id == Gosu::KbDown
      @downButtonLock = false
    end

    if id == Gosu::KbW
      @player1.buttonLock["jump"] = false
    end  
    if id == Gosu::KbE
      @player1.buttonLock["top"] = false
    end  
    if id == Gosu::KbQ
      @player1.buttonLock["mid"] = false
    end  
    if id == Gosu::KbLeftShift
      @player1.buttonLock["bot"] = false
    end  

    if id == Gosu::KbI
      @player2.buttonLock["jump"] = false
    end  
    if id == Gosu::KbU
      @player2.buttonLock["top"] = false
    end  
    if id == Gosu::KbO
      @player2.buttonLock["mid"] = false
    end  
    if id == Gosu::KbSpace
      @player2.buttonLock["bot"] = false
    end 
  end

  def update
    if !@titleLock
      if !@songs[@fightSong].playing?
        @songs[5].stop
        @songs[@fightSong].play
      end  
      #player1
      if Gosu::button_down?(Gosu::KbD)
        @player1.run(1)
      elsif Gosu::button_down?(Gosu::KbA)
        @player1.run(-1)
      else
        @player1.run(0)
      end
      #player2
      if Gosu::button_down?(Gosu::KbL)
        @player2.run(1)
      elsif Gosu::button_down?(Gosu::KbJ)
        @player2.run(-1)
      else
        @player2.run(0)
      end
      #player1
      if Gosu::button_down?(Gosu::KbW)
        if !@player1.buttonLock["jump"]
          @player1.jump
        end
      elsif Gosu::button_down?(Gosu::KbS)
        @player1.dive
      end
      #player2
      if Gosu::button_down?(Gosu::KbI)
        if !@player2.buttonLock["jump"]
          @player2.jump
        end
      elsif Gosu::button_down?(Gosu::KbK)
        @player2.dive
      end
      #player1
		  if Gosu::button_down?(Gosu::KbE)
        if !@player1.buttonLock["top"]
				  @player1.top
			  end
		  elsif Gosu::button_down?(Gosu::KbQ)
        if !@player1.buttonLock["mid"]
				  @player1.mid
			  end
		  elsif Gosu::button_down?(Gosu::KbLeftShift)
        if !@player1.buttonLock["bot"]
				  @player1.bot
			  end
		  end
      #player2
		  if Gosu::button_down?(Gosu::KbU)
        if !@player2.buttonLock["top"]
				  @player2.top
			  end
		  elsif Gosu::button_down?(Gosu::KbO)
        if !@player2.buttonLock["mid"]
				  @player2.mid
			  end
		  elsif Gosu::button_down?(Gosu::KbSpace)
        if !@player2.buttonLock["bot"]
				  @player2.bot
			  end
		  end

      @player1.update
      @player2.update
    
		  10.times{|n|@space.step(@dt)}
		  @player1.reset_forces
		  @player2.reset_forces

      if @player1.stats["health"] <= 0 || @player2.stats["health"] <= 0 
        @player2.reset
        @player1.reset
      end
    else
      if !@songs[5].playing?
        @songs[@fightSong].stop
        @songs[5].play
      end  
      if !@creditScreen
        if Gosu::button_down?(Gosu::KbDown) && !@downButtonLock
          @downButtonLock = true
          @startButtonActive += 1
          #@startButtonActive = @startButtonActive % 3
          if @startButtonActive > 2
            @startButtonActive = 2
          end
          #if @startButtonActive
            #@startButtonActive = false
          #else
            #@startButtonActive = true
			    #end
        end
        if Gosu::button_down?(Gosu::KbUp) && !@upButtonLock 
          @upButtonLock = true
          @startButtonActive -= 1
          if @startButtonActive < 0
            @startButtonActive = 0
          end
          #if @startButtonActive
            #@startButtonActive = false
          #else
            #@startButtonActive = true
			    #end
		    end
      end
       
    end
  end

  def draw
    @background_image.draw(0,0,ZOrder::Background)
    if @creditScreen
    	@titleScreen.draw(0,0,ZOrder::TitleScreen,self.width.to_f/@titleScreen.width,self.height.to_f/@titleScreen.height)
      @font.draw("Jeehun Chung",300,200,ZOrder::Menu,0.8,0.8,Gosu::Color::WHITE) 
      @font.draw("Daniel Fairbanks",300,215,ZOrder::Menu,0.8,0.8,Gosu::Color::WHITE) 
      @font.draw("Kayla Hackett",300,230,ZOrder::Menu,0.8,0.8,Gosu::Color::WHITE) 
      @font.draw("Keegan Mullins",300,245,ZOrder::Menu,0.8,0.8,Gosu::Color::WHITE) 
      @font.draw("Cannon Palmer",300,260,ZOrder::Menu,0.8,0.8,Gosu::Color::WHITE) 
      @font.draw("Soham Tamhane",300,275,ZOrder::Menu,0.8,0.8,Gosu::Color::WHITE) 
		elsif @titleLock
    	@titleScreen.draw(0,0,ZOrder::TitleScreen,self.width.to_f/@titleScreen.width,self.height.to_f/@titleScreen.height)
      @Title.draw("Freedom Fighters",300,220,ZOrder::Menu,1.0,1.0,Gosu::Color::WHITE)
      if @startButtonActive == 0
        @font.draw("Start",20,220,ZOrder::Menu,1.1,1.1,Gosu::Color::RED)
        @font.draw("Credits",20,240,ZOrder::Menu,1.0,1.0,Gosu::Color::BLUE)
        @font.draw("Quit",20,260,ZOrder::Menu,1.0,1.0,Gosu::Color::BLUE)
      elsif @startButtonActive == 1
        @font.draw("Start",20,220,ZOrder::Menu,1.0,1.0,Gosu::Color::BLUE)
        @font.draw("Credits",20,240,ZOrder::Menu,1.1,1.1,Gosu::Color::RED)
        @font.draw("Quit",20,260,ZOrder::Menu,1.0,1.0,Gosu::Color::BLUE)
      else
        @font.draw("Start",20,220,ZOrder::Menu,1.0,1.0,Gosu::Color::BLUE)
        @font.draw("Credits",20,240,ZOrder::Menu,1.0,1.0,Gosu::Color::BLUE)
        @font.draw("Quit",20,260,ZOrder::Menu,1.1,1.1,Gosu::Color::RED)
      end
		end 
    @player1.draw
    @player2.draw
  end

end

window = GameWindow.new
window.show
