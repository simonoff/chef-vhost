require 'spec_helper'

describe 'vhost::_test_nginx_lwrp' do
  include SpecHelper

  before(:each) do
    allow_recipe('nginx::default','vhost::nginx')
  end

  let(:chef_run) do
    chef_run_proxy.instance(step_into: 'vhost_nginx') do |node|
      node.set[:_vhost_test][:name] = 'test.dev'
      node.set[:_vhost_test][:action] = :enable
    end.converge(described_recipe)
  end

  it 'includes vhost::nginx recipe' do
    expect(chef_run).to include_recipe('vhost::nginx')
  end

  it 'calls enable nginx vhost resource' do
    expect(chef_run).to enable_vhost_nginx('test.dev')
  end

  it 'does not enable if already enabled' do
    chef_run_proxy.block(:converge, false) do |chef_run|
      allow(File).to receive(:symlink?)
                     .with(File.join(chef_run.node['nginx']['dir'], 'sites-enabled', 'test.dev.tld'))
                     .and_return(true)
    end

    expect(chef_run).not_to run_execute('nxensite test.dev.tld')
  end

  it 'enables a virtual host if it is not enabled' do
    expect(chef_run).to run_execute('nxensite test.dev.tld')
  end
end