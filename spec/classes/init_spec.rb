require 'spec_helper'

describe 'sonarqube' do
  context 'with default parameters' do
    let(:facts) do
      { :systemd      => false,
        :osfamily     => 'redhat',
        :kernel       => 'linux',
        :architexture => 'x86_64',
      }
    end
    it { is_expected.to contain_class('sonarqube') }
    it do 
      is_expected.to contain_user('sonar').with(
        :ensure => 'present',
        :home   => '/var/local/sonar',
        :managehome => 'false',
        :system     => 'true',
      )
    end
    it do 
      is_expected.to contain_group('sonar').with(
        :ensure => 'present',
        :system => 'true',
      )
    end
    it do 
      is_expected.to contain_file('/var/local/sonar').with(
        :ensure => 'directory',
        :mode   => '0700',
        :owner  => 'sonar',
        :group  => 'sonar',
      )
    end
    it { is_expected.to contain_package('unzip').with_ensure('present') }
    ['data', 'extras', 'extensions', 'logs'].each do |dir|
      it { is_expected.to contain_sonarqube__move_to_home("#{dir}").with_home('/var/local/sonar') }
    end
    it do
      is_expected.to contain_archive('/tmp/sonarqube-4.5.7.zip').with(
        :ensure       => 'present',
        :extract      => 'true',
        :extract_path => '/usr/local',
        :source       => 'https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-4.5.7.zip',
        :user         => 'sonar',
        :group        => 'sonar',
        :creates      => '/usr/local/sonarqube-4.5.7/COPYING',
        :notify       => 'Service[sonarqube]',
      )
    end
    it do 
      is_expected.to contain_archive('/tmp/sonarqube-4.5.7.zip').that_requires(
        [ 'File[/usr/local/sonarqube-4.5.7]', 
          'Package[unzip]', 
          'Sonarqube::Move_to_home[data]',
          'Sonarqube::Move_to_home[extras]',
          'Sonarqube::Move_to_home[extensions]',
          'Sonarqube::Move_to_home[logs]',
        ]
      )
    end
    it do 
      is_expected.to contain_file('/usr/local/sonarqube-4.5.7').with(
        :ensure => 'directory',
        :owner  => 'sonar',
        :group  => 'sonar',
      )
    end
    it do
      is_expected.to contain_file('/usr/local/sonar').with(
        :ensure => 'link',
        :target => '/usr/local/sonarqube-4.5.7',
        :owner  => 'sonar',
        :group  => 'sonar',
        :notify => 'Service[sonarqube]',
        :require => 'File[/usr/local/sonarqube-4.5.7]',
      )
    end
    it do
      is_expected.to contain_file('/var/local/sonar/extensions/plugins').with(
        :ensure => 'directory',
        :owner  => 'sonar',
        :group  => 'sonar',
      )
    end
    it { is_expected.to contain_file('/var/local/sonar/extensions/plugins').that_requires('Sonarqube::Move_to_home[extensions]') }
    it do
      is_expected.to contain_file('/usr/local/sonar/conf/sonar.properties').with(
        :ensure => 'file',
        :mode => '0600',
        :content => /jdbc:h2:tcp:\/\/localhost:9092\/sonar/,
      )
    end
    it { is_expected.to contain_file('/usr/local/sonar/conf/sonar.properties').that_requires('Archive[/tmp/sonarqube-4.5.7.zip]') }
    it { is_expected.to contain_file('/usr/local/sonar/conf/sonar.properties').with_content(/sonar.updatecenter.activate=true/) }
    it do
      is_expected.to contain_file('/usr/local/sonar/bin/linux-x86-64/sonar.sh').with(
        :ensure => 'file',
        :owner  => 'sonar',
        :group  => 'sonar',
      )
    end
    it { is_expected.to contain_file('/usr/local/sonar/bin/linux-x86-64/sonar.sh').that_requires('Archive[/tmp/sonarqube-4.5.7.zip]') }
    it do
      is_expected.to contain_file('/etc/init.d/sonar').with(
        :ensure  => 'link',
        :target  => '/usr/local/sonar/bin/linux-x86-64/sonar.sh',
      )
    end
    it { is_expected.to contain_file('/etc/init.d/sonar').that_requires('Archive[/tmp/sonarqube-4.5.7.zip]') }
    it { is_expected.not_to contain_file('/usr/lib/systemd/system/sonar.service') }
    it { is_expected.not_to contain_class('systemd') }
    it do
      is_expected.to contain_service('sonarqube').with(
        :ensure     => 'running',
        :name       => 'sonar',
        :hasrestart => 'true',
        :hasstatus  => 'true',
        :enable     => 'true',
      )
    end
    it do
      is_expected.to contain_service('sonarqube').that_requires(
        [ 'Archive[/tmp/sonarqube-4.5.7.zip]',
          'File[/etc/init.d/sonar]',
        ]
      )
    end
  end # context default parameters
  context 'on a systemd enabled system' do
    let(:facts) do
      { :systemd      => true,
        :path         => '/usr/sbin',
        :osfamily     => 'redhat',
        :kernel       => 'linux',
        :architexture => 'x86_64',
      }
    end
    it do
      is_expected.to contain_systemd__unit_file('sonar.service').with(
        :path   => '/usr/lib/systemd/system/',
        :before => 'Service[sonarqube]',
      )
    end
  end # context systemd
  context 'when installing from package' do
    let(:facts) do
      { :systemd      => false,
        :osfamily     => 'redhat',
        :kernel       => 'linux',
        :architexture => 'x86_64',
      }
    end
    context 'without repo management' do
      let(:params) do
        { :use_package  => true,
          :version      => '5.4-1',
          :package_name => 'sonar',
        }
      end
      it { is_expected.to contain_package('sonar').with_ensure('5.4-1') }
      # we do not check all properties here, only the one that are mutable
      it { is_expected.to contain_user('sonar').with_home('/var/local/sonar') }
      it { is_expected.to contain_group('sonar') }
      it { is_expected.to contain_file('/var/local/sonar') }
      it { is_expected.to contain_file('/opt/sonar/conf/sonar.properties').that_requires('Package[sonar]') }
      it { is_expected.to contain_file('/opt/sonar/bin/linux-x86-64/sonar.sh').that_requires('Package[sonar]') }
      it { is_expected.to contain_file('/etc/init.d/sonar').that_requires('Package[sonar]') }
      it { is_expected.to contain_service('sonarqube').that_requires(['Package[sonar]', 'File[/etc/init.d/sonar]']) }
      # resources not allowed here
      it { is_expected.not_to contain_sonarqube__move_to_home() }
      it { is_expected.not_to contain_package('unzip') }
      it { is_expected.not_to contain_archive() }
      it { is_expected.not_to contain_file('/usr/local/sonar-5.4-1') }
      it { is_expected.not_to contain_file('/usr/local/sonar') }
      it { is_expected.not_to contain_file('/var/local/sonar/extension/plugins') }
    end # context without repo
    context 'with repo management' do
      let(:params) do
        { :use_package  => true,
          :version      => '5.4-1',
          :package_name => 'sonar',
          :manage_repo  => true,
        }
      end
      # only test the repo stuff
      it do
        is_expected.to contain_class('sonarqube::repo').with(
          :repo_url => /http:\/\/downloads.sourceforge.net\/project\/sonar-pkg/,
          :before   => 'Package[sonar]',
        )
      end
    end #context with repo
  end # context default parameters

  context 'specific parameter settings' do
    let(:facts) do
      { :systemd      => false,
        :osfamily     => 'redhat',
        :kernel       => 'linux',
        :architexture => 'x86_64',
      }
    end
    let(:sonar_properties) { '/usr/local/sonar/conf/sonar.properties' }
    context "when crowd configuration is supplied" do
      let(:params) do 
        { :crowd => {
          'application' => 'crowdapplication',
          'service_url' => 'crowdserviceurl',
          'password'    => 'crowdpassword',
        } }
      end
      it 'should generate sonar.properties config for crowd' do
        is_expected.to contain_file(sonar_properties).with_content(%r[sonar\.authenticator\.class: org\.sonar\.plugins\.crowd\.CrowdAuthenticator])
        is_expected.to contain_file(sonar_properties).with_content(%r[crowd\.url: crowdserviceurl])
        is_expected.to contain_file(sonar_properties).with_content(%r[crowd\.application: crowdapplication])
        is_expected.to contain_file(sonar_properties).with_content(%r[crowd\.password: crowdpassword])
      end
    end # context crowd
      context "when http configuration is supplies as array" do
        let(:params) do
          { "http_proxy" => {
              'host'        => 'proxy.example.com',
              'port'        => '8080',
              'ntlm_domain' => '',
              'user'        => 'proxy_user',
              'password'    => 'proxy_secret',
            },
            "https_proxy" => {
              'host'        => 'proxy.example.com',
              'port'        => '8080',
              'ntlm_domain' => '',
              'user'        => 'proxy_user',
              'password'    => 'proxy_secret',
            } 
          }
        end
        it { is_expected.to contain_file(sonar_properties).with_content(/http.proxyHost=proxy.example.com/) }
        it { is_expected.to contain_file(sonar_properties).with_content(/http.proxyPort=8080/) }
        it { is_expected.to contain_file(sonar_properties).with_content(/http.auth.ntlm.domain=/) }
        it { is_expected.to contain_file(sonar_properties).with_content(/http.proxyUser=proxy_user/) }
        it { is_expected.to contain_file(sonar_properties).with_content(/http.proxyPassword=proxy_secret/) }
        it { is_expected.to contain_file(sonar_properties).with_content(/https.proxyHost=proxy.example.com/) }
        it { is_expected.to contain_file(sonar_properties).with_content(/https.proxyPort=8080/) }
        it { is_expected.to contain_file(sonar_properties).with_content(/https.auth.ntlm.domain=/) }
        it { is_expected.to contain_file(sonar_properties).with_content(/https.proxyUser=proxy_user/) }
        it { is_expected.to contain_file(sonar_properties).with_content(/https.proxyPassword=proxy_secret/) }
      end
    context "when no crowd configuration is supplied" do
      it { is_expected.to contain_file(sonar_properties).without_content("crowd") }
    end # context no crowd
    context "when ldap local users configuration is supplied" do
      let(:params) do 
        { :ldap => {
          'url'          => 'ldap://myserver.mycompany.com',
          'user_base_dn' => 'ou=Users,dc=mycompany,dc=com',
          'local_users'  => 'foo',
        } }
      end
      it { is_expected.to contain_file(sonar_properties).with_content(/sonar.security.localUsers=foo/) }
      it { is_expected.to contain_file(sonar_properties).with_content(/sonar.security.realm=LDAP/) }
      it { is_expected.to contain_file(sonar_properties).with_content(/ldap.url=ldap:\/\/myserver.mycompany.com/) }
      it { is_expected.to contain_file(sonar_properties).with_content(/ldap.user.baseDn: ou=Users,dc=mycompany,dc=com/) }
    end
    context "when ldap local users configuration is supplied as array" do
      let(:params) do
        { :ldap => {
          'url'          => 'ldap://myserver.mycompany.com',
          'user_base_dn' => 'ou=Users,dc=mycompany,dc=com',
          'local_users' => ['foo','bar'],
        } }
      end
      it { is_expected.to contain_file(sonar_properties).with_content(/sonar.security.localUsers=foo,bar/) }
      it { is_expected.to contain_file(sonar_properties).with_content(/sonar.security.realm=LDAP/) }
      it { is_expected.to contain_file(sonar_properties).with_content(/ldap.url=ldap:\/\/myserver.mycompany.com/) }
      it { is_expected.to contain_file(sonar_properties).with_content(/ldap.user.baseDn: ou=Users,dc=mycompany,dc=com/) }
    end
    context "when no ldap local users configuration is supplied", :compile do
      let(:params) do 
        { :ldap => {
          'url'          => 'ldap://myserver.mycompany.com',
          'user_base_dn' => 'ou=Users,dc=mycompany,dc=com',
        } }
      end
      it { is_expected.to contain_file(sonar_properties).without_content(/sonar.security.localUsers/) }
      it { is_expected.to contain_file(sonar_properties).with_content(/sonar.security.realm=LDAP/) }
      it { is_expected.to contain_file(sonar_properties).with_content(/ldap.url=ldap:\/\/myserver.mycompany.com/) }
      it { is_expected.to contain_file(sonar_properties).with_content(/ldap.user.baseDn: ou=Users,dc=mycompany,dc=com/) }
    end
    context "when no ldap configuration is supplied", :compile do
      it { is_expected.to contain_file(sonar_properties).without_content(/sonar.security/) }
      it { is_expected.to contain_file(sonar_properties).without_content(/ldap./) }
    end
  end # parameter testing
end
