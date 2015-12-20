# README

This is a Sinatra server (using Puma) that mimics basic functionality of the 
Amazon SQS Service (for development purposes).

The messages are stored in hashes therefore they are not persisted. When you 
shut down the server, the messages are lost.

There is no authentication mechanism in place (yet), so no access key id and
secret key are needed.

At the moment these types of transactions are implemented:
`CreateQueue`
`DeleteMessageBatch`
`GetQueueUrl`
`ReceiveMessage`
`SendMessage`

## Requirements

* Ruby 2.2 or newer

## Installation

Just install the gem:

    gem install lsqs

## Usage

Run `lsqs-server` in the console.

In your application set the AWS configuration like this (change `base_url` and
`port` number if you are not using the default ones):

```

	require 'aws-sdk' # version 2
	
	# it requires a dot in the URI when polling (to retrieve the region)
	# so 'localhost' won't work.
	base_url = '127.0.0.1' 
	port 		 = 9292
	
	Aws.config.update(:endpoint => "http://#{base_url}:#{port}")
```