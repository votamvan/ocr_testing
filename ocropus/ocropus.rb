#! /usr/bin/env ruby

BIN_DIR = ENV["OCROPUS_DIR"]
model   = ENV["OCROPUS_MODEL"]

target, destination_base, *rest = *ARGV

programs = %w(ocropus-nlbin ocropus-gpageseg ocropus-rpred)
unless File.exist? BIN_DIR and 
       File.directory? BIN_DIR and
       programs.all?{ |p| File.exist? File.join(BIN_DIR, p) }
  raise ArgumentError 
end

raise ArgumentError unless destination_base

def binarize(dir_path, options={})
  destination = options[:destination] ? options[:destination] : "derp"
  cmd = "#{File.join(BIN_DIR, "ocropus-nlbin")} -o #{destination} #{File.join(dir_path, "*.*")}"
  output = `#{cmd}`
  puts output
  return destination
end

def segment(path, options={})
  cmd = "#{File.join(BIN_DIR, "ocropus-gpageseg")} -n --minscale 5 #{path}"
  output = `#{cmd}`
  puts output
end

def recognize_lines(model_path, path, options={})
  model_path = if model_path and File.exist?(model_path)
    model_path
  else
    maybe_model = File.join(BIN_DIR, "models", "en-default.pyrnn.gz")
    if File.exist?(maybe_model)
      maybe_model
    else
      raise ArgumentError, "Unable to find model.  Please set OCROPUS_MODEL on the command line"
    end
  end

  processor_count = 4
  cmd = "#{File.join(BIN_DIR, "ocropus-rpred")} -n -Q #{processor_count / 2} -m #{model_path} #{path}"
  output = `#{cmd}`
  puts output
end

def compile_text(path, options={})
  Dir.glob(path)
end

def recognize(path, options={})
  puts "Binarizing images..."
  #binarize(path, {destination: destination_base})
  puts "Segmenting images..."
  #binarized_image_paths = File.join(destination_base, "*.bin.png")
  #segment(binarized_image_paths)
  puts "Recognizing lines"
  recognize_lines(model, File.join(destination_base, "*", "*.bin.png"))
  puts "Compiling text"
  compile_text(File.join(destination_base, "*", "*.txt"))
end
