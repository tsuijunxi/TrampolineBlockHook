#
# Be sure to run `pod lib lint TrampolineBlockHook.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TrampolineBlockHook'
  s.version          = '0.1.0'
  s.summary          = 'A trampoline-based Objective-C block and method hook library.'

  s.description      = <<-DESC
TrampolineBlockHook provides low-level trampoline hooks for Objective-C block
invocations and instance method implementations. It supports optional pre-hook
and post-hook callbacks, and is intended for runtime research, debugging,
instrumentation, and mixed Objective-C/Swift projects that expose Objective-C
runtime entry points.
                       DESC

  s.homepage         = 'https://github.com/tsuijunxi/TrampolineBlockHook'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'tsuijunxi' => '598395670@qq.com' }
  s.source           = { :git => 'https://github.com/tsuijunxi/TrampolineBlockHook.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'

  s.source_files = 'TrampolineBlockHook/Classes/**/*'
end
