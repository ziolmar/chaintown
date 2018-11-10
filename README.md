# Chaintown

This gem provides very simple implementation of pipeline or chain of commands design pattern. If you ever had service class which had to handle complex process and you would like to make the process more explicit and easier to maintain this gem can help you with it.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'chaintown'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install chaintown

## Usage

To use the gem first we need to include `Chaintown::Chain` module inside our service.

```ruby
class AnyService
  include Chaintown::Chain
end

```

The module define constructor which require two arguments. State and params. State is a class which should inherit from `Chaintown::State` and is used to share data between steps in the process. Params is a any object which provide initialization parameters. Param are frozen to be immutable. This prevents from changing it and force to use state object to share data.

```ruby
AnyService.new(Chaintown::State.new, params1: 'value')
```

The Chain module also provide DSL for defining steps. Every step is a method inside the class. Inside every method you have access to state and params.

```ruby
  step :step1
  step :step2

  def step1
    puts 'Step 1'
  end

  def step2
    puts 'Step 2'
  end
```

You can simply nest the steps by using `yield` inside your step.

```ruby
  step :step1 do
    step :step2
    step :step3
  end

  def step1
    if state.run_nested_process? # method defined in your own class
      yield
    end
  end
```

There is also a way to run step based on some condition by using `if` argument.

```ruby
  step :step1, if: proc { |state, params| params[:run_step_1] }
```

If in any step you set the state `valid` param to false the process will be terminated and no other steps will be called instead the process will be moved to alternative flow defined by failed steps.

```ruby
  step :step1
  step :step2
  failed_step :step3

  def step1
    state.valid = false
  end

  def step2
    puts 'will not be called'
  end

  def step3
    puts 'handle invalid state'
  end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ziolmar/chaintown. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Chaintown project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ziolmar/chaintown/blob/master/CODE_OF_CONDUCT.md).
