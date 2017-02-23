require 'gosu'
require './animation'

class Tester < Gosu::Window
  def initialize
    super 1920, 1080, true
    self.caption = "Game"
    @AbeSweep = Animation.new(500, 500, 40, Gosu::Image::load_tiles("images/AbeSweep.png", 105, 105))
    @AbeHatAttack = Animation.new(500, 500, 25, Gosu::Image::load_tiles("images/AbeHatAttack.png", 65, 110))
    @AbeMidAttack = Animation.new(500, 500, 40, Gosu::Image::load_tiles("images/AbeMidAttack.png", 60, 105))
    @AbeJump = Animation.new(500, 500, 100, Gosu::Image::load_tiles("images/AbeJump.png", 35, 105))

    @animation = @AbeMidAttack
  end

  def update
    if Gosu::button_down? Gosu::KbW then
      @animation.y -= 15
    end
    if Gosu::button_down? Gosu::KbS then
      @animation.y += 15
    end
    if Gosu::button_down? Gosu::KbD then
      @animation.x += 15
    end
    if Gosu::button_down? Gosu::KbA then
      @animation.x -= 15
    end

    if Gosu::button_down? Gosu::KbK then
      @animation = @AbeMidAttack
    end
    if Gosu::button_down? Gosu::KbJ then
      @animation = @AbeHatAttack
    end
    if Gosu::button_down? Gosu::KbL then
      @animation = @AbeSweep
    end
    if Gosu::button_down? Gosu::KbSpace then
      @animation = @AbeJump
    end

  end

  def draw
    @animation.draw
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end
end

window = Tester.new
window.show
