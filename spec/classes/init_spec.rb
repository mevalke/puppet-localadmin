require 'spec_helper'
describe 'puppet-localadmin' do
  context 'with default values for all parameters' do
    it { should contain_class('puppet-localadmin') }
  end
end
