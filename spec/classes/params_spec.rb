require 'spec_helper'

describe 'sonarqube::params' do
  context 'on a redhat system' do
    let(:facts) do
      {  :kernel       => 'linux',
         :architecture => 'x86_64',
         :osfamily     => 'RedHat',
      }
    end
    it { is_expected.to contain_sonarqube__params }
    it "Should not contain any resources" do
      should have_resource_count(0)
    end
  end
end
