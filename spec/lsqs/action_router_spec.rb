require 'spec_helper'

describe LSQS::ActionRouter do
  before do
    @router = described_class.new(QueueList.new)
  end
  describe '#distribute' do
    it 'throws an error for undefined action' do
      expect{@router.distribute('Foo', {})}.to raise_error(LSQS::ActionRouter::ActionError)
    end
    
    it 'does not throw an error for existing action' do
      expect{@router.distribute('CreateQueue', {})}.not_to raise_error
    end
    
    it 'returns an action object' do
      @result = @router.distribute('CreateQueue', {})
      @result.kind_of?(LSQS::Actions::CreateQueue).should be_truthy
    end
  end
end