require 'spec_helper'

describe LSQS::XMLTemplate do
  before do
    @xml_template = described_class.new
  end

  describe '#initialize' do
    it 'initializes with a liquid template' do
      @xml_template.template.kind_of?(Liquid::Template).should be_truthy
    end
  end

  describe '#render' do
    before do
      @action = OpenStruct.new(:name => 'Foo', :to_xml => '<Bar>Foo Bar</Bar>')
      @result = @xml_template.render(@action)
    end

    it 'renders XML and returns a string' do
      @result.kind_of?(String).should be_truthy
    end

    it 'includes opening closing xml tags' do
      @result.include?('<xml').should be_truthy
      @result.include?('</xml>').should be_truthy
    end

    it 'includes the result name properly' do
      @result.include?("<#{@action.name}Result>").should be_truthy
      @result.include?("</#{@action.name}Result>").should be_truthy
    end

    it 'includes the content' do
      @result.include?(@action.to_xml).should be_truthy
    end
  end

  describe '#render_error' do
    before do
      @error  = '<error>Foo did not work that well.</error>'
      @result = @xml_template.render_error(@error)
    end

    it 'renders XML and returns a string' do
      @result.kind_of?(String).should be_truthy
    end

    it 'includes opening closing xml tags' do
      @result.include?('<xml').should be_truthy
      @result.include?('</xml>').should be_truthy
    end

    it 'includes the error' do
      @result.include?(@error).should be_truthy
    end
  end

  describe '#request_id' do
    it 'returns a string' do
      @xml_template.request_id.kind_of?(String).should be_truthy
    end
  end
end