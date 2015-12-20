# README

This is a Sinatra server that mimics basic functionality of the SQS (for development purposes).

The messages are stored in hashes therefore they are not persisted, meaning that
 if you shut down the server, the messages are lost. 

## Requirements

* Ruby 2.2 or newer

## Installation

Assuming you have a local Git copy, first install all the required Gems:

    bundle install

If Bundler is not installed, first install it:

    gem install bundler

Once installed, run the tests to make sure everything is working:

    bundle exec rake

## Usage

Run `lsqs-server` in the console.

In your application set the AWS configuration like this (change `base_url` and
`port` number if you are not using the default ones):

```
require 'aws-sdk' # version 2

base_url = 'localhost' 
port 		 = 9292

Aws.config.update(:endpoint => "http://#{base_url}:#{port}")
```