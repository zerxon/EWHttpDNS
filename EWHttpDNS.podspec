Pod::Spec.new do |s|
  s.name         = "EWHttpDNS"
  s.version      = "1.0.0"
  s.summary      = "EWHttpDNS"
  s.homepage     = "http://www.brighttj.com"
  s.license      = "MIT"
  s.authors      = { 'wallaceleung' => 'wallaceleung@163.com'}
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/zerxon/EWHttpDNS.git", :tag => s.version }
  s.source_files = 'EWHttpDNS', 'EWHttpDNS/**/*.{h,m}'
  s.requires_arc = true
end
