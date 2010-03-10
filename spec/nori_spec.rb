require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'Nori::Resource' do
  describe '.initialize' do
    it 'should store the supplied arguments into the attributes variable' do
      item = Nori::Resource.new({:name => 'Nori'})
      item.instance_variable_get(:@attributes)[:name].should == 'Nori'
    end
  end

  describe '.action' do
    before(:all) do
      Nori::Resource.action :index, :url => 'http://example.com'
      @actions = Nori::Resource.instance_variable_get(:@actions)
    end

    it 'should add a new item to the actions' do
      @actions.should_not be_empty
    end

    it 'should set the new action name as a key' do
      @actions.keys.should == [:index]
    end

    it 'should add any other arguments as the actions attributes' do
      @actions[:index].should == {:url => 'http://example.com'}
    end
  end

  describe '.find' do
    it 'should raise an error if there is no :index action' do
      Nori::Resource.instance_variable_set(:@actions, {})
      lambda {
        Nori::Resource.find
      }.should raise_error(Nori::ActionNotSpecified)
    end

    it 'should call .all and pass its arguments' do
      @actions = Nori::Resource.instance_variable_set(
        :@actions,
        {:index => {}}
      )
      Nori::Resource.should_receive(:all).with(:q => 'Chunky Bacon!')
      Nori::Resource.find(:all, :q => 'Chunky Bacon!')
    end
  end

  describe '.all' do
    before(:each) do
      Nori::Request.stub!(:perform).and_return({'resource' => [1,2,3]})
    end

    it 'should call Nori::Request.perform to the :index url' do
      @actions = Nori::Resource.instance_variable_set(
        :@actions,
        {:index => {:url => 'http://google.com/search'}}
      )

      Nori::Request.should_receive(:perform).with(
        'http://google.com/search',
        {},
        :get
      ).and_return('resource' => {})

      Nori::Resource.all
    end

    it 'should call Nori::Request.perform to the :index url and the arguments' do
      Nori::Request.should_receive(:perform).with(
        'http://google.com/search',
        {:q => 'Chunky Bacon!'},
        :get
      ).and_return('resource' => {})

      Nori::Resource.all(:q => 'Chunky Bacon!')
    end

    it 'should call Nori::Request.perform with the :post method' do
      @actions = Nori::Resource.instance_variable_set(
        :@actions,
        {:index => {:url => 'http://google.com/search', :method => :post}}
      )

      Nori::Request.should_receive(:perform).with(
        'http://google.com/search',
        {},
        :post
      ).and_return('resource' => {})
      Nori::Resource.all
    end

    it 'should send every item in the parent_node to #new' do
      [1,2,3].each do |item|
        Nori::Resource.should_receive(:new).with(item)
      end
      Nori::Resource.all
    end

    it 'should return three Resource objects' do
      objects = Nori::Resource.all
      objects.each do |object|
        object.should be_instance_of Nori::Resource
      end
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
      HTTParty.should_receive(:get).with(
        'http://google.com/search',
        :query => {:q => 'Chunky Bacon!'}
      )
      Nori::Request.perform('http://google.com/search', :q => 'Chunky Bacon!')
    end
  end
end
