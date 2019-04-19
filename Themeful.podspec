#
# Be sure to run `pod lib lint Themeful.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Themeful'
  s.version          = '0.1.0'
  s.summary          = 'easy way to set theme of app'
  s.description      = <<-DESC
                       customize you app using different theme
                       such as
                       label.text label.textColor ...
                       imageView.image ...
                       DESC
  s.homepage         = 'https://github.com/ws00801526/Themeful'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ws00801526' => '3057600441@qq.com' }
  s.source           = { :git => 'https://github.com/ws00801526/Themeful.git', :tag => s.version.to_s }
  s.swift_version = '5.0'
  s.ios.deployment_target = '9.0'
  s.default_subspecs = 'Core', 'Download'
  s.module_name = 'Themeful'

  s.subspec 'Core' do |ss|
      ss.source_files = 'Themeful/Classes/Base/**/*'
  end

  s.subspec 'Download' do |ss|
      ss.source_files = 'Themeful/Classes/Download/**/*'
      ss.dependency 'Themeful/Core'
      ss.dependency 'SSZipArchive'
  end
end
