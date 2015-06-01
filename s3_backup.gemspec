Gem::Specification.new do |s|
  s.name        = 's3_backup'
  s.version     = '0.1.0'
  s.date        = Time.now.strftime("%Y-%m-%d")
  s.summary     = 'Backup directories in S3 in a safe way'
  s.description = 'Library for syncing a directory up and down from an s3 bucket'
  s.authors     = ['David Buckhurst']
  s.email       = 'david.buckhurst@bbc.co.uk'
  s.files       = [ 'lib/s3_backup.rb', 'README.md', 'LICENSE' ]
  s.homepage    = 'https://github.com/bbc/s3_backup'
  s.license     = 'MIT'
  s.add_runtime_dependency 'aws-sdk', '~> 2'
end
