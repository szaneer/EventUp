# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
# ignore all warnings from all pods
inhibit_all_warnings!

target 'EventUp!' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for EventUp!
  pod 'HCSStarRatingView'
  pod 'Firebase'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'
  pod 'Firebase/Firestore'
  pod 'SVProgressHUD'
  pod 'JSQMessagesViewController'
  pod 'GeoFire', :git => 'https://github.com/firebase/geofire-objc.git'
  pod 'SidebarOverlay'
  pod 'GTToast'
  pod 'IQKeyboardManagerSwift'
  pod 'JTAppleCalendar', '~> 7.1.0'
  pod 'RevealingSplashView'

  target 'EventUp!Tests' do
    inherit! :search_paths
    # Pods for testing
    pod 'HCSStarRatingView'
    pod 'Firebase'
    pod 'Firebase/Database'
    pod 'Firebase/Storage'
    pod 'Firebase/Firestore'
    pod 'SVProgressHUD'
    pod 'JSQMessagesViewController'
    pod 'GeoFire', :git => 'https://github.com/firebase/geofire-objc.git'
    pod 'SidebarOverlay'
    pod 'GTToast'
    pod 'IQKeyboardManagerSwift'
    pod 'JTAppleCalendar', '~> 7.1.0'
    pod 'RevealingSplashView'

  end

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
