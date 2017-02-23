require 'gosu'

class Animation
  def initialize(x, y, speed, image)
    @image = image
    @speed = speed
    @width = @image[0].width
    @height = @image[0].height
    @x = x
    @y = y
  end

  attr_accessor :x, :y, :image, :width, :height, :speed

  def draw
    img = @image[Gosu::milliseconds / @speed % @image.size];
    img.draw(@x - @width/2, @y - @height/2, 2, 3, 3)
  end
end
