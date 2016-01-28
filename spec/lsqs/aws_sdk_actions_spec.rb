require 'spec_helper'
require 'aws-sdk'

describe 'Testing actions against the aws-sdk' do
  before do
    base_url = 'www.example.com'
    port     = 8080
    @url     = "http://#{base_url}:#{port}"
    Aws.config.update(:endpoint => @url)
    @client = Aws::SQS::Client.new
  end

  after do
    list = @client.list_queues
    list.queue_urls.each do |queue|
      @client.delete_queue(:queue_url => queue)
    end
  end

  describe '#create_queue'
  it 'creates a queue if it does not exist' do
    response = @client.create_queue(:queue_name => 'foo_queue')

    response.queue_url.should == "#{@url}/foo_queue"

    response.data.kind_of?(Aws::SQS::Types::CreateQueueResult).should be_truthy
  end

  it 'throws an error if queue exists' do
    @client.create_queue(:queue_name => 'bar_queue')

    expect{
      @client.create_queue(:queue_name => 'bar_queue')
    }.to raise_error(Aws::SQS::Errors::Error400, 'QueueNameExists')
  end

  describe '#delete_queue' do
    it 'deletes a queue if it exists' do
      queue = @client.create_queue(:queue_name => 'bar')

      response = @client.delete_queue(:queue_url => queue.queue_url)

      response.data.kind_of?(Aws::EmptyStructure).should be_truthy
    end

    it 'throws an error if queue does not exist' do

      expect{
        @client.delete_queue(:queue_url => "#{@url}/no_queue")
      }.to raise_error(Aws::SQS::Errors::Error400, 'NonExistentQueue')
    end
  end

  describe '#purge_queue' do
    it 'purges a queue if it exists' do
      queue = @client.create_queue(:queue_name => 'another_queue')

      response = @client.purge_queue(:queue_url => queue.queue_url)

      response.data.kind_of?(Aws::EmptyStructure).should be_truthy
    end

    it 'throws an error if queue does not exist' do
      expect{
        @client.delete_queue(:queue_url => "#{@url}/not_there")
      }.to raise_error(Aws::SQS::Errors::Error400, 'NonExistentQueue')
    end
  end

  describe '#get_queue_url' do
    it 'purges a queue if it exists' do
      queue = @client.create_queue(:queue_name => 'this_queue')

      response = @client.get_queue_url(:queue_name => 'this_queue')
      response.data.kind_of?(Aws::SQS::Types::GetQueueUrlResult).should be_truthy
    end

    it 'throws an error if queue does not exist' do
      expect{
        @client.get_queue_url(:queue_name => 'foo_bar')
      }.to raise_error(Aws::SQS::Errors::Error400, 'NonExistentQueue')
    end
  end

  describe '#list_queues' do
    it 'returns an empty array if there are no queues' do
      list = @client.list_queues

      list.queue_urls.empty?.should be_truthy
    end

    it 'returns an array with the queue urls' do
      queue = @client.create_queue(:queue_name => 'great_queue')
      list = @client.list_queues

      list.queue_urls.size.should eql(1)
      list.queue_urls.first.should == queue.queue_url
    end

    it 'searches for a url based on a prefix' do
      @client.create_queue(:queue_name => 'bad_queue')
      nice = @client.create_queue(:queue_name => 'nice_queue')
      list = @client.list_queues(:queue_name_prefix => 'nice')

      list.queue_urls.size.should eql(1)
      list.queue_urls.first.should == nice.queue_url
    end
  end

  describe '#send_message' do
    it 'throws an error if queue does not exist' do
      entry     = {:foo => 'bar'}
      queue_url = "#{@url}/test"
      expect{
        @client.send_message(
          :queue_url => queue_url,
          :message_body => entry.to_json
        )
      }.to raise_error(Aws::SQS::Errors::Error400, 'NonExistentQueue')
    end

    it 'returns message on success' do
      entry     = {:foo => 'bar'}
      queue = @client.create_queue(:queue_name => 'test')
      queue_url = queue.queue_url
      response = @client.send_message(
        :queue_url => queue_url,
        :message_body => entry.to_json
      )

      response.message_id.kind_of?(String).should be_truthy
      response.md5_of_message_body.kind_of?(String).should be_truthy
      response.data.kind_of?(Aws::SQS::Types::SendMessageResult).should be_truthy
    end
  end

  describe '#send_message_batch' do
    before do
      @entries = [
        {
          :message_body => 'foo and bar',
          :id => 'foo_bar'
        },
        {
          :message_body => 'hey hello',
          :id  => 'hey_hello'
        }
      ]
    end

    it 'throws an error if queue does not exist' do
      queue_url = "#{@url}/test"
      expect{
        @client.send_message_batch(
          :queue_url => queue_url,
          :entries => @entries
        )
      }.to raise_error(Aws::SQS::Errors::Error400, 'NonExistentQueue')
    end

    it 'returns messages on success' do
      queue = @client.create_queue(:queue_name => 'test')
      queue_url = queue.queue_url
      response = @client.send_message_batch(
        :queue_url => queue_url,
        :entries => @entries
      )

      response.successful.size.should == 2
      response.data.kind_of?(Aws::SQS::Types::SendMessageBatchResult).should be_truthy
    end
  end

  describe '#receive_message' do
    before do
      @entries = [
        {
          :message_body => 'foo and bar',
          :id => 'foo_bar'
        },
        {
          :message_body => 'hey hello',
          :id  => 'hey_hello'
        }
      ]
    end

    it 'throws an error if queue does not exist' do
      queue_url = "#{@url}/test"
      expect{
        @client.receive_message(:queue_url => queue_url)
      }.to raise_error(Aws::SQS::Errors::Error400, 'NonExistentQueue')
    end

    it 'receives an empty response if there are no messages' do
      queue = @client.create_queue(:queue_name => 'receive_test')
      queue_url = queue.queue_url
      response = @client.receive_message(:queue_url => queue_url)

      response.messages.size.should == 0
    end

    it 'receives a message if there are messages in the queue' do
      queue = @client.create_queue(:queue_name => 'receive_test')
      queue_url = queue.queue_url
      @client.send_message_batch(:queue_url => queue_url, :entries => @entries)
      response = @client.receive_message(:queue_url => queue_url)

      response.messages.size.should == 1
      response.data.class.kind_of?(Aws::SQS::Types::ReceiveMessageResult)
    end

    it 'receives more message if maximum number of messages is set' do
      queue = @client.create_queue(:queue_name => 'receive_test')
      queue_url = queue.queue_url
      @client.send_message_batch(:queue_url => queue_url, :entries => @entries)

      response = @client.receive_message(:queue_url => queue_url, :max_number_of_messages => 5)

      response.messages.size.should == 2
      response.data.class.kind_of?(Aws::SQS::Types::ReceiveMessageResult)
    end
  end

  describe '#delete_message' do
    it 'throws an error if queue does not exist' do
      queue_url = "#{@url}/test"
      expect{
        @client.delete_message(:queue_url => queue_url, :receipt_handle => 'test')
      }.to raise_error(Aws::SQS::Errors::Error400, 'NonExistentQueue')
    end

    it 'throws message not in flight error after deleting successfully' do
      queue = @client.create_queue(:queue_name => 'delete_test')
      entry     = {:foo => 'bar'}
      queue_url = queue.queue_url
      @client.send_message(:queue_url => queue_url, :message_body => entry.to_json)

      response = @client.receive_message(:queue_url => queue_url)

      @client.delete_message(:queue_url => queue_url, :receipt_handle => response.messages.first.receipt_handle)

      expect{
        @client.change_message_visibility(
          :queue_url => queue_url,
          :receipt_handle => response.messages.first.receipt_handle,
          :visibility_timeout => 0
        )
      }.to raise_error(Aws::SQS::Errors::Error400, 'MessageNotInflight')
    end
  end

  describe '#delete_message_batch' do
    it 'throws an error if queue does not exist' do
      entries = [
              {
                :receipt_handle => 'foo',
                :id             => 'test1'
              },
              {
                :receipt_handle => 'bar',
                :id             => 'test2'
              }
            ]
      queue_url = "#{@url}/test"
      expect{
        @client.delete_message_batch(:queue_url => queue_url, :entries => entries)
      }.to raise_error(Aws::SQS::Errors::Error400, 'NonExistentQueue')
    end

    it 'throws message not in flight error after deleting successfully' do
      queue = @client.create_queue(:queue_name => 'delete_batch_test')
      entry1    = {:foo => 'bar'}
      entry2    = {:hey => 'hello'}
      queue_url = queue.queue_url

      @client.send_message(:queue_url => queue_url, :message_body => entry1.to_json)
      @client.send_message(:queue_url => queue_url, :message_body => entry2.to_json)

      response = @client.receive_message(:queue_url => queue_url, :max_number_of_messages => 2)

      entries = response.messages.map do |m|
        {:receipt_handle => m.receipt_handle, :id => m.message_id}
      end

      @client.delete_message_batch(:queue_url => queue_url, :entries => entries)

      expect{
        @client.change_message_visibility(
          :queue_url => queue_url,
          :receipt_handle => response.messages.first.receipt_handle,
          :visibility_timeout => 0
        )
      }.to raise_error(Aws::SQS::Errors::Error400, 'MessageNotInflight')

      expect{
        @client.change_message_visibility(
          :queue_url => queue_url,
          :receipt_handle => response.messages.last.receipt_handle,
          :visibility_timeout => 0
        )
      }.to raise_error(Aws::SQS::Errors::Error400, 'MessageNotInflight')
    end
  end

  describe '#change_message_visibility' do
    it 'throws an error if queue does not exist' do
      queue_url = "#{@url}/test"
      expect{
        @client.change_message_visibility(
          :queue_url => queue_url,
          :receipt_handle => 'test',
          :visibility_timeout => 0
        )
      }.to raise_error(Aws::SQS::Errors::Error400, 'NonExistentQueue')
    end

    it 'puts a message back in the queue when visibility is 0' do
      queue = @client.create_queue(:queue_name => 'visibility_test')
      entry     = {:foo => 'bar'}
      queue_url = queue.queue_url
      @client.send_message(:queue_url => queue_url, :message_body => entry.to_json)

      response1 = @client.receive_message(:queue_url => queue_url)

      response1.messages.size.should == 1

      response2 = @client.receive_message(:queue_url => queue_url)

      response2.messages.size.should == 0

      @client.change_message_visibility(
        :queue_url => queue_url,
        :receipt_handle => response1.messages.first.receipt_handle,
        :visibility_timeout => 0
      )

      response3 = @client.receive_message(:queue_url => queue_url)

      response1.messages.size.should == 1

      response1.messages.first.message_id.should == response3.messages.first.message_id
      response1.messages.first.md5_of_body.should == response3.messages.first.md5_of_body
    end
  end
end