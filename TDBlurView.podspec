Pod::Spec.new do |s|
  s.name    = 'TDBlurView'
  s.version = '0.0.3'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.summary = 'Blurs views'
  s.homepage = 'http://github.com/timominous/TDBlurView'
  s.authors = {
    'timominous' => 'timominous@gmail.com'
  }

  s.source = {
    :git => 'https://github.com/timominous/TDBlurView.git',
    :tag => "#{s.version}"
  }
  s.platform = :ios, '6.0'
  s.requires_arc = true

  s.source_files = 'TDBlurView/**/*.{h,m}'
  s.preserve_paths = '*'
end
