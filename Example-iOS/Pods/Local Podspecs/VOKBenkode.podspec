Pod::Spec.new do |s|
  s.name             = "VOKBenkode"
  s.version          = "0.2.0"
  s.summary          = "An Objective-C library for encoding/decoding objects using Bencoding."
  s.homepage         = "https://github.com/vokalinteractive/VOKBenkode"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "VOKAL Interactive" => "hello@vokalinteractive.com" }
  s.source           = { :git => "https://github.com/vokalinteractive/VOKBenkode.git", :tag => s.version.to_s }

  s.ios.deployment_target = '6.0'
  s.osx.deployment_target = '10.8'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
end
