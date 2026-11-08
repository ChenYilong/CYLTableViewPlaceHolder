Pod::Spec.new do |s|
  s.name                = "KLTableViewAndCollectionViewPlaceholder"
  s.version             = "0.1.1"
  s.summary             = "A line of code implements the UITableView and UICollectionView placeholders."
  s.homepage            = "https://github.com/klaus01/KLTableViewAndCollectionViewPlaceholder"
  s.license             = { :type => "MIT", :file => "LICENSE" }
  s.author              = { "柯磊" => "kelei0017@gmail.com" }
  s.platform            = :ios, "6.0"
  s.source              = { :git => "https://github.com/klaus01/KLTableViewAndCollectionViewPlaceholder.git", :tag => s.version.to_s }
  s.source_files        = "KLTableViewAndCollectionViewPlaceholder/*.{h,m}"
  s.requires_arc        = true
end