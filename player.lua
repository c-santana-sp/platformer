Player = {}

function Player:load()
  self.x = 100
  self.y = 0
  self.width = 20
  self.height = 60
  self.xVel = 0
  self.yVel = 100
  self.maxSpeed = 200
  self.acceleration = 4000
  self.jumpAmount = -500
  self.doubleJumpAvailable = false
  self.friction = 3500
  self.gravity = 1500

  self.grounded = false
  self.direction = "right"
  self.state = "idle"

  self:loadAssests()

  self.physics = {}
  self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
  self.physics.body:setFixedRotation(true) -- locks the rotation of a body
  self.physics.shape = love.physics.newRectangleShape(self.width, self.height)
  self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape) -- connects the body to shape

end

function Player:loadAssests()
  self.animation = {timer = 0, rate = 0.1}

  self.animation.run = { total = 6, current = 1, sprites = {} }
  for i = 1, self.animation.run.total do
    self.animation.run.sprites[i] = love.graphics.newImage("assests/player/run/" ..i.. ".png")
  end

  self.animation.idle = { total = 4, current = 1, sprites = {} }
  for i = 1, self.animation.idle.total do
    self.animation.idle.sprites[i] = love.graphics.newImage("assests/player/idle/" ..i.. ".png")
  end

  self.animation.air = { total = 4, current = 1, sprites = {} }
  for i = 1, self.animation.air.total do
    self.animation.air.sprites[i] = love.graphics.newImage("assests/player/air/" ..i.. ".png")
  end

  self.animation.draw = love.graphics.newImage("assests/player/idle/1.png")
  self.animation.width = self.animation.draw:getWidth()
  self.animation.height = self.animation.draw:getHeight()
end

function Player:update(dt)
  self:setState()
  self:setDirection()
  self:animate(dt)
  self:syncPhysics()
  self:move(dt)
  self:applyGravity(dt)
end

function Player:animate(dt)
  self.animation.timer = self.animation.timer + dt
  if self.animation.timer > self.animation.rate then
    self.animation.timer = 0
    self:setNextSpriteFrame()
  end
end

function Player:setNextSpriteFrame()
  local sprite = self.animation[self.state]

  if sprite.current < sprite.total then
    sprite.current = sprite.current + 1
  else
    sprite.current = 1
  end
  print(sprite.current)
  self.animation.draw = sprite.sprites[sprite.current]
end

function Player:setState()
  if not self.grounded then
    self.state = "air"
  elseif self.xVel == 0 then
    self.state = "idle"
  else
    self.state = "run"
  end

  -- print(self.state)
  -- print(self.xVel)
end

function Player:setDirection()
  if self.xVel < 0 then
    self.direction = "left"
  elseif self.xVel > 0 then
    self.direction = "right"
  end
end

function Player:syncPhysics()
  self.x, self.y = self.physics.body:getPosition()
  self.physics.body:setLinearVelocity(self.xVel, self.yVel)
end

function Player:move(dt)
  if love.keyboard.isDown("d", "right") then
    if self.xVel < self.maxSpeed then
      if self.xVel + self.acceleration * dt < self.maxSpeed then
        self.xVel = self.xVel + self.acceleration * dt
      else
        self.xVel = self.maxSpeed
      end
    end
  elseif love.keyboard.isDown("a", "left") then
    if self.xVel > -self.maxSpeed then
      if self.xVel - self.acceleration * dt < self.maxSpeed then
        self.xVel = self.xVel - self.acceleration * dt
      else
        self.xVel = -self.maxSpeed
      end
    end
  else
    self:applyFriction(dt)
  end
end

function Player:jump(key)
  if (key == "w" or key == "up") then
    if self.grounded and not self.doubleJumpAvailable then
      -- print("normal jump")
      self.yVel = self.jumpAmount
      self.grounded = false
      self.doubleJumpAvailable = true
      -- print("double jump")
    elseif not self.grounded and self.doubleJumpAvailable then
      self.yVel = self.jumpAmount * 0.8
      self.grounded = false
      self.doubleJumpAvailable = false
    end
  end
end

function Player:applyFriction(dt)
  if self.xVel > 0 then
    if self.xVel - self.friction * dt > 0 then
      self.xVel = self.xVel - self.friction * dt
    else
      self.xVel = 0
    end
  elseif self.xVel < 0 then
    if self.xVel + self.friction * dt < 0 then
      self.xVel = self.xVel + self.friction * dt
    else
      self.xVel = 0
    end
  end
end

function Player:applyGravity(dt)
  if not self.grounded then
    self.yVel = self.yVel + self.gravity * dt
  end
end

function Player:land(collision)
  self.currentGroundCollision = collision
  self.yVel = 0
  self.grounded = true
  self.doubleJumpAvailable = false
end

function Player:beginContact(a, b, collision)
  if self.grounded == true then return end
  local nx, ny = collision:getNormal()

  if a == self.physics.fixture then
    if ny > 0 then
      self:land(collision)
    elseif ny < 0 then
      self.yVel = 0
    end
  elseif b == self.physics.fixture then
    if ny < 0 then
      self:land(collision)
    elseif ny > 0 then
      self.yVel = 0
    end
  end
end

function Player:endContact(a, b, collision)
  if a == self.physics.fixture or b == self.physics.fixture then
    if self.currentGroundCollision == collision then
      self.grounded = false
    end
  end
end

function Player:draw()
  -- love.graphics.rectangle("fill", self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
  local scaleX = 1
  if self.direction == "left" then
    scaleX = -scaleX
  end
  love.graphics.draw(self.animation.draw, self.x, self.y, 0, scaleX, 1, self.animation.width / 2, self.animation.height / 2)
end
