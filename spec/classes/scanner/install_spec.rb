require 'spec_helper'

describe 'sonarqube::scanner::install' do
  context 'with default parameters' do
    it { is_expected.to contain_class('archive') }
    it do
      is_expected.to contain_archive('/tmp/sonar-scanner-2.6.zip').with(
        :ensure       =>  'present',
        :source       =>  'https://sonarsource.bintray.com/Distribution/sonar-scanner-cli/sonar-scanner-2.6.zip',
        :extract      => true,
        :extract_path => '/usr/local',
        :creates      => '/usr/local/sonar-scanner-2.6',
        :require      => 'Package[unzip]',
      )
    end
    it do
      is_expected.to contain_file('/usr/local/sonar-scanner').with(
        :ensure => 'link',
        :target => '/usr/local/sonar-scanner-2.6',
      )
    end
    it do 
      is_expected.to contain_file('/etc/profile.d/sonarhome.sh').with(
        :ensure  => 'file',
        :content => 'export SONAR_SCANNER_HOME=/usr/local/sonar-scanner',
      )
    end
  end
  context 'with custom parameters' do
    context 'when use_package' do
      let(:params) do
        { :use_package => true,
          :version     => '2.6-1',
          :installroot => '/opt/sonar-sanner-2.6',
        }
      end
      it do
        is_expected.to contain_package('sonar-scanner').with(
          :ensure => '2.6-1',
        )
      end
      it { is_expected.not_to contain_class('archive') }
      it { is_expected.not_to contain_package('unzip') }
      it { is_expected.not_to contain_archive('/tmp/sonar-scanner-2.6.zip') }
      it do
        is_expected.to contain_file('/opt/sonar-scanner').with(
          :ensure => 'link',
          :target => '/opt/sonar-sanner-2.6',
        )
      end
      it do
        is_expected.to contain_file('/etc/profile.d/sonarhome.sh').with(
          :ensure  => 'file',
          :content => 'export SONAR_SCANNER_HOME=/opt/sonar-scanner',
        )
      end
    end
    context 'when manage_link is false' do
      let(:params) { { :manage_link => false } }
      it { is_expected.not_to contain_file('/usr/local/sonar-scanner') }
    end
    context 'when manage_profile is false' do
      let(:params) { { :manage_profile => false } } 
      it { is_expected.not_to contain_file('/etc/profile.d/sonarhome.sh') }
    end
  end
end
