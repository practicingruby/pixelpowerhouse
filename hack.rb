require 'ray'

class Worker
  def initialize
    @waypoints = []
    @position  = [200, 200].to_vector2
  end

  def add_waypoint(point)
    @waypoints << point
  end

  attr_reader :waypoints, :position

  def move
    @position = @position + velocity
  end

  def velocity
   @waypoints.shift if @waypoints.first && @waypoints.first.distance(@position) < 1
   return [0,0].to_vector2 if @waypoints.empty?

   p1 = @position
   p2 = @waypoints.first

   dx = (p1.x == p2.x) ? 0 : (p1.x < p2.x ? 1 : -1)
   dy = (p1.y == p2.y) ? 0 : (p1.y < p2.y ? 1 : -1)

   return [dx, dy].to_vector2
  end

  def stop
    @waypoints.clear
  end
end

class Widget
  def initialize(position)
    @position = position
  end

  attr_accessor :position

  def touching?(entity)
    @position.inside?(entity)
  end
end

class Machine
  def initialize(center, input, output)
    @center = center
    @input  = input
    @output = output
  end

  def process(w)
    w.position = output #+ [rand(25..50), rand(25..50)]
  end

  attr_accessor :center, :input, :output
end

Ray.game("Machine") do
  register { add_hook :quit, method(:exit!) }

  scene :main do
    worker  = Worker.new
    widgets = 5.times.map { Widget.new([rand(100..300), rand(100..300)].to_vector2) }

    machine = Machine.new([300,300].to_vector2, 
                          [275, 300].to_vector2,
                          [325, 300].to_vector2)

    on :key_press, key(:escape) do
      worker.stop
    end

    on :mouse_press do |button, pos|
      worker.add_waypoint(pos)
    end

    always { worker.move }

    render do |win|

      machine_shape = Ray::Polygon.rectangle([-25, -25, 50, 50], Ray::Color.green)
      machine_shape.pos = machine.center

      machine_input = Ray::Polygon.rectangle([-12.5, -12.5, 25, 25], Ray::Color.cyan)
      machine_input.pos = machine.input

      machine_output = Ray::Polygon.rectangle([-12.5, -12.5, 25, 25], Ray::Color.cyan)
      machine_output.pos = machine.output

      player = Ray::Polygon.rectangle([-10, -10, 20, 20], Ray::Color.red)
      player.pos = worker.position


      win.draw(machine_shape)
      win.draw(machine_input)
      win.draw(machine_output)

      win.draw(player)

      worker.waypoints.each do |w|
        marker     = Ray::Polygon.rectangle([-2.5, -2.5, 5, 5], Ray::Color.green)
        marker.pos = w

        win.draw(marker)
      end

      widgets.each do |w|
        if w.touching?([machine.input.x - 12.5, machine.input.y - 12.5, 25, 25].to_rect)
          machine.process(w)
        elsif w.touching?([player.x - 10, player.y - 10, 20, 20].to_rect)
          w.position = player.position
        end

        widget_rect = Ray::Polygon.rectangle([-5, -5, 10, 10], Ray::Color.yellow)
        widget_rect.pos = w.position

        win.draw(widget_rect)
      end
    end
  end


  scenes << :main
end
