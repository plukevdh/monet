require 'monet'

namespace :monet do
  desc "clean out the baseline directory"
  task :clean, :path do |t, args|
    args.with_defaults(path: './config.yaml')

    config = Monet::Config.load args[:path]
    Monet.clean config
  end

  desc "Runs the site and grabs baselines"
  task :baseline => [:clean, :run] do
  end

  desc "Run the baseline comparison"
  task :run, :path do |t, args|
    args.with_defaults(path: './config.yaml')

    config = Monet::Config.load args[:path]
    Monet.capture config
    Monet.compare config
  end
end
