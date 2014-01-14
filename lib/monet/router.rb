module Monet
  class Router
    include URLHelpers
    TYPES = [
      :baseline,
      :capture,
      :thumbnail
    ]

    def initialize(config)
      @config = config
    end

    TYPES.each do |type|
      define_method "#{type}_dir" do |filename=""|
        clean File.join(@config.send("#{type}_dir"), @config.site, filename)
      end

      define_method "#{type}_url" do |filename|
        type_dir = @config.send "#{type}_dir"
        image_url(type_dir, filename)
      end
    end

    def original_url(path)
      url = path.split("/").last
      path = url.split('|')[1..-1].join("/").gsub(/-\d+\.png/, "")

      clean "#{@config.base_url}/#{path}"
    end

    def diff_dir(filename="")
      filename = filename.gsub(".png", "-diff.png") unless filename.empty?
      clean File.join(@config.baseline_dir, @config.site, filename)
    end

    def diff_url(path)
      diff = basename diff_dir(path)
      image_url(@config.baseline_dir, diff)
    end

    def capture_routes
      urls = {}
      @config.map.paths.each do |path|
        url = clean "#{@config.base_url}#{path}"
        @config.dimensions.each do |width|
          urls[url] ||= []
          urls[url] << url_to_filepath(url, width)
        end
      end

      urls
    end

    def url_to_filepath(url, width="*")
      uri = parse_uri(url)
      name = File.join @config.site, "#{@config.site}#{uri.path.gsub(/\//, '|')}"
      File.join @config.capture_dir, "#{name}-#{width}.png"
    end

    private
    def basename(path)
      File.basename path
    end

    def image_url(type_dir, name)
      relative_path = Pathname.new(type_dir).relative_path_from(Pathname.new(File.join(type_dir, "..")))
      "/#{relative_path}/#{@config.root_dir}/#{name}"
    end
  end
end