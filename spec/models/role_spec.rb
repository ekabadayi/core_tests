require File.dirname(__FILE__) + '/../spec_helper'

describe Role do
  describe '#by_permission' do
    it 'returns roles with given permission' do
      edit_project_role = Factory.create(:role, :name => 'edit project role', :permissions => [:edit_project])
      some_other_role   = Factory.create(:role, :name => 'some other role', :permissions => [:some_other])
      Role.by_permission(:edit_project).should == [edit_project_role]
      Role.by_permission(:some_other).should == [some_other_role]
    end
  end
end
