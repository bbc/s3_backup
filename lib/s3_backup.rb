require 'rubygems'
require 'aws-sdk'
require 'fileutils'

class S3Backup

  attr_accessor :region, :bucket, :prefix, :directory, :s3_client

  def initialize(args)
    @region = args[:region]
    @bucket = args[:bucket]
    @prefix = args[:prefix]
    @directory = args[:directory]

    @s3_client =  Aws::S3::Client.new( region: region )
  end

  def filename_from_key(filename)
    filename.split('/').last
  end

  def key_from_filename(filename)
    key = prefix + filename.split('/').last
    raise 'No filename' if key == prefix
    key
  end

  # Get a non-paged array of objects
  def objects
    bucket_obj = Aws::S3::Bucket.new(name: bucket, client: s3_client)
    bucket_obj.objects( prefix: prefix)
  end

  # Get a list of of files in directory
  def list_files( dir = directory )
    Dir.entries(directory).tap do |files|
      files.delete('.')
      files.delete('..')
    end
  end

  # Sync an s3 path with the local directory
  # Returns an array of all the objects that have been newly downloaded
  def sync_down
    existing = list_files
    new_objects = []
    self.objects.each do |obj|
      filename = filename_from_key(obj.key)
      existing.delete( filename )
      file = directory + filename
      if !File.exists?(file)
        puts "Downloading file #{file} with key #{obj.key})"
        new_objects << s3_client.get_object({ bucket: bucket, key: obj.key }, target: directory + filename_from_key(obj.key) )
      end
    end

    existing.each do |file|
      puts "Deleting file #{file}"
      File.delete( directory + file )
    end

    # Return true if the directory changed
    (new_objects.count > 0) || (existing.count > 0)
  end

  def upload_dir(dir_path)
    list_files(dir_path).each do |file|
      upload(file_path: dir_path + '/' + file, sync: false)
    end
  end

  # Upload a file to the s3 bucket, and sync it back
  # down to the directory
  def upload(file_name: nil, file_handle: nil, file_path: nil, sync: true)
    if file_path
      key = key_from_filename(file_path)
      puts "Uploading #{file_path} to s3 with key #{key}"
      File.open(file_path, 'rb') do |file|
        s3_client.put_object(key: key, body: file, bucket: bucket )
      end
    else
      key = key_from_filename(file_name)
      s3_client.put_object(key: key, body: file_handle.read, bucket: bucket)
    end
    sync_down if sync
  end

  # Delete an object from the s3 bucket, and sync the
  # changes back down
  # Syncing down will delete the file locally
  def delete(file_name)
    key = key_from_filename(file_name)
    puts "Deleting object from s3 with key #{key}"
    Aws::S3::Object.new(key: key, bucket_name: bucket, client: s3_client).tap do |obj|
      obj.delete
      obj.wait_until_not_exists
    end
    sync_down
  end

end

