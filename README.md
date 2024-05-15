# Operatic

[![GitHub Actions status](https://github.com/benpickles/operatic/workflows/Ruby/badge.svg)](https://github.com/benpickles/operatic)

A minimal standard interface for your operations.

## Installation

Add Operatic to your application's Gemfile and run `bundle install`.

```ruby
gem 'operatic'
```

## Usage

An Operatic class encapsulates an operation and communicates its status via a result object. As well as being a `#success?` or `#failure?` data can also be attached to the result via `#success!`, `#failure!`, or during the operation's execution.

```ruby
class SayHello
  include Operatic

  # Readers for instance variables defined in `.call`.
  attr_reader :name

  # Declare convenience data accessors.
  data_attr :message

  def call
    # Exit the method and mark the operation as a failure.
    return failure! unless name

    # Mark the operation as a success and attach further data.
    success!(message: "Hello #{name}")
  end
end

result = SayHello.call(name: 'Dave')
result.class     # => Operatic::Success
result.failure?  # => false
result.success?  # => true
result.message   # => "Hello Dave"
result[:message] # => "Hello Dave"
result.to_h      # => {:message=>"Hello Dave"}

result = SayHello.call
result.class     # => Operatic::Failure
result.failure?  # => true
result.success?  # => false
result.message   # => nil
result[:message] # => nil
result.to_h      # => {}
```

A Rails controller might use Operatic like this:

```ruby
class HellosController < ApplicationController
  def create
    result = SayHello.call(name: params[:name])

    if result.success?
      render plain: result.message
    else
      render :new
    end
  end
end
```

## Pattern matching

An Operatic result also supports pattern matching allowing you to match over a tuple of the result class and its data:

```ruby
case SayHello.call(name: 'Dave')
in [Operatic::Success, { message: }]
  # Result is a success, do something with the `message` variable.
in [Operatic::Failure, _]
  # Result is a failure, do something else.
end
```

Or match solely against its data:

```ruby
case SayHello.call(name: 'Dave')
in message:
  # Result has the `message` key, do something with the variable.
else
  # Do something else.
end
```

Which might be consumed in Rails like this:

```ruby
class HellosController < ApplicationController
  def create
    case SayHello.call(name: params[:name])
    in [Operatic::Success, { message: }]
      render plain: message
    in [Operatic::Failure, _]
      render :new
    end
  end
end
```

## Development

Run the tests with:

```
bundle exec rspec
```

Generate Yard documentation with:

```
bundle exec yardoc
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Operatic project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/benpickles/operatic/blob/main/CODE_OF_CONDUCT.md).
