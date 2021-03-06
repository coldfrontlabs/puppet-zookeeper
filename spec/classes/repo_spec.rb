require 'spec_helper'

shared_examples 'zookeeper repo release support' do |os_facts|
  context 'fail when release not supported' do
    let :pre_condition do
      'class {"zookeeper":
        repo   => "cloudera",
        cdhver => "5",
       }'
    end

    it do
      expect do
        is_expected.to compile
    end.to raise_error(/is not supported for redhat version/) end
  end
end

shared_examples 'zookeeper repo arch support' do |os_facts|
  context 'fail when architecture not supported' do
    let :pre_condition do
      'class {"zookeeper":
        repo   => "cloudera",
        cdhver => "5",
       }'
    end

    it do
      expect do
        is_expected.to compile
    end.to raise_error(/is not supported for architecture/) end
  end
end

shared_examples 'zookeeper repo' do |os_facts|
  let(:user) { 'zookeeper' }
  let(:group) { 'zookeeper' }

  os_release = os_facts[:os]['release']['major']
  os_hardware = os_facts[:os]['hardware']

  if os_facts[:osfamily] == 'RedHat'
    context 'Cloudera repo' do
      let :pre_condition do
        'class {"zookeeper":
          repo   => "cloudera",
          cdhver => "5",
        }'
      end

      it { is_expected.to contain_yumrepo('cloudera-cdh5').with({
          baseurl: "http://archive.cloudera.com/cdh5/redhat/#{os_release}/#{os_hardware}/cdh/5/"
        }) }
    end
  end

  context 'fail when CDH version not supported' do
    let :pre_condition do
      'class {"zookeeper":
        repo   => "cloudera",
        cdhver => "6",
       }'
    end

    it do
      expect do
        should compile
    end.to raise_error(/is not a supported cloudera repo./) end
  end

  context 'fail when repository source not supported' do
    let :pre_condition do
      'class {"zookeeper":
        repo => "another-repo",
       }'
    end

    it do
      expect do
        should compile
    end.to raise_error(/provides no repository information for yum repository/) end
  end
end

describe 'zookeeper::install::repo' do
  on_supported_os.each do |os, os_facts|
    os_facts[:os]['hardware'] = 'x86_64'

    context "on #{os}" do
      let(:facts) do
        os_facts.merge({
          :ipaddress     => '192.168.1.1',
          :puppetversion => Puppet.version,
        })
      end

      include_examples 'zookeeper repo', os_facts
    end
  end

  context 'test unsupported repo arch' do
    test_on = {
      :hardwaremodels => ['arc'],
      :supported_os => [
        {
          'operatingsystem'        => 'RedHat',
          'operatingsystemrelease' => ['7'],
        },
      ],
    }
    on_supported_os(test_on).each do |os, os_facts|
      context "on #{os}" do
        let(:facts) do
          os_facts.merge({
            :ipaddress     => '192.168.1.1',
            :puppetversion => Puppet.version,
          })
        end

        include_examples 'zookeeper repo arch support', os_facts
      end
    end
  end

  context 'test unsupported repo release' do
    test_on = {
      :supported_os => [
        {
          'operatingsystem'        => 'RedHat',
          'operatingsystemrelease' => ['8'],
        },
      ],
    }
    on_supported_os(test_on).each do |os, os_facts|
      os_facts[:os]['hardware'] = 'x86_64'

      context "on #{os}" do
        let(:facts) do
          os_facts.merge({
            :ipaddress     => '192.168.1.1',
            :puppetversion => Puppet.version,
          })
        end

        include_examples 'zookeeper repo release support', os_facts
      end
    end
  end
end
