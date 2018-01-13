# Class KeyServer
class KeyServer
  attr_accessor :keys, :free_keys
  attr_reader :deleted_keys

  # Constructor
  def initialize
    @keys = {}
    @free_keys = {}
    @deleted_keys = Set.new
    @mutex = Mutex.new
  end

  # Generates a random key
  def random_key(size)
    o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
    (0...size).map { o[rand(o.length)] }.join
  end

  # Generates keys
  def generate_keys(length, size)
    while @free_keys.size < length
      key = random_key(size)
      next if @free_keys.key?(key) || @deleted_keys.include?(key)

      @mutex.synchronize do
        @keys[key] = { :timestamp_d => Time.now.to_i }
        @free_keys[key] = true
      end
    end
    @free_keys.keys
  end

  # Retrieves a free key if available else returns nil
  def fetch_key
    return nil if @free_keys.empty?
    key = -1
    @mutex.synchronize do
      key = @free_keys.shift[0]
      @keys[key][:timestamp_b] = Time.now.to_i
    end
    key
  end

  # Unblocks the key with given id
  def unblock_key(key)
    return false unless @keys.key? key
    @mutex.synchronize do
      @keys[key][:timestamp_b] = nil
      @free_keys[key] = true
    end
  end

  # Deletes the key with given id
  def delete_key(key)
    return false unless @keys.key? key
    @mutex.synchronize do
      @keys.delete(key)
      @free_keys.delete(key)
    end
    @deleted_keys.add key
  end

  # Keeps alive the key with given id
  def keep_alive_key(key)
    return false unless @keys.key? key
    @mutex.synchronize do
      @keys[key][:timestamp_d] = Time.now.to_i
    end
  end

  # Checks if the key is expired w.r.t to the time limit passed as argument
  def expired?(key, time, type)
    return false if !@keys.key?(key) || @keys[key][type].nil?
    Time.now.to_i - @keys[key][type] > time
  end

  def cleanup
    @keys.each do |k, _v|
      if expired?(k, 300, :timestamp_d)
        delete_key(k)
      elsif expired?(k, 60, :timestamp_b)
        unblock_key(k)
      end
    end
  end
end
