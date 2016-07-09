Pod::Spec.new do |s|

  s.name         = "Overdrive"
  s.version      = "0.0.1"
  s.summary      = "Elegant task based API in Swift"

  s.description  = <<-DESC
  Elegant task based API in Swift with focus on concurrency, multi-threading and type safety.
                   DESC

  s.homepage     = "https://arikis.github.io/Overdrive"

  s.license      = "MIT"

  s.author             = { "SaidSikira" => "saidsikira@gmail.com" }

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.11"
  s.tvos.deployment_target = "9.0"

  s.source = { :git => "https://github.com/arikis/Overdrive.git", :tag => "#{s.version}" }

  s.source_files = "Sources/*.swift"
end
