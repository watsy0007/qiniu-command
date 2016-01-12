require 'securerandom'

class Qiniu
  def initialize(user, pass, bucket = nil)
    @bucket = bucket
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

  def upload_path(path)
    index = 1
    #TODO 1. 收集key url
    #TODO 2. 错误提示收集，报警
    Dir.foreach(path) do |file_name|
      if file_name != '.' && file_name != '..'
        file_path = "#{path}/#{file_name}"
        key = "#{SecureRandom.uuid}.#{index}.#{file_name.split('.').last}"
        index += 1
        upload(key, file_path.gsub(' ', '\ '))
      end
    end
  end

  def stat(key, &block)
    exec('stat', [@bucket, key], &block)
  end

  private

  def exec(command, args = nil)
   args = args.nil? ? [] : args
   command = "./qrsctl #{command} #{args.join(' ')}"
   puts command
   IO.popen(command) do |f|
     yield(f.read) if block_given?
   end
  end
end

qiniu = Qiniu.new('watsy0007@gmail.com', 'watsy310', 'markdowntmp')

#qiniu.upload('1111', '/Users/watsy/Desktop/0F5074FB-8605-47F9-921B-004FB93FE737.png') do |f|
#    puts f
#end

qiniu.upload_path("/Users/watsy/Desktop/亿采网A+ BP\ 2016.1")
