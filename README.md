# Monet [![Build Status](https://travis-ci.org/plukevdh/monet.png?branch=master)](https://travis-ci.org/plukevdh/monet) [![Code Climate](https://codeclimate.com/github/plukevdh/monet.png)](https://codeclimate.com/github/plukevdh/monet)

Monet is a libary built for making testing interfaces and design easy. We all have interfaces that we've added a new button, changed some CSS, or added new javascript interaction to and had the page layout explode unexpectedly. Monet is meant to make tracking those changes and ensuring consistent automatably easy.

## Installation

Add this line to your application's Gemfile:

    gem 'monet'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install monet

## Usage

The basic gem requires a config file that is called in an app initializer or via the built-in rake task. This config primarily exists to give the gem a list of paths it needs to collect and either baseline or compare to previous baselines. This config might look something like this:

```ruby
config = Monet.config do |config|
  config.driver = :poltergeist
  config.dimensions = [1440,900]

  config.map do |map|
    map.add 'home/index'
    map.add 'home/show'
  end

  # alternatively...

  config.map :spider
end
```

You can also use a yaml file and load it later

```yaml
:driver: :poltergeist
:dimensions:
  - 1024

:base_url: "http://lance.com"

:compare_type: Highlight
:map:
  - "/"
  - "/aboutus"
  - "/littleleague"
```

You can then use the config to run the capture and comparison toolset:

```ruby
Monet.capture(config)
Monet.compare(config)
```

There are also rake tasks for this

```
rake run ./config.yaml
```

## Process

Captures are saved into the following structure by default:

```
/baselines
/captures
```

- /captures is where the current capture run images are stored, pre-comparison with baseline.
- /baselines is where all current baseline images are stored. persistent in-between capture runs.

You can set these params using the `baseline_dir` and `captures_dir` options.

During the capture process, any new captures that do not have a match found in baselines to compare with are considered new baselines.
Any images that match baseline are discarded.
Any images that flag differences, are flagged for review.

Review involves checking flagged images and marking as

1. discard
2. flag as issue
3. accept as new baseline

## Todo
- Parallelize PNG diffing
- Dashboard
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
- https://github.com/BBC-News/wraith : Similar idea again, but more limited in features, also doesn't allow for baselining, more of a multi-site/URL compare.
