require 'spec_helper'

describe 'sonarqube::scanner' do
  context 'with default parameters' do
    it { is_expected.to contain_class('sonarqube::scanner::install').that_comes_before('Class[Sonarqube::Scanner::Config]') }
    it { is_expected.to contain_class('sonarqube::scanner::config').that_requires('Class[Sonarqube::Scanner::Install]') }
  end
  context 'parameter validation' do
    context 'package_name' do
      let(:params) { { :package_name => false } }
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'installroot' do
      ['wrong_path', 5, true].each do |value|
        let(:params) { { :installroot => "#{value}" } }
        it { expect { is_expected.to compile }.to raise_error }
      end
    end
    context 'use_package' do
      let(:params) { { :use_package => 'ofcourse' } }
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'manage_profile' do
      let(:params) { { :manage_profile => 'ofcourse' } }
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'manage_link' do
      let(:params) { { :manage_link => 'ofcourse' } }
      it { expect { is_expected.to compile }.to raise_error }
    end
  end
end


