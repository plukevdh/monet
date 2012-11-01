# Monet

Monet is a libary built for making testing interfaces and design easy. We all have interfaces that we've added a new button, changed some CSS, or added new javascript interaction to and had the page layout explode unexpectedly. Monet is meant to make tracking those changes and ensuring consistent automatably easy.

## Installation

Add this line to your application's Gemfile:

    gem 'monet'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install monet

## Usage

The basic gem requires a config file that is somehow called on the app startup. This config primarily exists to give the gem a list of paths it needs to collect and either baseline or compare to previous baselines. This config might look something like this:

    Monet::Config do |config|
	  config.driver = :poltergeist
	  config.dimensions = [1440,900]

	  config.map do |map|
		map.add 'home/index'
		map.add 'home/show'
	  end
    end

## Todo
- Browser/driver config
- Rails integration
- Sinatra/Rack integration
- Web UI

## Contributing

1. Fork it
2. Branch it (`git checkout -b my-new-feature`)
3. Commit it (`git commit -am 'Add some feature'`)
4. Push it (`git push origin my-new-feature`)
5. Pull Request it! 

Willing to consider commit bit priviledges to anyone who expresses extreme interest in the project. 

## Credits

Big shout to __Jeff Kreeftmeijer__ for his blog post on [ChunkyPNG](http://jeffkreeftmeijer.com/2011/comparing-images-and-creating-image-diffs/). The Monet::Compare::CompareStrategy code is basically what he wrote in the post.

## Alternatives

- https://github.com/intridea/green_onion : Mostly the same thing I did here, but I didn't know about it starting out. I like what they did, but I had a different take, so I decided to pursue my version to the end.

