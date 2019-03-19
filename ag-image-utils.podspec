Pod::Spec.new do |s|
  s.name         = "ag-image-utils"
  s.version      = "1.0.0"
  s.summary      = "Image utils for React Native."
  s.description  = <<-DESC
    Image utils for React Native.
                   DESC

  s.homepage     = "https://github.com/opqqqqqq/ag-image-utils"
  s.license      = "Apache-2.0"
  s.author             = "Ruby Dragon"
  s.source       = { :git => "https://github.com/opqqqqqq/ag-image-utils.git", :tag => "#{s.version}" }
  s.source_files  = "ios"
  s.dependency "React"
  
  s.platform     = :ios, "8.0"
end
