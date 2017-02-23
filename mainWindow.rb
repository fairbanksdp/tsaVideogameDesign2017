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
    #@space.damping = 0.9
    #@space.gravity = vec2(0, 4000.0)
    @space.gravity = vec2(0, 10.0)
    @ground = CP::Shape::Segment.new(
			CP::Body.new_static(),
			vec2(0,250), 
			vec2(640,250), 
			1)
    @roof1 = CP::Shape::Segment.new(
			CP::Body.new_static(),
      vec2(0,250), vec2(640,250), 1)
    @ground.e = 0
    @ground.u = 0.05
    @space.add_shape(@ground)
    @player1 = Pres.new("George",true,self)
    @player2 = Pres.new("Abe",false,self)
    
    @background_image = Gosu::Image.new(
			"media/whiteHouse.png", 
			:tileable => true)
    @move

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
						print("#{(a.curAnim == a.anims[str]) && !a.attackLock[str]} ")
            print("#{a.curAnim == a.anims[str]} ")
						print("buttonLock: #{a.buttonLock[str]} ")
						print("attackLock: #{a.attackLock[str]}\n")
						if (a.curAnim == a.anims[str]) && !a.attackLock[str]
            	v.takeHit(10)
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
  end
  def button_up(id)
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
      close
    end
  end

  def draw
    @background_image.draw(0,0,ZOrder::Background)
    @player1.draw
    @player2.draw
  end

end

window = GameWindow.new
window.show
