require 'spec_helper'

describe LSQS::Queue do
  before do
    @queue = described_class.new('test')
  end

  describe '#initialize' do
    it 'has a name' do
      @queue.name.should == 'test'
    end

    it 'has a messages array' do
      @queue.messages.kind_of?(Array).should be_truthy
      @queue.messages.empty?.should be_truthy
    end

    it 'has an in_flight hash' do
      @queue.in_flight.kind_of?(Hash).should be_truthy
      @queue.in_flight.empty?.should be_truthy
    end

    it 'has attributes hash' do
      @queue.attributes.kind_of?(Hash).should be_truthy
    end
  end

  describe '#default_timeout' do
    it 'has default visibility if not set' do
      queue = described_class.new('test')

      queue.visibility_timeout.should == described_class::DEFAULT_TIMEOUT
    end

    it 'has visibility timeout if set' do
      queue = described_class.new('test', {'Attributes' => {'VisibilityTimeout' => 10}})

      queue.visibility_timeout.should == 10
    end
  end

  describe '#create_message' do
    it 'creates a message' do
      @queue.create_message

      @queue.messages.size.should == 1
      @queue.messages.first.kind_of?(Message).should be_truthy
    end
  end

  describe '#get_messages' do
    it 'gets a single message' do
      @queue.create_message('MessageBody' => 'foo')

      result = @queue.get_messages

      result.size.should == 1
      @queue.in_flight.size.should == 1
      result.find{|k,v| v.body == 'foo'}.should be_truthy
    end

    it 'gets a two messages if MaxNumberOfMessages is 2' do
      @queue.create_message('MessageBody' => 'foo')
      @queue.create_message('MessageBody' => 'bar')
      @queue.create_message('MessageBody' => 'foo bar')

      result = @queue.get_messages('MaxNumberOfMessages' => 2)

      result.size.should == 2
      @queue.in_flight.size.should == 2
    end

    it 'gets a two messages if MaxNumberOfMessages is 5 and available are 2' do
      @queue.create_message('MessageBody' => 'foo')
      @queue.create_message('MessageBody' => 'bar')

      result = @queue.get_messages('MaxNumberOfMessages' => 5)

      result.size.should == 2
      @queue.in_flight.size.should == 2
    end

    it 'throws an error if max number is above 10' do
      @queue.create_message('MessageBody' => 'foo')
      @queue.create_message('MessageBody' => 'bar')

      expect{@queue.get_messages('MaxNumberOfMessages' => 11)}.to raise_error(RuntimeError, 'ReadCountOutOfRange')
    end
  end

  describe '#delete_message' do
  end

  describe '#size' do
    it 'calculates size correctly' do
      @queue.create_message('MessageBody' => 'foo')
      @queue.create_message('MessageBody' => 'bar')
      @queue.create_message('MessageBody' => 'test')

      @queue.size.should == 3
    end
  end

  describe '#purge_queue' do
    it 'clears the queue' do
      @queue.create_message('MessageBody' => 'foo')
      @queue.create_message('MessageBody' => 'bar')

      @queue.size.should == 2
      @queue.in_flight.size.should == 0

      @queue.get_messages

      @queue.size.should == 1
      @queue.in_flight.size.should == 1

      @queue.purge

      @queue.size.zero?.should be_truthy
      @queue.in_flight.size.zero?.should be_truthy

    end
  end

  describe '#generate_receipt' do
    it 'generates a string' do
      receipt = @queue.generate_receipt
      receipt.kind_of?(String).should be_truthy
      receipt.length.should == 32
    end
  end

  describe '#change_message_visibility' do
    it 'puts the message back in the queue if seconds is 0' do
      @queue.create_message

      @queue.size.should == 1

      result = @queue.get_messages

      @queue.size.zero?.should be_truthy
      @queue.in_flight.size.should == 1

      @queue.change_message_visibility(result.first.first, 0)

      @queue.size.should == 1
      @queue.in_flight.size.zero?.should be_truthy
    end

    it 'throws an error if the message is not in flight' do
      expect{@queue.change_message_visibility('foo', 0)}.to raise_error(RuntimeError, 'MessageNotInflight')
    end

    it 'keeps the message in flight if seconds is more than 0' do
      @queue.create_message

      @queue.size.should == 1

      result = @queue.get_messages

      @queue.size.zero?.should be_truthy
      @queue.in_flight.size.should == 1

      @queue.change_message_visibility(result.first.first, 10)

      @queue.size.zero?.should be_truthy
      @queue.in_flight.size.should == 1
    end
  end

  describe '#timeout_messages' do
    it 'puts messages back in the queue' do
      queue = described_class.new('test', {'Attributes' => {'VisibilityTimeout' => 1}})

      queue.create_message

      queue.size.should == 1
      queue.in_flight.size.zero?.should be_truthy

      queue.get_messages
      queue.size.zero?.should be_truthy
      queue.in_flight.size.should == 1

      sleep(2)

      queue.timeout_messages

      queue.size.should == 1
      queue.in_flight.size.zero?.should be_truthy
    end
  end
end