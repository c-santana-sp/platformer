local STI = require("sti")
require("player")
local Camera = require("camera")
love.graphics.setDefaultFilter("nearest", "nearest")

function love.load()
  Map = STI("map/1.lua", {"box2d"})
  World = love.physics.newWorld(0, 0)

  World:setCallbacks(beginContact, endContact)

  Map:box2d_init(World)
  Map.layers.solid.visible = false

  background = love.graphics.newImage("assets/background.png")
  Player:load()
end

function love.update(dt)
  World:update(dt)
  Player:update(dt)

  Camera:setPosition(Player.x, Player.y )
end

function love.draw()
  love.graphics.draw(background)
  Map:draw(-Camera.x, -Camera.y, Camera.scale, Camera.scale)
  love.graphics.push()
  love.graphics.scale(2, 2)

  Camera:apply()
  Player:draw()
  Camera:clear()

  love.graphics.pop()
end

function love.keypressed(key)
  Player:jump(key)

  if key == "escape" then
    love.event.quit()
  end
end

function beginContact(a, b, collision)
  Player:beginContact(a, b, collision)
end

function endContact(a, b, collision)
  Player:endContact(a, b, collision)
end
