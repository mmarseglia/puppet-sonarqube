require 'spec_helper'

describe 'sonarqube::repo' do
  context 'with default parameters' do
    context 'on a redhat system' do
      let(:facts) { { :osfamily => 'RedHat', } }
      it do
        is_expected.to contain_yumrepo('sonarqube').with(
          :ensure   => 'present',
          :enabled  => '1',
          :baseurl  => /sonar-pkg\/rpm/,
          :gpgcheck => '0',
        )
      end
      it { is_expected.not_to contain_apt__source() }
      it { is_expected.not_to contain_zypprepo() }
    end
    context 'on a Debian system' do
      let(:facts) do 
        { :osfamily => 'Debian',
          :lsbdistid => 'Debian',
        }
      end
      it do
        is_expected.to contain_apt__source('sonarqube').with(
          :location => /sonar-pkg\/deb/,
          :release  => 'binary',
        )
      end
      it { is_expected.not_to contain_yumrepo() }
      it { is_expected.not_to contain_zypper() }
    end
    context 'on a Suse system' do
      let(:facts) { { :osfamily => 'Suse' } }
      it do
        is_expected.to contain_zypprepo('sonarqube').with(
          :enabled     => '1',
          :baseurl     => /sonar-pkg\/rpm/,
          :autorefresh => '1',
          :gpgcheck    => '0',
          :type        => 'rpm-md',
        )
      end
      it { is_expected.not_to contain_yumrepo() }
      it { is_expected.not_to contain_apt__source() }
    end
    context 'on an unsupported system' do
      let(:facts) { { :osfamily => 'WierdOS' } }
      it { is_expected.to compile.and_raise_error(/Unsupported OS WierdOS/) }
    end
  end # with default parameters
  context "with custom parameters" do
    let(:params) { { :repo_url => 'http://some.custom.url', } }
    context "on a RedHat system" do
      let(:facts) { { :osfamily => 'RedHat', } }
      it do
        is_expected.to contain_yumrepo('sonarqube').with(
          :ensure   => 'present',
          :enabled  => '1',
          :baseurl  => 'http://some.custom.url',
          :gpgcheck => '0',
        )
      end
      it { is_expected.not_to contain_apt__source() }
      it { is_expected.not_to contain_zypprepo() }
    end
    context 'on a Debian system' do
      let(:facts) do
        { :osfamily => 'Debian', 
          :lsbdistid => 'Debian',
        }
      end
      it do
        is_expected.to contain_apt__source('sonarqube').with(
          :location => 'http://some.custom.url',
          :release  => 'binary',
        )
      end
      it { is_expected.not_to contain_yumrepo() }
      it { is_expected.not_to contain_zypprepo() }
    end
    context 'on a Suse system' do
      let(:facts) { { :osfamily => 'Suse', } }
      it do
        is_expected.to contain_zypprepo('sonarqube').with(
          :enabled     => '1',
          :baseurl     => 'http://some.custom.url',
          :autorefresh => '1',
          :gpgcheck    => '0',
          :type        => 'rpm-md',
        )
      end
      it { is_expected.not_to contain_yumrepo() }
      it { is_expected.not_to contain_apt__source() }
    end
    context 'on an unsupported system' do
      let(:facts) { { :osfamily => 'WierdOS' } }
      it { is_expected.to compile.and_raise_error(/Unsupported OS WierdOS/) }
    end
  end
end
