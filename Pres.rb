class Pres
  attr_accessor :buttonLock, :rigidBody, :shape, :hitBoxes, :dir, :attackLock, :curAnim, :anims, :stats
  def initialize(name, isFirst, window)
    @window = window
		
    @imgStill = Gosu::Image.new("media/#{name}Still.bmp")
    @spriteWidth = @imgStill.width
    @spriteHeight = @imgStill.height

    @healthBar = Gosu::Image.new("media/healthBar.png", :tileable=>true)
		@WIDTH = 0
		@HEIGHT = 0
		@animSizes = 
		{
			"Abe"=>
			{
				"idle"=>{"x"=>135,"y"=>315},"jump"=>{"x"=>105,"y"=>315},
				"walk"=>{"x"=>150,"y"=>315},"top"=>{"x"=>195,"y"=>330},
				"mid"=>{"x"=>180,"y"=>315},"bot"=>{"x"=>315,"y"=>315},"reelback"=>{"x"=>150,"y"=>315}
			},
			"George"=>
			{
				"idle"=>{"x"=>150,"y"=>279},"jump"=>{"x"=>117,"y"=>279},
				"walk"=>{"x"=>150,"y"=>279},"top"=>{"x"=>225,"y"=>300},
				"mid"=>{"x"=>225,"y"=>279},"bot"=>{"x"=>225,"y"=>279},"reelback"=>{"x"=>150,"y"=>279}
			}
		}
    @anims = Hash.new
    @anims["idle"] = Gosu::Image::load_tiles(
      "media/#{name}Idle.png", 
			@animSizes["#{name}"]["idle"]["x"], 
			@animSizes["#{name}"]["idle"]["y"]
		)
    @anims["jump"] = Gosu::Image::load_tiles(
      "media/#{name}Jump.png", 
			@animSizes["#{name}"]["jump"]["x"], 
			@animSizes["#{name}"]["jump"]["y"]
		)
    @anims["walk"] = Gosu::Image::load_tiles(
      "media/#{name}Walk.png", 
			@animSizes["#{name}"]["walk"]["x"], 
			@animSizes["#{name}"]["walk"]["y"]
		)
    @anims["top"] = Gosu::Image::load_tiles(
      "media/#{name}AttackTop.png", 
			@animSizes["#{name}"]["top"]["x"], 
			@animSizes["#{name}"]["top"]["y"]
		)
    @anims["mid"] = Gosu::Image::load_tiles(
      "media/#{name}AttackMid.png", 
			@animSizes["#{name}"]["mid"]["x"], 
			@animSizes["#{name}"]["mid"]["y"]
		)
    @anims["bot"] = Gosu::Image::load_tiles(
      "media/#{name}AttackBot.png", 
			@animSizes["#{name}"]["bot"]["x"], 
			@animSizes["#{name}"]["bot"]["y"]
		)
    @anims["reelback"] = Gosu::Image::load_tiles(
      "media/#{name}Reelback.png", 
      @animSizes["#{name}"]["reelback"]["x"], 
      @animSizes["#{name}"]["reelback"]["y"]
    )
    #@animFrameDist = {"jump"=>0,"idle" HEIGHT/@image.height
		@scaleX = @imgStill.width/105.to_f
		@scaleY = @imgStill.height/315.to_f
   
    setAnimTo("idle")
    
    @onGround = true
    @secondJump = true

    @buttonLock = {"jump"=>false,"top"=>false,"mid"=>false,"bot"=>false}    
    @attackLock = {"top"=>false,"mid"=>false,"bot"=>false}    

    @stats = {"jumpH"=>-2000,"speed"=>500,"health"=>100}

    verts = [
             vec2(0,0), 
             vec2(@spriteWidth,0), 
             vec2(@spriteWidth,-@spriteHeight), 
             vec2(0,-@spriteHeight)
            ]
    area = CP.area_for_poly(verts)
    mass = 80
    moment = CP.moment_for_box(mass,@imgStill.width,@imgStill.height)
    @rigidBody = CP::Body.new(mass, moment)
    @shape = CP::Shape::Poly.new(@rigidBody, verts, vec2(0,0))
    @shape.e = 0
    @shape.u = 0.4
    @shape.collision_type = :player
    @shape.group = self

    verts[2].y = verts[2].y/3
    verts[3].y = verts[3].y/3
    @hitBoxes = 
    {
      "topRight"=>CP::Shape::Poly.new(@rigidBody, verts, vec2(-@spriteWidth-1,-1)),
      "topLeft"=>CP::Shape::Poly.new(@rigidBody, verts, vec2(@spriteWidth+1,-1)),
      "midRight"=>CP::Shape::Poly.new(@rigidBody, verts, vec2(-@spriteWidth-1,(@spriteHeight/3.0)-1)),
      "midLeft"=>CP::Shape::Poly.new(@rigidBody, verts, vec2(@spriteWidth+1,(@spriteHeight/3.0)-1)),
      "botRight"=>CP::Shape::Poly.new(@rigidBody, verts, vec2(-@spriteWidth-1,(2*@spriteHeight/3.0)-1)),
      "botLeft"=>CP::Shape::Poly.new(@rigidBody, verts, vec2(@spriteWidth+1,(2*@spriteHeight/3.0)-1))
    }
    @hitBoxes.each_value {|n|n.collision_type = :hitBox}
    @hitBoxes.each_value {|n|n.sensor = true}
    @hitBoxes.each_value {|n|n.group = self}
    #@hitBoxes["topRight"].collision_type = :hitBox
    #@hitBoxes["topLeft"].collision_type = :hitBox
    #@hitBoxes["midRight"].collision_type = :hitBox
    #@hitBoxes["midLeft"].collision_type = :hitBox
    #@hitBoxes["botRight"].collision_type = :hitBox
    #@hitBoxes["botLeft"].collision_type = :hitBox
    
    @window.space.add_body(@rigidBody)
    @window.space.add_shape(@shape)
    @hitBoxes.each_value {|n| @window.space.add_shape(n)}
		@isFirst = isFirst
    if isFirst
      @rigidBody.p.x = 150
      @rigidBody.p.y = 200
      @dir = -1
    else
      @rigidBody.p.x = 350
      @rigidBody.p.y = 200
      @dir = 1
    end
  end
     
  def run(dir)
    if dir == 0
      @rigidBody.v.x -= @rigidBody.v.x/10
      @rigidBody.apply_force(
        vec2(dir*@stats["speed"],0), vec2(0,0)
      )
    elsif dir * @rigidBody.v.x < 0
      if @onGround
        @rigidBody.v.x = 0
        @rigidBody.apply_force(
          vec2(dir*@stats["speed"],0), vec2(0,0)
        )
				if @curAnim != @anims["jump"]
					@curAnim = @anims["walk"]
				end
      else
        @rigidBody.v.x -= @rigidBody.v.x/12
        @rigidBody.apply_force(
          vec2(dir*@stats["speed"]/2,0), vec2(0,0)
        )
      end 
    else 
      if @onGround
        @rigidBody.apply_force(
          vec2(dir*@stats["speed"],0), vec2(0,0)
        )
				if @curAnim != @anims["jump"]
					@curAnim = @anims["walk"]
				end
      else
        @rigidBody.apply_force(
          vec2(dir*@stats["speed"]/2,0), vec2(0,0)
        )
      end
    end
  end 

  def jump
    @buttonLock["jump"] = true
    if @onGround
      #@rigidBody.apply_impulse(vec2(0,@stats["jumpH"]), vec2(0,0))
    	setAnimTo("jump")
    elsif @secondJump
      @secondJump = false 
      #@rigidBody.apply_impulse(vec2(0,@stats["jumpH"]), vec2(0,0))
    	setAnimTo("jump")
    end
    #@curAnim = @anims["jump"]
    #@curFrame = @curAnim[0]
  end
  def dive
    if !@onGround && @curAnim == @anims["jump"]
      @rigidBody.apply_impulse(vec2(0,-2*@stats["jumpH"]/4), vec2(0,0))
			@framePos = 8
    end
  end
	
	def top
    @buttonLock["top"] = true
		setAnimTo("top")
	end
	def mid
    @buttonLock["mid"] = true
		setAnimTo("mid")
	end
	def bot
    @buttonLock["bot"] = true
    setAnimTo("bot")
	end

  def update
    if curAnim?("reelback")
			cyclesPerFrame = 4
			frameTick(cyclesPerFrame)
    elsif @curAnim == @anims["top"]
			cyclesPerFrame = 2
			frameTick(cyclesPerFrame)
			@rigidBody.v = vec2(0,0)
    elsif @curAnim == @anims["mid"]
			cyclesPerFrame = 2
			frameTick(cyclesPerFrame)
			@rigidBody.v = vec2(0,0)
    elsif @curAnim == @anims["bot"]
			cyclesPerFrame = 2
			frameTick(cyclesPerFrame)
			@rigidBody.v = vec2(0,0)
    elsif @curAnim == @anims["jump"]
			cyclesPerFrame = 4
			if @framePos < 3
				frameTick(cyclesPerFrame)
			elsif @framePos.to_i == 3 && @onGround
      	@rigidBody.apply_impulse(vec2(0,@stats["jumpH"]), vec2(0,0))
      	@onGround = false
				cyclesPerFrame = 1
			elsif @rigidBody.v.y.abs < 15 && @framePos < 4 
				frameTick(cyclesPerFrame)
			elsif @rigidBody.v.y.abs <= 5 && @framePos < 5
				frameTick(cyclesPerFrame)
			elsif @rigidBody.v.y.abs > 5 && @framePos < 6 && @framePos > 5
				frameTick(cyclesPerFrame)
			elsif @rigidBody.v.y.abs > 15 && @framePos < 7 && @framePos > 4
				frameTick(cyclesPerFrame)
			elsif @rigidBody.p.y >= 229 && @framePos < 9 && @framePos > 5
				frameTick(cyclesPerFrame)
			elsif @rigidBody.p.y >= 248
				frameTick(cyclesPerFrame)
			end
		elsif @curAnim == @anims["walk"]
			cyclesPerFrame = 10
			frameTick(cyclesPerFrame)
			if @rigidBody.v.x.abs < 10
				frameTick(1.0/@curAnim.length)
			elsif @curAnim == @anims["idle"] 
				@curAnim = @anims["walk"]
				@curFrame = @curAnim[@framePos.to_i]
			end
		end
	
    if @rigidBody.p.y <= 249 
      @onGround = false
      #@curAnim = @anims["jump"]
      
      frame = ((@curAnim.length + (@rigidBody.v.y/@curAnim.length))/2).round - 1
      #@curFrame = @curAnim[frame]
      #print("anim length: #{@curAnim.length} force: #{@rigidBody.force.y} y speed: #{@rigidBody.v.y} frame: #{@framePos}\n")
    else
      @rigidBody.p.y = 250
      @onGround = true
      @secondJump = true
      #@curAnim = @anims["idle"]
    end
		if @rigidBody.p.x < 0 
			@rigidBody.p.x = 0
		elsif @rigidBody.p.x > @window.width
			@rigidBody.p.x = @window.width
		end
		@rigidBody.a = 0
    force = @rigidBody.force.x
    if force != 0
      @dir = -force/force.abs
    end
  end
  def reset_forces
    @rigidBody.reset_forces
  end

  def draw
		#img = @image[Gosu::milliseconds/SPEED % @image.size]
    if @curAnim == @anims["idle"]
			frameTick(8)
			releaseLock = @attackLock.each.map do |m,n|
				if n
					m
				end
			end
			releaseLock.each {|n|@attackLock[n] = false}
      #@curFrame = @curAnim[Gosu::milliseconds/83 % @curAnim.length]
      #@curFrame = @imgStill
    end
		if @isFirst
    	@healthBar.draw(@window.width/2, 0, ZOrder::UI, -1*@stats["health"]*(@window.width/2.0)/(100.0*@healthBar.width), 1)
		elsif
    	@healthBar.draw(@window.width/2, 0, ZOrder::UI, @stats["health"]*(@window.width/2.0)/(100.0*@healthBar.width), 1)
		end
    #@healthBar.draw(@window.width/2, 0, ZOrder::UI,1,1)
    @curFrame.draw(@rigidBody.p.x-(@dir * @scaleX * @curFrame.width/2),
              @rigidBody.p.y-(@scaleY * @curFrame.height/2),
              ZOrder::Player,
              @dir * @scaleX, #(@imgStill.width.to_f/@curFrame.width), 
							@scaleY #@imgStill.height/@curFrame.height.to_f
    )
  end
  
	def animate(sec)
		#s = c/f * s/c * f
		#sc/fs = c/f
		cyclesPerFrame = sec*60.0/@curAnim.length
		@framePos += 1.0/cyclesPerFrame
		frame = @framePos.to_i
    if frame < @curAnim.length
      @curFrame = @curAnim[frame]
    else
			@attackLock.each_value {|n|n=false}
			setAnimTo("idle")
    end
		return frame
	end
  def frameTick(speed)
		@framePos += 1.0/speed
    frame = @framePos.to_i
    if frame < @curAnim.length
      @curFrame = @curAnim[frame]
    else
			@attackLock.each_value {|n|n=false}
			setAnimTo("idle")
    end
		return frame
  end
	def framePos(speed)
    return @framePos.to_i
	end
	def setAnimTo(anim)
		@framePos = 0 
		@curAnim = @anims[anim]
		@curFrame = @curAnim[@framePos]
	end
  def curAnim?(anim)
    return (@curAnim == @anims[anim])
  end

	def takeHit(damage)
    setAnimTo("reelback")
    @stats["health"] -= damage
	end

  def collisions
    
  end

end

