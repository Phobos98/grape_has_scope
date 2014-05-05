# grape_has_scope

This is a Plataformatec's gem [has_scope](https://github.com/plataformatec/has_scope) implementation to use with [Grape API](https://github.com/intridea/grape)

## Installation

Add the `grape` and `grape_has_scope` gems to Gemfile.

```ruby
gem 'grape'
gem 'grape_has_scope'
```

And then execute:

    bundle

## Usage

The usage is similar to the original implementation, so you can read the detailed instructions on the original has_scope page

The only difference is that you should define used scopes in the `before` block of your `Grape::API`, like this

```ruby
class Posts < Grape::API

  before do
    has_scope :by_author
    has_scope :page
    has_scope :per_page
  end

  resource :posts do

    desc 'Returns the list of posts'
    params do
      optional :by_author, type: Integer, desc: "Filter by: Author ID"
      optional :page, type: Integer, default: 1, desc: "Page number (default: 1)"
      optional :per_page, type: Integer, default: 30, desc: "Number of elements per page (default: 30)"
    end
    get '' do
      apply_scopes(Post)
    end
  end
end
```

## Tests

The tests were just copied from the original gem, so they will not work, and I did not yet have time to update them :) So feel free to implement them and contribute, if you wish