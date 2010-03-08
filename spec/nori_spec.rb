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
