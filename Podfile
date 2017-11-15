# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
# ignore all warnings from all pods
inhibit_all_warnings!

target 'EventUp!' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for EventUp!
  pod 'Firebase'
  pod 'Firebase/Database'
  pod 'Firebase/Firestore'
  pod 'FirebaseUI/Auth'
  pod 'FirebaseUI/Google'
  pod 'FirebaseUI/Facebook'
  pod 'FirebaseUI/Twitter'
  pod 'FirebaseUI/Phone'
  pod 'SVProgressHUD'
  pod 'JSQMessagesViewController'
  pod 'TextFieldEffects'
  pod 'GeoFire', :git => 'https://github.com/firebase/geofire-objc.git'
  pod 'SidebarOverlay'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == "GeoFire"
            target.build_configurations.each do |config|
                config.build_settings["FRAMEWORK_SEARCH_PATHS"] = '$(inherited) "${SRCROOT}/FirebaseDatabase/Frameworks"'
                config.build_settings["HEADER_SEARCH_PATHS"] = '$(inherited) "${PODS_ROOT}/Headers/Public/FirebaseDatabase"'
                config.build_settings["OTHER_CFLAGS"] = '$(inherited) -isystem "${PODS_ROOT}/Headers/Public/FirebaseDatabase"'
                config.build_settings["OTHER_LDFLAGS"] = '$(inherited) -framework "FirebaseDatabase"'
            end
        end
        
    end
end
