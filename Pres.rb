class Pres
  attr_accessor :buttonLock, :rigidBody, :shape
  def initialize(img, isFirst, window)
    @window = window
    @image = Gosu::Image.new("media/#{img}")
    @onGround = true
    @secondJump = true
    @dt = 1/60.0
    @buttonLock = Hash.new
    @buttonLock["jump"] = false    
    #@stats = {"jumpH"=>-50000,"speed"=>50000,"health"=>100}
    @stats = {"jumpH"=>-50000,"speed"=>50000,"health"=>100}
    @spriteVars = Hash.new
    verts = [
             vec2(0,0), 
             vec2(@image.width,0), 
             vec2(@image.width,-@image.height), 
             vec2(0,-@image.height)
            ]
    area = CP.area_for_poly(verts)
    mass = 80
    moment = CP.moment_for_box(mass,@image.width,@image.height)
    @rigidBody = CP::Body.new(mass, moment)
    @shape = CP::Shape::Poly.new(@rigidBody, verts, vec2(0,0))
    @shape.e = 0
    @shape.u = 0.4
    @window.space.add_body(@rigidBody)
    @window.space.add_shape(@shape)
    #@rigidBody.apply_force(vec2(0,-10),vec2(0,0))
    if isFirst
      @rigidBody.p.x = 150
      @rigidBody.p.y = 200
      #@rigidBody.slew(vec2(50,200),1/60)
    else
      @rigidBody.p.x = 350
      @rigidBody.p.y = 200
      #@rigidBody.slew(vec2(250,200),1/60)
    end
  end
     
  def move
    #@x += @velX
    #@y += @velY
    #@velY += @accelY 
    #@dampingX = -1*@velX/4
    #@velX += @dampingX
  end
  def run(dir)
    if (dir == 0)
      #@rigidBody.v.x -= @rigidBody.v.x/15
    else
      @rigidBody.apply_force(vec2(dir*@stats["speed"],0), vec2(0,0))
    end
  end 
  def jump
    @buttonLock["jump"] = true
    if @onGround
      @rigidBody.apply_impulse(vec2(0,@stats["jumpH"]), vec2(0,0))
    elsif @secondJump
      #@velY = -1*@stats["jumpH"]    
      @secondJump = false 
      @rigidBody.apply_impulse(vec2(0,@stats["jumpH"]), vec2(0,0))
    end
  end

  def update
    #@rigidBody.update_velocity(@rigidBody.v,0.5,@dt)
    #@rigidBody.update_position(@dt)
    if @rigidBody.p.y <= 249 
      @onGround = false
    else
      @rigidBody.p.y = 250
      #@rigidBody.v.y = 0
      @onGround = true
      @secondJump = true
    end
    #@rigidBody.reset_forces
  end
  def draw
    @rigidBody.reset_forces
    @image.draw(@rigidBody.p.x-(@image.width/2),@rigidBody.p.y-(@image.height/2),ZOrder::Player)
  end
  

  def collisions
    
  end

end

