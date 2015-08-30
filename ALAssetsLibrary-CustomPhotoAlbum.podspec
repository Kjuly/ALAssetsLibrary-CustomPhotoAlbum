Pod::Spec.new do |s|
  s.name             = "ALAssetsLibrary-CustomPhotoAlbum"
  s.version          = "1.3.1"
  s.summary          = "A nice ALAssetsLibrary category for saving images & videos into custom photo album."
  s.homepage         = "https://github.com/Kjuly/ALAssetsLibrary-CustomPhotoAlbum"
  s.license          = 'MIT'
  s.author           = { "Kaijie Yu" => "dev@kjuly.com" }
  s.source           = { :git => "https://github.com/Kjuly/ALAssetsLibrary-CustomPhotoAlbum.git", :tag => s.version.to_s }

  s.platform     = :ios, '5.0'
  s.requires_arc = true

  s.source_files = 'ALAssetsLibrary-CustomPhotoAlbum'

  s.frameworks = 'UIKit', 'AssetsLibrary'
  s.weak_framework = 'Photos'
end

