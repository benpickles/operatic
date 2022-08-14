# Operatic

[![GitHub Actions status](https://github.com/benpickles/operatic/workflows/Ruby/badge.svg)](https://github.com/benpickles/operatic)

A minimal standard interface for your operations.

## Installation

Add Operatic to your application's Gemfile and run `bundle install`.

```ruby
gem 'operatic'
```

## Usage

An Operatic class encapsulates an operation and communicates the status of the operation via its result object. As well as being either a `#success?` or a `#failure?` further data can be attached via `#success!`, `#failure!` or convenience accessors.

```ruby
class SayHello
  include Operatic

  # Readers for attributes passed via `.call`.
  attr_reader :name

  # Declare convenience accessors on the result.
  result_attr :message

  def call
    # Exit the method and mark the result as a failure.
    return failure! unless name

    # Mark the result as a success and attach further data.
    success!(message: "Hello #{name}")
  end
end

result = SayHello.call(name: 'Dave')
result.success?  # => true
result.message   # => "Hello Dave"
result[:message] # => "Hello Dave"
result.to_h      # => {:message=>"Hello Dave"}

result = SayHello.call
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

Everyone interacting in the Operatic project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/benpickles/operatic/blob/master/CODE_OF_CONDUCT.md).
