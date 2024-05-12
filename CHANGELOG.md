# CHANGELOG

## Version 0.7.0 - 2024-05-12

- Data within an operation is now gathered on a separate `#data` object that's passed to a concrete `Operatic::Success`/`Operatic::Failure` result instance on completion. Convenience data accessors can be defined on the `Data` object (via the renamed `Operatic.data_attr`) but remain available on the result using the magic of `Result#method_missing`. <https://github.com/benpickles/operatic/pull/18>
- Require Ruby version 2.7+.
- Support pattern matching solely against a Result's data. <https://github.com/benpickles/operatic/pull/20>

## Version 0.6.0 - 2022-08-22

- Support pattern matching a Result (in Ruby 2.7+). <https://github.com/benpickles/operatic/pull/12>

## Version 0.5.0 - 2022-06-23

- Support custom initialize method to aid compatibility with other libraries. <https://github.com/benpickles/operatic/pull/11>
- Rename to `Operatic.result_attr` to be more specific about its functionality. <https://github.com/benpickles/operatic/pull/10>
- Get and set Result data with `#[]` / `#[]=`. <https://github.com/benpickles/operatic/pull/9>

## Version 0.4.0 - 2022-05-25

- Switch to keyword arguments. <https://github.com/benpickles/operatic/pull/8>

## Version 0.3.1 - 2020-01-05

- Less specific Rake dependency. <https://github.com/benpickles/operatic/pull/6>

## Version 0.3.0 - 2019-11-27

- Implement `#to_h` not `#to_hash`. <https://github.com/benpickles/operatic/pull/4>

## Version 0.2.0 - 2019-11-23

First official version hosted on [RubyGems.org](https://rubygems.org/gems/operatic).
