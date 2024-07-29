# Kudu

RVM based ruby build tool with transitive dependency management

## Installation
```
gem install bundler
# installs 3rd party gems in vendor/cache and local gem path
bundler cache
# run kudu using the bundle
bundle exec kudu
```

## Usage

```
bundler exec kudu
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

This will leave the built gem in `pkg/kudu-[version].gem`

