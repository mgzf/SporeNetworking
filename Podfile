use_frameworks!

target ‘SporeNetworking’ do
    
  pod 'Result', '~> 3.0'

  target ‘SporeNetworkingTests’ do
    inherit! :search_paths

    pod 'Quick', '~> 1.0.0'
    pod 'Nimble', '~> 5.1.1'
  end

  target ‘Demo’ do
    pod 'SporeNetworking', :path => './'
  end

end


post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.2'
        end
    end
end
