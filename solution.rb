#!/usr/bin/ruby 
require 'math'
class Point
	attr_accessor :x,:y
	def initialize(x,y)
		@x = x
		@y = y
	end
end

def generate_points
	points = Array.new
	prng = Random.new(1234)
	1000.times do 
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
		unless top_left.kind_of Point and bottom_right.kind_of Point
			raise "wrong input"
		end
		@top_left = top_left
		@bottom_right = bottom_right
	end
	def in_area?(point)
		point.x >= top_left.x and point.x <= bottom_right and 
		point.y >= bottom_right and point.y <= top_left
	end
	def points_near
		points.length + neighbors.inject{ |sum, neighbor| sum += neighbor.points.length }
	end
end

def find_shortest_distance(points)
	# first sort points into areas 
	# then you have to only compare all points in neighbouring areas for their distance


end

def create_areas(points)
	# so we need to find a grid pattern that makes sure that an Area and all its neighbors
	# don't include more than 6 points (maybe 5 is a better upper bound)
	# trial and error
	areas = Array.new
	area_length = Math.floor(Math.sqrt(points.length))

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
	areas
end

if __FILE__ == $0
	points = generate_points
	find_shortest_distance(points)
end
