Pod::Spec.new do |spec|
  spec.name = "Obihiro"
  spec.version = "1.0.1"
  spec.license = { type: 'MIT' }
  spec.homepage = "https://github.com/soutaro/Obihiro"
  spec.authors = { "Soutaro Matsumoto" => "matsumoto@soutaro.com" }
  spec.summary = "PageObject for ViewController"
  spec.source = { git: "https://github.com/soutaro/Obihiro.git", tag: spec.version }
  spec.source_files = "Obihiro/*.{h,m}"
  spec.ios.deployment_target = "8.0"
end
