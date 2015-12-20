require 'sinatra'
require 'puma/cli'
require 'liquid'
require 'securerandom'
require 'active_support/core_ext/string'
require 'json'
require 'builder'

require_relative 'lsqs/version'
require_relative 'lsqs/server'
require_relative 'lsqs/xml_template'
require_relative 'lsqs/action_router'
require_relative 'lsqs/queue_list'

require_relative 'lsqs/actions/base'
require_relative 'lsqs/actions/get_queue_url'

module LSQS
  def self.template
    XMLTemplate.new
  end
  
  def self.router
    ActionRouter.new(queue_list)
  end
  
  def self.queue_list
    QueueList.new
  end
end # LSQS

