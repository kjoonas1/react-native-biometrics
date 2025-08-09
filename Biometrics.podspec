require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "Biometrics"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => min_ios_version_supported }
  s.source       = { :git => "https://github.com/kjoonas1/react-native-biometrics.git", :tag => "#{s.version}" }

  s.source_files = [
    "ios/**/*.{h,m,mm,cpp,swift}",
    'shared/**/*.{h,cpp,mm,c}'
  ]
  s.public_header_files = [
    "ios/Biometrics.h",
    "shared/crypto/CryptoBridge.h"
  ]
  s.exclude_files = [
    "shared/crypto/CryptoHelper.h"
  ]

  s.ios.frameworks = 'LocalAuthentication'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'HEADER_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}/../shared"'
  }
  s.dependency 'OpenSSL-Universal'

  install_modules_dependencies(s)
end
