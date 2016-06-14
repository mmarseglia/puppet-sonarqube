require 'spec_helper'

describe 'sonarqube::scanner::config' do
  context 'with default parameters' do
    it do
      is_expected.to contain_file('/usr/local/sonar-scanner-2.6/conf/sonar-scanner.properties').with(
        :ensure  => 'file',
        :content => /http:\/\/localhost:9000/,
        :require => 'Class[Sonarqube::Scanner::Install]',
      )
    end
  end
  context 'when using package' do
    let(:params) do
      {  :use_package => true,
         :installroot  => '/opt/sonar-scanner-2.6',
      }
    end
    it do
      is_expected.to contain_file('/opt/sonar-scanner-2.6/conf/sonar-scanner.properties').with(
        :ensure  => 'file',
        :content => /http:\/\/localhost:9000/,
        :require => 'Class[Sonarqube::Scanner::Install]',
      )
    end
  end
  context 'with custom sonarqube_server' do
    let(:params) { { :sonarqube_server => 'http://1.2.3.4:9999'} }
    it do
      is_expected.to contain_file('/usr/local/sonar-scanner-2.6/conf/sonar-scanner.properties').with(
        :ensure  => 'file',
        :content => /http:\/\/1.2.3.4:9999/,
        :require => 'Class[Sonarqube::Scanner::Install]',
      )
    end
  end
end
