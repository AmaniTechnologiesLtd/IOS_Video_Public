# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'



target 'VideoSample' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for VideoSample
  pod 'Socket.IO-Client-Swift', '16.0.1'
  pod 'WebRTC-lib' # '~> 94.0.0' use latest
end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        # config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
        config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
        # config.build_settings['ENABLE_BITCODE'] = 'NO'
        if target.name != 'Socket.IO-Client-Swift'
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
        end
        if target.name == 'WebRTC-lib'
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
        end
      end
    end
  end
end
