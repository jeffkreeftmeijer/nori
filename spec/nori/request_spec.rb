require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'Nori::Request' do
  describe '.perform' do
    it 'should do a GET request to the specified url' do
      HTTParty.should_receive(:get).with('http://google.com', :query => {})
      Nori::Request.perform('http://google.com')
    end

    it 'should do a post request to the specified url' do
      HTTParty.should_receive(:post).with('http://google.com', :query => {})
      Nori::Request.perform('http://google.com', {}, :post)
    end

    it 'should pass the supplied arguments in the request' do
      HTTParty.should_receive(:get).with(
        'http://google.com/search',
        :query => {:q => 'Chunky Bacon!'}
      )
      Nori::Request.perform('http://google.com/search', :q => 'Chunky Bacon!')
    end
  end
end
