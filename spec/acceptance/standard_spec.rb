require 'spec_helper_acceptance'

describe 'sonar class' do

context 'default parameters' do

it 'should work' do

pp = <<-EOS
 include ::sonarqube
EOS

expect(apply_manifest(pp).exit_code).to_not eq(1)

end
end
end
