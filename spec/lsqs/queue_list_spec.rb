require 'spec_helper'

describe LSQS::QueueList do
  before do
    @list = described_class.new
  end
  
  describe '#initialize' do
    it 'initializes properly' do
      
      list = described_class.new

      list.queues.kind_of?(Hash).should be_truthy
      list.queues.size.zero?.should be_truthy
    end
  end
  
  describe '#create' do
    it 'creates a queue' do
      @list.create('foo')
      @list.create('bar')
      
      @list.queues.size.should == 2
      @list.queues['foo'].kind_of?(LSQS::Queue).should be_truthy
    end
    
    it 'throws an error if queue already exists' do
      @list.create('test')
      expect{@list.create('test')}.to raise_error(RuntimeError, 'QueueNameExists')
    end
  end
  
  describe '#inspect' do
    it 'gives the list of queues' do
      @list.create('foo')
      @list.create('bar')
      
      result = @list.inspect
      
      result.size.should == 2
      result.include?('bar').should be_truthy
      result.include?('foo').should be_truthy
      result.kind_of?(Array).should be_truthy
    end
    
    it 'gives the list of queues by prefix' do
      @list.create('foo')
      @list.create('bar')
      
      result = @list.inspect('QueueNamePrefix' => 'foo')
      
      result.size.should == 1
      result.include?('foo').should be_truthy
      result.kind_of?(Array).should be_truthy
    end
  end
  
  describe '#find' do
    it 'returns a single queue' do
      @list.create('test')
      
      result = @list.find('test')
      
      result.kind_of?(LSQS::Queue).should be_truthy
      result.name.should == 'test'
    end
    
    it 'throws an error if queue does not exist' do
      expect{@list.find('foo')}.to raise_error(RuntimeError, 'NonExistentQueue')
    end
  end
  
  describe '#delete' do
    it 'deletes a queue' do
      @list.create('test')
      
      @list.queues.size.should == 1
      
      @list.delete('test')
      @list.queues.size.zero?.should be_truthy
    end
    
    it 'throws an error if queue does not exist' do
      expect{@list.delete('foo')}.to raise_error(RuntimeError, 'NonExistentQueue')
    end
  end
  
  describe '#purge' do
    it 'empties the queue list' do
      @list.create('test')
      
      @list.queues.size.should == 1
      
      @list.purge
      
      @list.queues.size.zero?.should be_truthy
    end
  end
end