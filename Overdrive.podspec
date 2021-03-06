Pod::Spec.new do |s|
  s.name = 'Overdrive'
  s.version = '0.3'
  s.license = 'MIT'
  s.summary = 'Fast advanced task based API in Swift with focus on type safety, concurrency and multi threading'
  s.homepage = 'https://github.com/arikis/Overdrive'
  s.authors = { 'Said Sikira' => 'saidsikira@gmail.com' }
  s.documentation_url = 'https://swiftable.io/overdrive'
  s.social_media_url = 'https://twitter.com/saidsikira'

  s.source = { :git => 'https://github.com/arikis/Overdrive.git', :tag => s.version }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source_files = 'Sources/{Overdrive,Extensions}/**/*.swift'
end
