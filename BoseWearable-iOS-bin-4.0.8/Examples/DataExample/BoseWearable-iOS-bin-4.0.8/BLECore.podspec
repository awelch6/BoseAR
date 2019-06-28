Pod::Spec.new do |s|

  s.name          = "BLECore"
  s.version       = "4.0.8"
  s.summary       = "Bose BLE Core Library"

  s.description   = <<-DESC
  This library provides core BLE functionality used by the BoseWearable library.
                    DESC

  s.homepage      = "https://developer.bose.com"

  s.author        = "Bose Corporation"
  s.source        = { :git => "git@github.com:BoseCorp/BoseWearable-iOS-bin.git", :tag => "#{s.version}" }
  s.license       = { :type => "Proprietary", :text => "Bose Confidential" }

  s.platform      = :ios, "11.4"
  s.swift_version = "5.0"

  s.vendored_framework = "Frameworks/iOS/BLECore.framework"

  s.dependency "Logging", "#{s.version}"
end
