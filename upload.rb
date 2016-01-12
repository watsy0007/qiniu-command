require 'securerandom'

class Qiniu
  def initialize(user, pass, bucket = nil, domain = nil, prefix = nil, uuid_key = nil)
    @bucket = bucket
    @domain = domain
    @prefix = prefix
    @uuid_key = uuid_key.nil? ? SecureRandom.uuid : uuid_key
    exec('login', [user, pass])
  end

  def buckets(&block)
    exec('buckets', &block)
  end

  def upload(key, file, &block)
    exec('put -c', [@bucket, key, file]) do |f|
      return puts('upload error') if f.nil?
      stat(key, &block)
    end
  end

  def upload_path(path, &block)
    index = 1
    #TODO 1. 收集key url
    #TODO 2. 错误提示收集，报警
    urls = []
    Dir.foreach(path) do |file_name|
      if file_name != '.' && file_name != '..'
        file_path = "#{path}/#{file_name}".gsub(' ', '\ ')
        key = "#{@prefix}/#{@uuid_key}.#{index}.#{file_name.split('.').last}"
        index += 1
        upload(key, file_path) do |f|
          if f.nil?
           puts "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx errors"
           return
          end
          urls << "#{@domain}/#{key}"
        end
      end
    end
    yield(urls) if block_given?
    urls
  end

  def stat(key, &block)
    exec('stat', [@bucket, key], &block)
  end

  private

  def exec(command, args = nil)
   args = args.nil? ? [] : args
   command = "./qrsctl #{command} #{args.join(' ')}"
   #puts command
   IO.popen(command) do |f|
     yield(f.read) if block_given?
   end
  end
end

qiniu = Qiniu.new(ARGV[0], ARGV[1], ARGV[2], ARGV[3], ARGV[4], ARGV[5])

qiniu.upload_path("/Users/watsy/Desktop/亿采网A+ BP\ 2016.1") do |urls|
  puts urls
end
