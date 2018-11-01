
require 'gosu'

class Snake

attr_accessor :direction, :xpos, :ypos, :speed, :length, :segments, :ticker

	def initialize(window)
		@window = window
		@xpos = 200
		@ypos = 200
		@segments = []
		@direction = "derecha"
		@head_segment = Segment.new(self, @window, [@xpos, @ypos])
		@segments.push(@head_segment)
		@speed = 2
		@length = 1
		@ticker = 0
		
  end

	def draw
		@segments.each do |s|
			s.draw
		end
	end

	def update_position

		add_segment
		@segments.shift(1) unless @ticker > 0

	end

	def add_segment
		
		if @direction == "izquierda"
			xpos = @head_segment.xpos - @speed
			ypos = @head_segment.ypos
			new_segment = Segment.new(self, @window, [xpos, ypos])
		end

		if @direction == "derecha"
			xpos = @head_segment.xpos + @speed
			ypos = @head_segment.ypos
			new_segment = Segment.new(self, @window, [xpos, ypos])
		end

		if @direction == "arriba"
			xpos = @head_segment.xpos
			ypos = @head_segment.ypos - @speed
			new_segment = Segment.new(self, @window, [xpos, ypos])
		end

		if @direction == "abajo"
			xpos = @head_segment.xpos
			ypos = @head_segment.ypos + @speed
			new_segment = Segment.new(self, @window, [xpos, ypos])
		end

		@head_segment = new_segment
		@segments.push(@head_segment)

	end

	def ate_apple?(apple)
		if Gosu::distance(@head_segment.xpos, @head_segment.ypos, apple.xpos, apple.ypos) < 10
			return true
		end
	end

	def hit_self?
		segments = Array.new(@segments)
		if segments.length > 21
			segments.pop((10 * @speed))
			segments.each do |s|
				if Gosu::distance(@head_segment.xpos, @head_segment.ypos, s.xpos, s.ypos) < 11
					puts "true, head: #{@head_segment.xpos}, #{@head_segment.ypos}; seg: #{s.xpos}, #{s.ypos}"
					return true
				else
					next
				end
			end
			return false
		end

	end

	def outside_bounds?
		if @head_segment.xpos < 0 or @head_segment.xpos > 630
			return true
		elsif @head_segment.ypos < 0 or @head_segment.ypos > 470
			return true
		else
			return false
		end
	end

end

class Segment

	attr_accessor :xpos, :ypos
	def initialize(snake, window, position)
		@window = window
		@xpos = position[0]
		@ypos = position[1]
	end

	def draw
		@window.draw_quad(@xpos,@ypos,Gosu::Color::YELLOW,@xpos + 10,@ypos,Gosu::Color::YELLOW,@xpos,@ypos + 10,Gosu::Color::YELLOW,@xpos + 10,@ypos + 10,Gosu::Color::YELLOW)
	end

end

class Apple

attr_reader :xpos, :ypos

	def initialize(window)
		@window = window
		@xpos = rand(10..630)
		@ypos = rand(50..470)
	end

	def draw
		@window.draw_quad(@xpos,@ypos,Gosu::Color::RED,@xpos,@ypos + 10,Gosu::Color::RED,@xpos + 10,@ypos,Gosu::Color::RED,@xpos + 10,@ypos + 10, Gosu::Color::RED)
	end
end


class GameWindow < Gosu::Window
	def initialize
		super 640, 480, false
		self.caption = "Snake"
		@snake = Snake.new(self)
		@apple = Apple.new(self)
		@score = 0

		@text_object = Gosu::Font.new(self, 'Ubuntu Sans', 20)

	end

	def update

		if button_down? Gosu::KbLeft and @snake.direction != "derecha"
			@snake.direction = "izquierda"
		end
		if button_down? Gosu::KbRight and @snake.direction != "izquierda"
			@snake.direction = "derecha"
		end
		if button_down? Gosu::KbUp and @snake.direction != "abajo"
			@snake.direction = "arriba"
		end
		if button_down? Gosu::KbDown and @snake.direction != "arriba"
			@snake.direction = "abajo"
		end

		if button_down? Gosu::KbEscape
			self.close
		end

		if @snake.ate_apple?(@apple)
			@apple = Apple.new(self)
			@score += 10
			@snake.length += 10
			
			@snake.ticker += 11
			if @score % 100 == 0
				@snake.speed += 0.5
			end
		end

		if @snake.hit_self?
			@new_game = Gosu::Font.new(self, 'Ubuntu Sans', 32)
		end

		if @snake.outside_bounds?
			@new_game = Gosu::Font.new(self, 'Ubuntu Sans', 32)
		end

		if @new_game and button_down? Gosu::KbReturn
			@new_game = nil
			@score = 0
			@snake = Snake.new(self)
			@apple = Apple.new(self)
		end

		@snake.ticker -= 1 if @snake.ticker > 0
	end

	def draw

		if @new_game
			@new_game.draw("Puntuación #{@score}", 5, 200, 100)
			@new_game.draw("Presiona para jugar de nuevo", 5, 250, 100)
			@new_game.draw("Esc para salir", 5, 300, 100)
		else
			@snake.update_position
			@snake.draw
			@apple.draw
			@Level = "Nivel: 1"
			@text_object.draw("Puntuación: #{@score}",2,2,0)
			if @score >= 50  && @score < 100
				@snake.speed  = 3
				@Level = "Nivel 2"
				
			elsif @score >= 100 && @score < 150
				@snake.speed = 5
				@Level = "Nivel 3"
			elsif @score >= 150 && @score < 200
				@snake.speed = 7
				@Level = "Nivel 4"
			elsif @score >= 200 && @score < 250
				@snake.speed = 9
				@Level = "Nivel 5"
			end

			@text_object.draw(@Level,20,20,0)

		end
	end
end

window = GameWindow.new
window.show
