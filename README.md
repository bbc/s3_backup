# s3_backup

Backup a directory to s3 to allow easy syncing between instances.

## Why would you use this?

Sometime you want to use s3 to backup a directory on an instance,
and sync that directory across instances. There are lots of ways to
keep directories in sync across instances, but by far the simplest is 
to keep the s3 bucket up todate and sync the contents down to the 
instances as needed.

We use this gem alongside gem-in-a-box in order to keep our gems
consistent across instances.

## How does it work?

First, initialize s3_backup:

    s3b = S3Backup.new(
      region: 'eu-west-1',
      bucket: 'my-storage-bucket',
      prefix: '/some/bucket/path/',
      directory: '/path/to/sync/
      )

Instead of copying a file into your directory, just upload the file
directly to s3:

    s3.upload(file_path: '/path/to/new/file')

This uploads the new file to s3, and syncs it down to the local
directory.

The other instances should periodically call syncronize with s3:

    s3.sync_down

This will download the new file. sync_down returns true when it makes
a change to the local directory.

You can also delete files by doing:

    s3.delete('filename')

This deletes the file from s3, and syncs down the directory (deleting
the local copy of the file in the process).

## Limitations

This library only works with flat directories for now. Although it
should be fairly easy to support syncing directory structures.

## License

s3_backup is available to everyone under the terms of the MIT open 
source licence. Take a look at the LICENSE file in the code.

Copyright (c) 2015 BBC
