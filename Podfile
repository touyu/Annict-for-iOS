# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Annict-for-iOS' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Annict-for-iOS
  pod 'Firebase'
  pod 'Firebase/Database'

  target 'Annict-for-iOSTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'Annict-for-iOSUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

plugin 'cocoapods-keys', {
  :project => "Annict-for-iOS",
  :keys => [
    "AnnictClientID",
    "AnnictClientSecret",
    "AnnictAccessToken"
]}