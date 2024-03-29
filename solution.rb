#!/usr/bin/ruby1.9.1

class Point
  attr_accessor :x,:y
  def initialize(x,y)
    @x = x
    @y = y
  end

  def to(other_point)
    distance(self, other_point)
  end
  
  def ==(point)
    @x == point.x && @y == point.y
  end

  def to_s
    "Point (#{@x}, #{@y})"
  end
end

class Area
  attr_accessor :top_left, :bottom_right
  attr_reader :points, :neighbors, :last_split_direction
  def initialize(top_left, bottom_right, last_split_direction = :horizontal)
    unless top_left.kind_of? Point and bottom_right.kind_of? Point
      raise "wrong input: top_left = #{top_left} and bottom_right = #{bottom_right}"
    end
    @top_left = top_left
    @bottom_right = bottom_right
    @neighbors = Array.new
    @points = Array.new
    @last_split_direction = last_split_direction
  end

  # Areas are equal if they define the same area. Points and neighbors are ignored.
  def ==(area)
    @top_left == area.top_left && @bottom_right == area.bottom_right
  end

  def to_svg(zoom = 100)
    svg = "<rect x=\"#{left*zoom}\" y = \"#{top*zoom}\" width = \"#{(right - left)*zoom}\" height = \"#{(top - bottom)*zoom}\" />"
  end

  def to_s
    representation = "Area##{self.__id__}, top_left=#{@top_left}, bottom_right=#{@bottom_right}, neighbors=#{@neighbors.map{|neighbor| neighbor.__id__}}, points#=#{@points.count}, last_split_direction=#{@last_split_direction}"
  end

  def pp
    "#{top_left} #{bottom_right} #{points.count} #{last_split_direction}" 
  end

  def last_split_direction=(direction)
    if not [:horizontal, :vertical].include?(direction)
      raise "wrong direction!"
    end
    @last_split_direction = direction
  end

  def add_point(point)
    if self.contains?(point)
      points << point
    end
  end
  
  def add_neighbor(area)
    if is_neighbor_of area
      @neighbors << area
    end
  end

  def is_neighbor_of(area)
    overlapping_horizontal = left <= area.right && right >= area.left
    overlapping_vertical = bottom <= area.top && top >= area.bottom
    overlapping_horizontal && overlapping_vertical
  end

  def top
    @top_left.y
  end

  def left
    @top_left.x
  end

  def right
    @bottom_right.x
  end

  def bottom
    @bottom_right.y
  end

  def contains?(point)
    horizontal_ok = (point.x >= self.left && (point.x < self.right || (point.x == self.right && self.right == 1.0)))
    vertical_ok = (point.y >= self.bottom && (point.y < self.top || (point.y <= self.top && self.top == 1.0)))
    horizontal_ok && vertical_ok
  end

  def number_of_points_near
    if neighbors.nil? or neighbors.count == 0
      points.count
    else
      points.count + neighbors.inject(0) do |sum, neighbor| 
        if neighbor.points.nil?
          sum
        else
          sum + neighbor.points.count 
        end
      end
    end
  end

  def points_near
    points + neighbors.inject([]){|other_points, neighbor| other_points += neighbor.points }
  end
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

def find_shortest_distance(points)
  # first sort points into areas 
  # then you have to only compare all points in neighbouring areas for their distance
  areas = create_areas(points)
  puts "#{areas.count} Areas created"
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

=begin
This function takes an array containing all relevant areas and the area that shall be split.
=end
def split_area(areas, area)
	unless areas.kind_of?(Array) and area.kind_of?(Area)
		raise "wrong argument: areas=#{areas}, area=#{area}"
	end
	if area.last_split_direction == :horizontal
		new_areas = split_vertical(areas, area)
	elsif area.last_split_direction == :vertical
		new_areas = split_horizontal(areas, area)
	else
		raise "wrong argument error: area=#{area}"
	end
	transfer_points(area, new_areas)
	rebuild_neighbors(area, new_areas)
	areas.delete(area)
	areas.concat(new_areas)
end

=begin
rebuilds all neighbor associations for the derivatives.
derivatives will include all neighbors of the source and each other as neighbors.
=end
def rebuild_neighbors(source, derivatives)
	derivatives.first.add_neighbor(derivatives.last)
	derivatives.last.add_neighbor(derivatives.first)
	source.neighbors.each do |neighbor|
		derivatives.each do |derivative|
			derivative.add_neighbor(neighbor)
		end
	end
end

=begin
populates new_areas with all points currently in old_area 
=end
def transfer_points(old_area, new_areas)
	unless old_area.kind_of?(Area) and new_areas.kind_of?(Array)
		raise "wrong arguments: old=#{old_area} new=#{new_areas}"
	end
	old_area.points.each do |point|
		new_areas.each do |area|
			area.add_point(point)
		end
	end
end

=begin
returns the left and right area that are the result of splitting the given area vertically..
=end
def split_vertical(areas, area)
	top = area.top
	bottom = area.bottom
	left = area.left
	right = area.right
	middle = (area.right - area.left) / 2.0
	new_left_area = Area.new(Point.new(left, top), Point.new(middle, bottom))
	new_right_area = Area.new(Point.new(middle, top), Point.new(right, bottom))
	[new_left_area, new_right_area]
end

=begin
returns the left and right area that are the result of splitting the given area horizontally.
=end
def split_horizontal(areas, area)
	top = area.top
	bottom = area.bottom
	left = area.left
	right = area.right
	middle = (top - bottom)/ 2.0
	new_bottom_area = Area.new(Point.new(left, middle), Point.new(right, bottom))
	new_top_area = Area.new(Point.new(left, top), Point.new(right, middle))
	[new_bottom_area, new_top_area]
end

def pp_areas(areas)
  areas.each do|area| 
    puts area.pp 
  end
end

def create_areas(points)
  # so we need to find a grid pattern that makes sure that an Area and all its neighbor
  # don't include more than 6 points (maybe 5 is a better upper bound)
  # trial and error
  brute_force_upper_bound = 6
  everywhere = Area.new(Point.new(0,1), Point.new(1,0))
  areas = [everywhere]
  points.each do |point|
    everywhere.add_point(point)
  end
  areas_to_split = areas.select{|area| area.number_of_points_near > brute_force_upper_bound}

  while areas_to_split.count != 0
    # split the area with the most points 
    to_split = areas_to_split.sort_by{|area| area.points.count}.last
    split_area(areas, to_split)
    # needed to know if we should keep splitting
    number_of_points_near = {}
    areas.each do |area|
      number_of_points_near[area] = area.number_of_points_near
    end
    
    areas_to_split = []
    number_of_points_near.each do |area, point_count|
      if point_count > brute_force_upper_bound
        areas_to_split << area
      end
    end
  end
  areas
end

def plot(areas)
  File.open("debug.svg", "w") do |file|
    file << areas.to_svg
  end
end

class Array
  def to_svg(zoom=100)
    html = "<svg xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\" viewBox=\"#{-(zoom)} #{-(zoom)} #{zoom*2} #{zoom*2}\" >"
    html += "<style> rect, polygon, path { fill:none;stroke:black; stroke-width:1px}</style>"

    self.each do |element|
      html += element.to_svg
    end
    html += '</svg>'
  end
end

if __FILE__ == $0
  points = generate_points
  puts "Points generated"
  puts "The shortest found distance is:\n#{find_shortest_distance(points)}"
end
