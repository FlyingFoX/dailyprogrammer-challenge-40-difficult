#!/usr/bin/ruby 
class Point
	attr_accessor :x,:y
	def initialize(x,y)
		@x = x
		@y = y
	end
	
	def to(other_point)
		distance(self, other_point)
	end

	def to_s
		"Point (#{@x}, #{@y})"
	end
end

def generate_points(amount = 1000)
	points = Array.new
	prng = Random.new(1234)
	amount.times do 
		points << Point.new(prng.rand(0.0..1.0), prng.rand(0.0..1.0))
	end
	points
end

def distance(point1, point2)
	Math.sqrt((point1.x - point2.x)**2 + (point1.y - point2.y)**2)
end

class Area
	attr_accessor :neighbors, :points, :top_left, :bottom_right
	def initialize(top_left, bottom_right)
		unless top_left.kind_of? Point and bottom_right.kind_of? Point
			raise "wrong input"
		end
		@top_left = top_left
		@bottom_right = bottom_right
		@neighbors = Array.new
		@points = Array.new
	end
	end

	def in_area?(point)
		point.x >= top_left.x and point.x <= bottom_right and 
				point.y >= bottom_right and point.y <= top_left
	end

	def number_of_points_near
		points.length + neighbors.inject{ |sum, neighbor| sum += neighbor.points.length }
	end
	
	def points_near
		points + neighbors.inject{|other_points, neighbor| other_points += neighbor.points }
	end
end

def find_shortest_distance(points)
	# first sort points into areas 
	# then you have to only compare all points in neighbouring areas for their distance
	areas = create_areas(points)
	shortest_distance = Distance.new(Point.new(0,0), Point.new(1,1))
	areas.each do |area|
		current_distance = find_shortest_distance_in_area(area)
		if shortest_distance.distance > current_distance.distance
			shortest_distance = current_distance
		end
	end
	shortest_distance
end

def find_shortest_distance_in_area(area)
	find_shortest_distance_of_array(area.points_near)
end
		
	
#class used to store the result
class Distance
	attr_accessor :distance, :point1, :point2
	def initialize( point1, point2, distance = nil)
		set(point1, point2, distance)
	end
	def set(point1, point2, distance = nil)
		if distance.nil?
			@distance = point1.to(point2)
		else
			@distance = distance
		end
		@point1 = point1
		@point2 = point2
	end
	def to_s
		"distance between #{point1} and #{point2} is #{@distance}"
	end
end

def find_shortest_distance_of_array(points)
	# make sure we don't have too many points to compare
	if points.count > 9
		raise "Too many points in Array!"
	end

	shortest_distance = Distance.new(Point.new(0,0), Point.new(1,1))
	points.combination(2).each do |point1, point2|
		distance = point1.to point2
		if distance < shortest_distance.distance
			shortest_distance.set(point1, point2, distance)
		end
	end
	shortest_distance
end

def create_areas(points)
	# so we need to find a grid pattern that makes sure that an Area and all its neighbors
	# don't include more than 6 points (maybe 5 is a better upper bound)
	# trial and error
	areas = Array.new
	area_length = Math.sqrt(points.length).floor

	#build area including the left side, excluding the right side
	left = 0
	bottom = 0
	1.upto(area_length) do |x|
		right = 1.0/area_length * x
		1.upto(area_length) do |y|
			top = 1.0/area_length * y
			areas << Area.new(Point.new(left, top), Point.new(right, bottom))
			bottom = top
		end
		left = right
	end

	# add the points to the areas!
	# i am under the impression that i need some kind of area tree to be able to do this
	areas.each do|area|
		if area.in_area?
		end
	end
	areas
end

if __FILE__ == $0
	points = generate_points
	puts "The shortest found distance is:\n#{find_shortest_distance(points)}"
end
