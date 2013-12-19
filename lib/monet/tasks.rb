require 'monet'

def load_config(args)
  args.with_defaults(path: './config.yaml')
  Monet::Config.load args[:path]
end

def images_from_dir(dir)
  Dir.glob File.join(dir, "**", "*.png")
end

namespace :monet do
  desc "clean out the baseline directory"
  task :clean, :path do |t, args|
    Monet.clean load_config(args)
  end

  desc "Runs the site and grabs baselines"
  task :baseline => [:clean, :run] do
  end


  namespace :thumbnail do
    desc "Thumbnail all baseline images"
    task :baseline do
      config = load_config(args)
      capture = Monet::Capture.new config

      images_from_dir(config.baseline_dir).each do |image|
        capture.thumbnail image
      end
    end

    desc "Thumnail all captured images"
    task :captures do
      capture = Monet::Capture.new config

      images_from_dir(config.capture_dir).each do |image|
        capture.thumbnail image
      end
    end
  end

  desc "Run the baseline comparison"
  task :run, :path do |t, args|
    config = load_config(args)
    Monet.capture config
    Monet.compare config
  end
end
