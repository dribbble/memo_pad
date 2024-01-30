# MemoPad

Explicit, block-level memoization for your Ruby projects, for when `@foo ||= bar` isn't good enough.

## Why MemoPad?

When might you reach for MemoPad? When your memoized result could be falsey (since they'd always evaluate on the `||=`) or if you need to memoize a different result based on method arguments or other values.

MemoPad differs from other popular gems (like [memoist](https://rubygems.org/gems/memoist) or [memery](https://rubygems.org/gems/memery)) primarily in how you memoize your result. Those tools abstract the memoization at a method level, by way of a `memoize` class method, adding new methods to your objects (like the unmemoized method definitions), and getting in the way of tools like `show-source`.

MemoPad avoids those frictions by trading the convenience of `memoize :foo` with a more explicit declaration of what to memoize and where. Objects which include this module gain a `#memo_pad` instance method which you can use to mememoize the result of any block to a given name (conventionally the method's name) and an optional set of arguments which should memoize distinct values.

See the Usage section below for an example class taking advantage of MemoPad.


## Installation


Install the gem and add to the application's Gemfile by executing:

    $ bundle add memo_pad

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install memo_pad

## Usage

1. First, `include MemoPad` in your class.
2. Then use `memo_pad.call(name, *args) do; end` to memoize the result of the block.
3. There is no step 3.

```ruby
class Foo
  include MemoPad

  def expensive_method
    memo_pad.call(:expensive_method) do
      # Do some expensive work here
    end
  end

  def expensive_method_with_arguments(foo, bar: nil)
    memo_pad.call(:expensive_method, foo, bar) do
      # Do expensive work here, respecting the values of `foo` and `bar`
    end
  end

  def complex_memoization
    first_part = memo_pad.call(:complex_memoization_first) do
      # Some independent expensive work
    end

    # Maybe some other unmemoized work

    memo_pad.call(:complex_memoization_second, first_part) do
      # Some other expensive work, respecting the value of `first_part`
    end
  end
end
```
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dribbble/memo_pad. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/dribbble/memo_pad/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the MemoPad project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/dribbble/memo_pad/blob/main/CODE_OF_CONDUCT.md).
