require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'Nori::Resource' do
  describe '#initialize' do
    it 'should store the supplied arguments into the attributes variable' do
      item = Nori::Resource.new({:name => 'Nori'})
      item.instance_variable_get(:@attributes)[:name].should == 'Nori'
    end
  end

  describe '#method_missing' do
    before(:all) do
      @item = Nori::Resource.new({'name' => 'Nori'})
    end

    it 'should return the name when calling it as a method' do
      @item.name.should == 'Nori'
    end

    it 'should raise a NoMethodError when the attribute is not available' do
      lambda {
        @item.description
      }.should raise_error(NoMethodError)
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
    describe 'when not providing the :all argument' do
      it 'should call Nori::Request.perform to the :show url' do
        Nori::Resource.instance_variable_set(
          :@actions,
          {:show => {:url => 'http://example.com'}}
        )

        Nori::Request.should_receive(:perform).with(
          'http://example.com',
          {},
          :get
        ).and_return('resource' => {})
        Nori::Resource.find
      end

      it 'should call Nori::Request.perform to the :show url and the arguments' do
        Nori::Resource.instance_variable_set(
          :@actions,
          {:show => {:url => 'http://example.com'}}
        )

        Nori::Request.should_receive(:perform).with(
          'http://example.com',
          {:id => 123},
          :get
        ).and_return('resource' => {})
        Nori::Resource.find(:id => 123)
      end


      it 'should call Nori::Request.perform with the :post http_method' do
        Nori::Resource.instance_variable_set(
          :@actions,
          {:show => {:url => 'http://example.com', :http_method => :post}}
        )

        Nori::Request.should_receive(:perform).with(
          'http://example.com',
          {:id => 123},
          :post
        ).and_return('resource' => {})
        Nori::Resource.find(:id => 123)
      end

      it 'should send the item in the parent_node to #new' do
        Nori::Request.stub!(:perform).and_return({'resource' => 1})
        Nori::Resource.should_receive(:new).with(1)
        Nori::Resource.find(:id => 1)
      end

      it 'should return a Resource object' do
        Nori::Request.stub!(:perform).and_return({'resource' => 1})
        object = Nori::Resource.find(:id => 1)
        object.should be_instance_of Nori::Resource
      end

      it 'should use the :parent_node when provided' do
        Nori::Request.stub!(:perform).and_return({'node' => 1})

        @actions = Nori::Resource.instance_variable_set(
          :@actions,
          {:show => {:url => 'http://example.com', :parent_node => 'node'}}
        )

        Nori::Resource.should_receive(:new).with(1)
        Nori::Resource.find(:id => 1)
      end

      it 'should raise an error when the :parent_node could not be found' do
        response = {'othernode' => 1}
        Nori::Request.stub!(:perform).and_return(response)
        lambda {
          Nori::Resource.find(:id => 1)
        }.should raise_error(Nori::ParentNodeNotFound, "Couldn't find `node` in #{response.to_yaml}")
      end

      it 'should raise an error if there is no :show action' do
        Nori::Resource.instance_variable_set(:@actions, {})
        lambda {
          Nori::Resource.find(:id => 1)
        }.should raise_error(Nori::ActionNotSpecified)
      end
    end

    describe 'when providing the :all argument' do
      before(:each) do
        Nori::Request.stub!(:perform).and_return({'resource' => [1,2,3]})
      end

      it 'should call Nori::Request.perform to the :index url' do
        Nori::Resource.instance_variable_set(
          :@actions,
          {:index => {:url => 'http://example.com'}}
        )

        Nori::Request.should_receive(:perform).with(
          'http://example.com',
          {},
          :get
        ).and_return('resource' => {})
        Nori::Resource.find(:all)
      end

      it 'should call Nori::Request.perform to the :show url and the arguments' do
        Nori::Resource.instance_variable_set(
          :@actions,
          {:index => {:url => 'http://example.com'}}
        )

        Nori::Request.should_receive(:perform).with(
          'http://example.com',
          {:id => 123},
          :get
        ).and_return('resource' => {})
        Nori::Resource.find(:all, :id => 123)
      end


      it 'should call Nori::Request.perform with the :post http_method' do
        Nori::Resource.instance_variable_set(
          :@actions,
          {:index => {:url => 'http://example.com', :http_method => :post}}
        )

        Nori::Request.should_receive(:perform).with(
          'http://example.com',
          {:id => 123},
          :post
        ).and_return('resource' => {})
        Nori::Resource.find(:all, :id => 123)
      end

      it 'should send every item in the parent_node to #new' do
        [1,2,3].each do |item|
          Nori::Resource.should_receive(:new).with(item)
        end
        Nori::Resource.find(:all)
      end

      it 'should return three Resource objects' do
        objects = Nori::Resource.find(:all)
        objects.each do |object|
          object.should be_instance_of Nori::Resource
        end
      end

      it 'should use the :parent_node when provided' do
        Nori::Request.stub!(:perform).and_return({'node' => [1,2,3]})

        @actions = Nori::Resource.instance_variable_set(
          :@actions,
          {:index => {:url => 'http://example.com', :parent_node => 'node'}}
        )

        [1,2,3].each do |item|
          Nori::Resource.should_receive(:new).with(item)
        end

        Nori::Resource.find(:all)
      end

      it 'should raise an error when the :parent_node could not be found' do
        response = {'othernode' => 1}
        Nori::Request.stub!(:perform).and_return(response)
        lambda {
          Nori::Resource.find(:all)
        }.should raise_error(Nori::ParentNodeNotFound, "Couldn't find `node` in #{response.to_yaml}")
      end

      it 'should raise an error if there is no :index action' do
        Nori::Resource.instance_variable_set(:@actions, {})
        lambda {
          Nori::Resource.find(:all)
        }.should raise_error(Nori::ActionNotSpecified)
      end
    end
  end

  describe '.all' do
    it 'should call find with :all and pass its arguments' do
      Nori::Resource.should_receive(:find).with(:all, :name => 'Bob')
      Nori::Resource.all(:name => 'Bob')
    end
  end

  describe '.parent_node' do
    it 'should return the request class name when no parent_node is specified' do
      @actions = Nori::Resource.instance_variable_set(
        :@actions,
        {:index => {:parent_node => nil}}
      )

      Nori::Resource.parent_node(:index).should == 'resource'
    end

    it 'should return the parent_node when specified' do
      @actions = Nori::Resource.instance_variable_set(
        :@actions,
        {:index => {:parent_node => 'node'}}
      )

      Nori::Resource.parent_node(:index).should == 'node'
    end
  end

  describe '.http_method' do
    it 'should return :get as the default' do
      @actions = Nori::Resource.instance_variable_set(
        :@actions,
        {:index => {:http_method => nil}}
      )

      Nori::Resource.http_method(:index).should == :get
    end

    it 'should return the parent_node when specified' do
      @actions = Nori::Resource.instance_variable_set(
        :@actions,
        {:index => {:http_method => :post}}
      )

      Nori::Resource.http_method(:index).should == :post
    end
  end

  describe '.parameter_action' do
    it 'should return the :url for :index' do
      Nori::Resource.instance_variable_set(
        :@actions,
        {:index => {:url => 'http://google.com/search', :parent_node => 'node'}}
      )

      Nori::Resource.parameter_action(:url, :index).should == 'http://google.com/search'
    end

    it 'should return the :parent_node for :show' do
      Nori::Resource.instance_variable_set(
        :@actions,
        {:show => {:url => 'http://google.com/search', :parent_node => 'node'}}
      )

      Nori::Resource.parameter_action(:parent_node, :show).should == 'node'
    end
  end

  describe '.method_missing' do
    it 'should call to .parameter_action and pass the action and the parameter' do
      Nori::Resource.should_receive(:parameter_action).with(:url, :index)
      Nori::Resource.url(:index)
    end

    it 'should call .all with a magic condition' do
      Nori::Resource.should_receive(:all).with(:name => 'nori')
      Nori::Resource.find_all_by_name('nori')
    end

    it 'should call .all with multiple magic conditions' do
      Nori::Resource.should_receive(:all).with(:name => 'nori', :language => 'ruby')
      Nori::Resource.find_all_by_name_and_language('nori', 'ruby')
    end

    it 'should call .all with multiple magic conditions and extra conditions' do
      Nori::Resource.should_receive(:all).with(:name => 'nori', :language => 'ruby', :order => 'desc')
      Nori::Resource.find_all_by_name_and_language('nori', 'ruby', :order => 'desc')
    end
  end
end
