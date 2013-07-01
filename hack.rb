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

=begin
Ray.game "Test" do
  register { add_hook :quit, method(:exit!) }

  scene :square do
    @rect = Ray::Polygon.rectangle([0, 0, 20, 20], Ray::Color.red)
    @rect.pos = [200,200]

    max_x = window.size.width - 20
    max_y = window.size.height - 20

    @goodies = 20.times.map do 
      x = rand(max_x) + 10
      y = rand(max_y) + 10
      
      g  = Ray::Polygon.rectangle([0,0,10,10])
      g.pos = [x,y]

      g
    end

    max_x = window.size.width  - 30
    max_y = window.size.height - 30

    @baddies = 5.times.map do
      x = rand(max_x) + 15
      y = rand(max_y) + 15
      g = Ray::Polygon.rectangle([0,0,15,15], Ray::Color.blue)
      g.pos += [x,y]
      g
    end
    
    always do
      if @rect.pos.x - 2 > 0
        @rect.pos += [-2, 0] if holding?(:left)
      end
 
      if @rect.pos.x + 2 < window.size.width
        @rect.pos += [2, 0] if holding?(:right)
      end

      if @rect.pos.y - 2 > 0
        @rect.pos += [0, -2] if holding?(:up)
      end

      if @rect.pos.y + 2 < window.size.height
        @rect.pos += [0, 2] if holding?(:down)
      end

      @goodies.reject! { |e| 
        [e.pos.x, e.pos.y, 10, 10].to_rect.inside?([@rect.pos.x, @rect.pos.y, 20, 20])
      }

      @baddies.each do |e|
        if e.pos.x < @rect.pos.x
          e.pos += [rand*2.5,0]
        else
          e.pos -= [rand*2.5,0]
        end

        if e.pos.y < @rect.pos.y
          e.pos += [0, rand*2.5]
        else
          e.pos -= [0, rand*2.5]
        end
      end

      @game_over ||= @baddies.any? { |e|
        [e.pos.x, e.pos.y, 15, 15].to_rect.collide?([@rect.pos.x, @rect.pos.y, 20,20])
      }
    end

    render do |win|
      if @goodies.empty?
        win.draw text("YOU WIN", :at => [100,100], :size => 60)
      elsif @game_over
        win.draw text("YOU LOSE", :at => [100,100], :size => 60)
      else
        @goodies.each { |g| win.draw(g) }
        @baddies.each { |g| win.draw(g) }
        win.draw @rect
      end
    end
  end

  scenes << :square
end
=end
