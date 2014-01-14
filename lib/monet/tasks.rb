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
    config = load_config(args)
    Dir.glob(File.join(config.baseline_dir, "**", "*.png")).each do |img|
      File.delete img
    end
  end

  desc "Captures a spider result list"
  task :spider do |t, args|
    config = load_config(args)
    Monet::CaptureMap.new(config.base_url, :spider).paths

    savedir = File.join File.dirname(args[:path]), "spider.txt"
    Monet::PageLogger.instance.save(savedir)
  end


  desc "Runs the site and grabs baselines"
  task :baseline => [:clean, :run] do
  end

  namespace :thumbnail do
    desc "Thumbnail all baseline images"
    task :baseline, :path do |t, args|
      config = load_config(args)
      capture = Monet::Capture.new config

      images_from_dir(config.baseline_dir).each do |image|
        Monet::Image.new(image).thumbnail! config.thumbnail_dir
      end
    end

    desc "Thumnail all captured images"
    task :captures, :path do |t, args|
      config = load_config(args)
      capture = Monet::Capture.new config

      images_from_dir(config.capture_dir).each do |image|
        capture.thumbnail image
      end
    end
  end

  desc "Run the baseline comparison"
  task :run, :path do |t, args|
    config = load_config(args)
    Monet::Capture.new(config).capture_all
    Monet::BaselineControl.new(config).run
  end
end
