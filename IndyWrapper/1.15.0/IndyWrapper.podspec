Pod::Spec.new do |s|
  s.name             = 'IndyWrapper'
  s.version          = '1.15.0'
  s.summary          = 'Indy iOS Wrapper'

  s.description      = <<-DESC
iOS wrapper for the Hyperledger Indy framework.
                       DESC

  s.homepage         = 'https://github.com/Przytua/libindy-pod'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Łukasz Przytuła' => 'lprzytula@gmail.com' }
  s.source           = { :git => 'https://github.com/Przytua/libindy-pod.git', :tag => s.version.to_s }
  s.static_framework = true

  s.ios.deployment_target = '10.0'

  s.source_files = 'Indy/Classes/**/*'
  s.public_header_files = 'Indy/Classes/**/*.h'

  s.dependency 'libsodium'
  s.dependency 'libzmq', '4.2.3'
  s.dependency 'OpenSSL-XCFramework'
  s.dependency 'IndyCore', '1.15.0'
end
