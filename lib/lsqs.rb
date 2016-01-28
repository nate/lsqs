require 'sinatra'
require 'puma/cli'
require 'liquid'
require 'securerandom'
require 'digest/md5'
require 'active_support/core_ext/string'
require 'json'
require 'builder'

require_relative 'lsqs/version'
require_relative 'lsqs/error_handler'
require_relative 'lsqs/server'
require_relative 'lsqs/xml_template'
require_relative 'lsqs/action_router'
require_relative 'lsqs/queue_list'
require_relative 'lsqs/queue'
require_relative 'lsqs/message'

require_relative 'lsqs/actions/base'
require_relative 'lsqs/actions/get_queue_url'
require_relative 'lsqs/actions/receive_message'
require_relative 'lsqs/actions/create_queue'
require_relative 'lsqs/actions/send_message'
require_relative 'lsqs/actions/delete_message_batch'
require_relative 'lsqs/actions/purge_queue'
require_relative 'lsqs/actions/list_queues'
require_relative 'lsqs/actions/delete_queue'
require_relative 'lsqs/actions/delete_message'
require_relative 'lsqs/actions/send_message_batch'
require_relative 'lsqs/actions/change_message_visibility'

module LSQS
  def self.template
    @template ||= XMLTemplate.new
  end

  def self.router
    @router ||= ActionRouter.new(queue_list)
  end

  def self.queue_list
    QueueList.new
  end
end # LSQS

