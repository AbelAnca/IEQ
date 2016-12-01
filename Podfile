# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'IEQ' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for IEQ
    pod 'Alamofire', '~> 4.0'
    pod 'KVNProgress', '~> 2.2.1'
    pod 'RealmSwift'
    pod 'AsyncSwift'
    pod 'Fabric'
    pod 'Crashlytics'

  target 'IEQTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'IEQUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
installer.pods_project.targets.each do |target|
target.build_configurations.each do |config|
config.build_settings['SWIFT_VERSION'] = '3.0'
config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.10'
end
end
end
