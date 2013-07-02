function collide(sa, sb)
  leftA    = sa.x - sa.width / 2
  rightA   = sa.x + sa.width / 2
  topA     = sa.y - sa.height / 2
  bottomA  = sa.y + sa.height / 2

  leftB    = sb.x - sb.width / 2
  rightB   = sb.x + sb.width / 2
  topB     = sb.y - sb.height / 2
  bottomB  = sb.y + sb.height / 2

  return bottomA > topB and topA < bottomB and rightA > leftB and leftA < rightB 
end

function drawRectangle(rect)
  love.graphics.setColor(rect.color)
  love.graphics.rectangle("fill", rect.x - rect.width / 2, 
                                  rect.y - rect.height / 2, 
                                  rect.width, rect.height)
end

function moveShape(shape, destination)
  dx = 0
  dy = 0

  if shape.x < destination.x then
    dx = 1
  elseif shape.x > destination.x then
    dx = -1
  end

  if shape.y < destination.y then
    dy = 1
  elseif shape.y > destination.y then
    dy = -1
  end

  shape.x = shape.x + dx
  shape.y = shape.y + dy
end

function love.load()
  player = {
    x = 100,
    y = 100,
    width = 20,
    height = 20,
    moving = false,
    destination = { x = 100, y = 100 },
    color = { 255, 0, 0 }
  }

  widget = {
    x      = 300,
    y      = 300,
    width  = 10,
    height = 10,
    color  = { 255, 255, 0 }
  }

  machine  = {
    body = {
      x = 500,
      y = 500,
      width  = 50,
      height = 50, 
      color  = { 125, 0, 125 }
    },

    input = {
      x = 475,
      y = 500,
      width = 25,
      height = 25,
      color  = { 255, 0, 255 }
    },

    output = {
      x = 525,
      y = 500,
      width  = 25,
      height = 25,
      color  = { 255, 0, 255 }
    }
  }

  conveyor = {
    x = 650,
    y = 500,
    width = 300,
    height = 50,
    color  = { 33, 33, 33 },
    dy     = 0,
    dx     = 1
  }

  wall = {
    x = 500,
    y = 300,
    width = 10,
    height = 600,
    color  = { 99, 99, 99 },
  }

  font = love.graphics.newFont(64)
  love.graphics.setFont(font)
end

function love.draw()
  if widget.x >= 800 then
    love.graphics.setColor({255,255,255})
    love.graphics.print("You win!", 100,100)
  else
    drawRectangle(wall)
    drawRectangle(conveyor)
    drawRectangle(machine.body)
    drawRectangle(machine.input)
    drawRectangle(machine.output)

    drawRectangle(player)
    drawRectangle(widget)
  end
end

function love.update(dt)
  if collide(player, wall) then
    moveShape(player, { x = wall.x - 25, y = player.y })
  else
    moveShape(player, player.destination)
  end

  if collide(widget, conveyor) then
    widget.x = widget.x + conveyor.dx
    widget.y = conveyor.y
  elseif collide(widget, machine.input) then
    widget.x = machine.output.x
    widget.y = machine.output.y

    widget.color = {0, 255, 0}

  elseif collide(widget, player) then
    widget.x = player.x
    widget.y = player.y
  end
end

function love.mousepressed(x, y, button)
  if button == "l" then
    player.destination = { x = x, y = y }
  end
end
