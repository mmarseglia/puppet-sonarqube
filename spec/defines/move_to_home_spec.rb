require 'spec_helper'

describe "sonarqube::move_to_home" do
  let(:title) { 'dirtomove' }
  let(:pre_condition) { [ 'include sonarqube' ] }
  let(:params) { { :home => '/home/tomoveto' } }
  let(:facts) { { :systemd => false } }
  it do 
    is_expected.to contain_file('/home/tomoveto/dirtomove').with(
      :ensure  => 'directory',
      :require => 'File[/home/tomoveto]',
    )
  end
  it do
    is_expected.to contain_file('/usr/local/sonar/dirtomove').with(
      :ensure  => 'link',
      :target  => '/home/tomoveto/dirtomove',
      :require => [ 'File[/usr/local/sonar]',
                    'File[/home/tomoveto/dirtomove]' ],
    )
  end
end



