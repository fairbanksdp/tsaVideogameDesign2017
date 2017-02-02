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
    @ground = CP::Shape::Segment.new(CP::Body.new_static(),
      vec2(0,250), vec2(640,250), 1)
    @ground.e = 0
    @ground.u = 0.05
    @space.add_shape(@ground)
    @player1 = Pres.new("pres1.bmp",true,self)
    @player2 = Pres.new("pres16.bmp",false,self)
    
    @background_image = Gosu::Image.new("media/whiteHouse.png", :tileable => true)
    @move
    
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
    if Gosu::button_down?(Gosu::KbW)
      if !@player1.buttonLock["jump"]
        @player1.jump
      end
    end
    @player1.move
    @player1.update
    #player2
    @player2.update
    #player1
    
    #player2
    @space.step(@dt)
  end

  def draw
    @background_image.draw(0,0,ZOrder::Background)
    @player1.draw
    @player2.draw
  end

end

window = GameWindow.new
window.show
