require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-calendar"
  s.version      = package["version"]
  s.summary      = "React Native Calendar TurboModule with New Architecture support"
  s.homepage     = "https://github.com/shadahmad7/react-native-calendar#readme"
  s.license      = "MIT"
  s.author       = { "Shad Ahmad" => "shad.ahmad0311@gmail.com" }
  s.platforms    = { :ios => "13.0" }

  # Use local path during development
  s.source       = { :path => "." }

  # Include only necessary files
  s.source_files = "ios/**/*.{h,m,mm,swift}"
  s.requires_arc = true
  s.swift_version = "5.0"
  s.static_framework = true

  # Dependencies
  s.dependency "React-Core"

  # Optional: other calendar or utility frameworks if needed
  # s.dependency "EventKit"
end
