require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'Nori::Resource' do
  describe '.action' do
    before(:each) do
      Nori::Resource.action :find, :url => 'http://example.com'
      @actions = Nori::Resource.instance_variable_get(:@actions)
    end

    it 'should add a new item to the actions' do
      @actions.should_not be_empty
    end

    it 'should set the new action name as a key' do
      @actions.keys.should == [:find]
    end

    it 'should add any other arguments as the actions attributes' do
      @actions[:find].should == {:url => 'http://example.com'}
    end
  end
end

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
      HTTParty.should_receive(:get).with('http://google.com/search', :query => {:q => 'Chunky Bacon!'})
      Nori::Request.perform('http://google.com/search', :q => 'Chunky Bacon!')
    end
  end
end
