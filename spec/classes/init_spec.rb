require 'spec_helper'
describe 'puppet_localadmin' do
  context 'with default values for all parameters' do
    it { should contain_class('puppet_localadmin') }
  end
end
