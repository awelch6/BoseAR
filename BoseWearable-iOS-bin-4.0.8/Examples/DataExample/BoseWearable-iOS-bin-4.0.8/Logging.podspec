Pod::Spec.new do |s|

  s.name          = "Logging"
  s.version       = "4.0.8"
  s.summary       = "Bose Logging"

  s.description   = <<-DESC
  Bose Logging Library for iOS
                    DESC

  s.homepage      = "https://developer.bose.com"

  s.author        = "Bose Corporation"
  s.source        = { :git => "git@github.com:BoseCorp/BoseWearable-iOS-bin.git", :tag => "#{s.version}" }
  s.license       = { :type => "Proprietary", :text => "Bose Confidential" }

  s.platform      = :ios, "11.4"
  s.swift_version = "5.0"

  s.vendored_framework = "Frameworks/iOS/Logging.framework"
end
