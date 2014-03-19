# encoding: utf-8

require 'bundler'
Bundler.require

require 'yaml'


config = YAML.load_file 'config.yml'

Backup::Model.new(:eccube_db_backup, 'EC-CUBE database backup') do

  split_int_chunks_of 250

  database MySQL do |db|
    db.name              = config["mysql"]["database"]
    db.username          = config["mysql"]["username"]
    db.password          = config["mysql"]["password"]
    db.host              = config["mysql"]["host"]
    db.port              = config["mysql"]["port"]
    db.socket            = config["mysql"]["socket"]
    db.additional_option = config["mysql"]["additional_option"]
  end

  store_with S3 do |s3|
    s3.access_key_id
    s3.secret_access_key
    s3.region
    s3.bucket
    s3.path
    s3.keep
  end

  compress_with Gzip

  notify_by HttpPost do |mail|
    post.on_success           = true
    post.on_warning           = true
    post.on_failure           = true
    post.uri                  = config["notify"]["endpoint"]
  end

end
