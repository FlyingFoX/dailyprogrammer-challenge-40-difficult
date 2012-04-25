#!/usr/bin/ruby1.9.1 

require 'test/unit'
require './solution.rb'
require 'ruby-debug'

class SolutionTest < Test::Unit::TestCase
  def setup
    @everywhere = Area.new(Point.new(0,1), Point.new(1,0))
  end

  def test_generate_points
    points = generate_points(100)
    points.each do |point|
      assert(@everywhere.contains?(point))
    end
  end
end

class AreaTest < Test::Unit::TestCase
  def setup
    @everywhere = Area.new(Point.new(0,1), Point.new(1,0))
    @left = Point.new(0, 0.5)
    @right = Point.new(1, 0.5)
    @top = Point.new(0.5, 1)
    @bottom = Point.new(0.5, 0)
    @top_left = Point.new(0,1)
    @bottom_left = Point.new(0,0)
    @bottom_right = Point.new(1,0)
    @top_right = Point.new(1, 1)
    @middle = Point.new(0.5, 0.5)
  end

  def test_create_area
    debugger
    points = [@left, @right, @top, @bottom, @top_left, @bottom_left, @top_right, @middle]
    areas = create_areas(points)
    assert_equal(6, areas.count)
    should_be_areas = []
    should_be_areas << Area.new(@top_left, @bottom) 
    should_be_areas << Area.new(@middle, @bottom_right)
    should_be_areas << Area.new(@top, Point.new(0.75, 0.75))
    should_be_areas << Area.new(Point.new(0.5, 0.75), Point.new(0.5+((0.5+0.75)/2), 0.5))
    should_be_areas << Area.new(Point.new(0.5+((0.5+0.75)/2), 0.75), Point.new(0.75, 0.5))
    should_be_areas << Area.new(Point.new(0.75, 1), Point.new(1, 0.5))
    should_be_areas.each do |should|
      assert(areas.include?(should))
    end
  end


  def test_point_equality
    assert_equal(Point.new(0,0), Point.new(0,0))
    mypoint = Point.new(0,0)
    assert_equal(mypoint, mypoint)
    assert_equal(mypoint, Point.new(0,0))
  end

  def test_split_area
    areas = [@everywhere]
    split_area(areas,@everywhere)
    assert_equal(2, areas.count)
    left_area = Area.new(@top_left, @bottom, :vertical)
    right_area = Area.new(@top, @bottom_right, :vertical)
    areas.sort_by!{|area| area.left}
    assert_equal(left_area, areas.first)
    assert_equal(right_area, areas.last)

    left_area = Area.new(@top_left, @bottom, :vertical)
    top_right_area = Area.new(@top, @right, :horizontal)
    bottom_right_area = Area.new(@middle, @bottom_right, :horizontal)
    areas = [left_area, top_right_area, bottom_right_area]
    split_area(areas, top_right_area)
    assert_equal(4, areas.count)
  end

  def test_contains
    area = Area.new(@left, @bottom)
    assert(area.contains?(@bottom_left))
    assert_equal(false, area.contains?(@bottom))
    assert(! area.contains?(@left))
    assert(! area.contains?(@middle))
    assert(area.contains?(Point.new(0, 0.1)))
    assert(area.contains?(Point.new(0.1, 0)))
    area = Area.new(@top_left, @bottom_right)
    [@left, @right, @top, @bottom, @top_left, @bottom_left, @top_right, @middle].each do |point|
      assert(area.contains?(point))
    end
  end
end

