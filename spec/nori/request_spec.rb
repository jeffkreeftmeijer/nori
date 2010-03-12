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

    it 'should replace the url tag with the param provided' do
      HTTParty.should_receive(:get).with(
        'http://google.com/search', :query => {}
      )

      Nori::Request.perform('http://{name}.com/search', {:name => 'google'})
    end

    it 'should replace multiple url tags with the params provided' do
      HTTParty.should_receive(:get).with(
        'http://google.com/search', :query => {}
      )

      Nori::Request.perform('http://{name}.com/{page}', {:name => 'google', :page => 'search'})
    end
  end
end
