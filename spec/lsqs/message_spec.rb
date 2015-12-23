require 'spec_helper'

describe LSQS::Message do
  before do
    @attributes = {'MessageBody' => 'test'}
    @message = described_class.new(@attributes)
  end
  describe '#attributes' do
    it 'has same message body' do
      @message.attributes['MessageBody'].should == @attributes['MessageBody']
    end
    
    it 'has correct MD5 message hash' do
      @message.attributes['MD5'].should == Digest::MD5.hexdigest(@attributes['MessageBody'])
    end
    
    it 'has an Id' do
      @message.attributes['Id'].kind_of?(String).should be_truthy
    end
    
    it 'can initialize its id' do
      attributes = {'MessageBody' => 'test', 'Id' => 'foo'}
      message = described_class.new(attributes)
      message.attributes['Id'].should == attributes['Id']
    end
    
    it 'can initialize its md5' do
      attributes = {'MessageBody' => 'test', 'MD5' => 'bar'}
      message = described_class.new(attributes)
      message.attributes['MD5'].should == attributes['MD5']
    end
  end
  
  describe '#expired?' do
    it 'returns true if visibility_timeout is not set' do
      @message.expired?.should be_truthy
    end
    
    it 'returns false if visibility_timeout is set' do
      @message.expire_in(30)
      @message.expired?.should be_falsey
    end
  end
  
  describe '#expire_in' do
    it 'sets the visibility_timeout' do
      time = Time.now
      @message.expire_in(30)
      @message.visibility_timeout.should > time + 30
    end
  end
  
  describe '#expire' do
    it 'resets the visibility_timeout' do
      @message.expire_in(30)
      @message.visibility_timeout.kind_of?(NilClass).should be_falsey
      @message.expire
      @message.visibility_timeout.kind_of?(NilClass).should be_truthy
    end
  end
end