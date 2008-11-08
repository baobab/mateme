require File.dirname(__FILE__) + '/../spec_helper'

describe <%= class_name %> do

  before(:each) do
    login_current_user  
  end

  # it "should create a record" do
  #  options = {
  #   :some_symbol => 'some_value'
  #  }  
  #  running { post :create, options }.should_not change(SomeModel, :count)
  #  running { post :create, options.merge(:some_other_symbol => 'some_other_value') }.should change(SomeModel, :count).by(1)
  # end

<% @methods = class_name.constantize.new.methods - ApplicationController.new.methods %>
<% @methods.each do |method| %>
  it "should handle <%= method -%>"
<% end %>
  
end
