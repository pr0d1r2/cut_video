#!/usr/bin/env ruby

class VideoCut
  attr_reader :file, :cut_points, :previous_start, :cut

  def initialize(file, cut_points)
    @file = file
    @cut_points = cut_points
    @previous_start = "00:00:00"
  end

  def self.make(file, cut_points)
    new(file, cut_points).make
  end

  def make
    cut_points.each do |cut_point|
      @cut = cut_point
      system(cmd)
      @previous_start = cut_point
    end
    system(last_cmd)
  end

  private

  def suffix
    file.split('.').last
  end

  def file_without_suffix
    file.split('.')[0..-2].join('.')
  end

  def output
    "#{file_without_suffix}-#{previous_start.gsub(':', '-')}--#{cut.gsub(':', '-')}.#{suffix}"
  end

  def cmd
    "ffmpeg -i '#{file}' -ss #{previous_start} -to #{cut} -acodec copy -vcodec copy '#{output}'"
  end

  def last_output
    "#{file_without_suffix}-#{previous_start.gsub(':', '-')}.#{suffix}"
  end

  def last_cmd
    "ffmpeg -i '#{file}' -ss #{previous_start} -acodec copy -vcodec copy '#{last_output}'"
  end
end


files = []
cut_points = []

if ARGV.empty?
  puts
  puts "Usage:"
  puts "  #{__FILE__} videofile   cut_point[s]"
  puts "  #{__FILE__} example.mp4 00:01:00 00:03:00"
  puts
  exit 1
end

ARGV.each do |arg|
  if File.exist?(arg)
    files << arg
  else
    cut_points << arg
  end
end

unique_cut_points = cut_points.sort.uniq

files.each do |file|
  VideoCut.make(file, unique_cut_points)
end
