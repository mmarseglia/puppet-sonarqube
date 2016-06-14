require 'spec_helper'

describe 'sonarqube::plugin' do
  let(:pre_condition) { [ 'include sonarqube' ] }
  let(:title) { 'sonar-puppet-plugin' }
  let(:facts) { { :systemd => false } }
  context 'installing from package' do
    let(:params) do 
      { :version     => '1.3-1',
        :use_package => true,
      }
    end
    it do
      is_expected.to contain_package('sonar-puppet-plugin').with(
        :ensure => '1.3-1',
        :notify => 'Service[sonarqube]',
      )
    end
    it { is_expected.not_to contain_maven('/tmp/sonar-puppet-plugin-1.3-3.jar') }
    it { is_expected.not_to contain_exec('remove-old-versions-of-sonar-puppet-plugin') }
    it { is_expected.not_to contain_file('/opt/sonar/extensions/plugins/sonar-puppet-plugin-1.3-3.jar') }
  end
  context 'uninstalling from package' do
    let(:params) do 
      { :version     => '1.3-1',
        :use_package => true,
        :ensure      => 'absent'
      }
    end
    it do 
      is_expected.to contain_package('sonar-puppet-plugin').with(
        :ensure => 'absent',
        :notify => 'Service[sonarqube]',
      )
    end
  end
  context 'installing from jar' do
    let(:params) { { :version => '1.3' } }
    it do
      is_expected.to contain_maven('/tmp/sonar-puppet-plugin-1.3.jar').with(
        :groupid    => 'org.codehaus.sonar-plugins',
        :artifactid => 'sonar-puppet-plugin',
        :version    => '1.3',
        :before     => 'File[/var/local/sonar/extensions/plugins/sonar-puppet-plugin-1.3.jar]',
        :require    => 'File[/var/local/sonar/extensions/plugins]',
      )
    end
    it do
      is_expected.to contain_exec('remove-old-versions-of-sonar-puppet-plugin').with(
        :command => '/tmp/cleanup-old-plugin-versions.sh /var/local/sonar/extensions/plugins sonar-puppet-plugin 1.3',
        :refreshonly => true,
      )
    end
    it do
      is_expected.to contain_file('/var/local/sonar/extensions/plugins/sonar-puppet-plugin-1.3.jar').with(
        :ensure => 'present',
        :source => '/tmp/sonar-puppet-plugin-1.3.jar',
        :owner  => 'sonar',
        :group  => 'sonar',
        :notify => 'Service[sonarqube]',
      )
    end
  end
  context 'uninstalling from jar' do
    let(:params) do 
      { :version     => '1.3',
        :ensure      => 'absent',
      }
    end
    it do
      is_expected.to contain_file('/var/local/sonar/extensions/plugins/sonar-puppet-plugin-1.3.jar').with(
        :ensure => 'absent',
        :notify => 'Service[sonarqube]',
      )
    end
  end
  context 'validation' do
    let(:params) do 
      { :version     => '1.3-1',
        :ensure      => 'not_allowed',
      }
    end
    it { is_expected.to compile.and_raise_error(/Attribute ensure can only be present or absent/) }
  end
end
