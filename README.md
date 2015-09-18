# Greedo

A very simple helper for generating data tables.

## Installation

Add this line to your application's Gemfile:

    gem 'greedo'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install greedo

## Usage

After installing greedo, you can use the helper like this:

```haml
%h1 My first table

= greedo(User.registered, per_page: 10) do |g|
  = g.column :name
  = g.column "Actions" do |user|
    = link_to "Edit", edit_user_path(user)
```

This will create a data table with two columns, one labelled "Name" and the other "Actions".
It will show 10 users from the given scope (which should either be an ActiveRecord::Relation or an Array). 
Pagination will be added if necessary.

## Limitations

This is a very simple helper for now - there's no sorting, or even any way to easily customize the generated HTML. This will change in time, but for now I'm open-sourcing this mainly to share this useful bit of code between projects.

## TODO:

Here's a couple of things I'm planning to add to this gem:

* sorting by clicking on a column name
* a generator to install the templates used by greedo in your project for ease of customization
* making the paginator library swappable (greedo uses will_paginate now).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/greedo/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
