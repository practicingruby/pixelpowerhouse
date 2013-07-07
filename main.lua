require("lua-enumerable")

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

function workerAt(x, y)
  return table.detect(world, function(e) 
    return e.class == "worker" and
           x > e.x - e.width / 2 and
           x < e.x + e.width / 2 and
           y > e.y - e.height / 2 and
           y < e.y + e.height / 2 
  end)
end

function moveWorkers()
  workers = table.select(world, function(e) return e.class == "worker" end)

  -- fixme, should be a select
  wall    = table.detect(world, function(e) return e.class == "wall" end)

  table.each(workers, function(worker)
    if collide(worker, wall) then
      if worker.x < wall.x then
        moveShape(worker, { x = worker.x - 25, y = worker.y })
      else
        moveShape(worker, { x = worker.x + 25, y = worker.y })
      end
    else
      moveShape(worker, worker.destination)
    end
  end)
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

  world = {
    { class = "worker",
      x = 100,
      y = 100,
      width = 20,
      height = 20,
      moving = false,
      destination = { x = 100, y = 100 },
      color = { 255, 0, 0 }
    }, 

    { class = "worker",
      x = 600,
      y = 400,
      width = 20,
      height = 20,
      moving = false,
      destination = { x = 600, y = 400 },
      color = { 255, 50, 50 }
    },

    { class = "widget",
      x      = 300,
      y      = 300,
      width  = 10,
      height = 10,
      color  = { 255, 255, 0 }
    },

    { class = "conveyor",
      x = 600,
      y = 500,
      width = 200,
      height = 50,
      color  = { 33, 33, 33 },
      dy     = 0,
      dx     = 1
    },

    { class = "conveyor",
      x = 700,
      y = 200,
      width = 200,
      height = 50,
      color  = { 33, 33, 33 },
      dy     = 0,
      dx     = 1
    },

    { class = "wall",
      x = 500,
      y = 300,
      width = 10,
      height = 600,
      color  = { 99, 99, 99 },
    },

    { class = "machine",
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
  }

  font = love.graphics.newFont(64)
  love.graphics.setFont(font)

  player = world[1]
  player.color = { 255, 100, 100 }

  widget = world[3]
end

function love.draw()
  if widget.x >= 800 then
    love.graphics.setColor({255,255,255})
    love.graphics.print("You win!", 100,100)
  else
    for i, entity in ipairs(world)  do
      if entity.class ~= "machine" then
        drawRectangle(entity)
      else
        drawRectangle(entity.body)
        drawRectangle(entity.input)
        drawRectangle(entity.output)
      end
    end
  end

--[[
    for i, conveyor in ipairs(conveyors) do
      drawRectangle(conveyor)
    end

    drawRectangle(machine.body)
    drawRectangle(machine.input)
    drawRectangle(machine.output)

    for i, worker in ipairs(workers) do
      drawRectangle(worker)
    end

    drawRectangle(widget)
  end
--]]
end

function love.update(dt)
  moveWorkers()

  --[[ FIXME: integrate into moveWorker()
  for i, worker in ipairs(workers) do
    for i, conveyor in ipairs(conveyors) do
      if collide(widget, conveyor) then
        widget.x = widget.x + conveyor.dx
        widget.y = conveyor.y
      elseif collide(widget, machine.input) then
        widget.x = machine.output.x
        widget.y = machine.output.y

        widget.color = {0, 255, 0}
      elseif collide(widget, worker) then
        widget.x = worker.x
        widget.y = worker.y
      end
    end
  end
  --]]
end

function love.mousepressed(x, y, button)
  if button == "l" then
    worker = workerAt(x, y)

    if worker then
      player.color = { 255, 50, 50 }

      player = worker
      player.color = { 255, 150, 150 }
      player.destination = { x = player.x, y = player.y }
    else
      player.destination = { x = x, y = y }
    end
  end
end
