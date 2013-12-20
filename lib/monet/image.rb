module Monet
  class Image
    NoDiffFound = Class.new(Exception)

    def initialize(path, config)
      @path = File.expand_path path
      @config = config
    end

    def baseline?
      @path.include? @config.baseline_dir
    end

    def flagged?
      begin
        diff
        true
      rescue NoDiffFound => e
        false
      end
    end

    def baseline
      File.join @config.baseline_dir, basename
    end

    def thumbnail
      File.join @config.thumbnail_dir, basename
    end

    def basename
      @path.split(File::SEPARATOR)[-2..-1].join(File::SEPARATOR)
    end

    def diff
      @diff ||= baseline.gsub(".png", "-diff.png")
      raise NoDiffFound, "No diff exists for #{basename}" unless File.exists?(@diff)
      @diff
    end
  end
end