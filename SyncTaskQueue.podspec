#
#  Be sure to run `pod spec lint NetWorkState.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "SyncTaskQueue"
  s.version      = "0.0.3"
  s.summary      = "Network state handle for iOS."
  s.homepage     = "https://github.com/FlameGrace/SyncTaskQueue"
  s.license      = "BSD"
  s.author             = { "FlameGrace" => "flamegrace@hotmail.com" }
  s.ios.deployment_target = "6.0"
  s.source       = { :git => "https://github.com/FlameGrace/SyncTaskQueue.git", :tag => "0.0.3" }
  s.source_files  = "SyncTaskQueue", "SyncTaskQueue/**/*.{h,m}"
  s.public_header_files = "SyncTaskQueue/**/*.h"
end
