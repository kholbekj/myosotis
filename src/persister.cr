require "openssl"

class Persister
  property :private_key

  def initialize(@file_name : String)
    @private_key = "spicy"
  end

  def encrypted_list(hash)
    hash.map do |k, v|
      pkey = "#{@private_key}#{k}"
      data = aes_encrypt(v, pkey)
    end
  end

  def aes_encrypt(data, key)
    cipher = OpenSSL::Cipher.new("aes-128-cbc")
    cipher.encrypt
    cipher.key = key
    io = IO::Memory.new
    io.write(cipher.update(data))
    io.write(cipher.final)
    io.to_s.bytes.map(&.to_s(16)).join(":")
  end

  def aes_decrypt(byte_string, key)
    byte_array = byte_string.split(":").map(&.to_i(16).to_u8)
    byte_slice = Bytes.new(byte_array.size)
    byte_slice.copy_from(byte_array.to_unsafe, byte_array.size)

    cipher = OpenSSL::Cipher.new("aes-128-cbc")
    cipher.decrypt
    cipher.key = key

    io = IO::Memory.new
    io.write(cipher.update(byte_slice))
    io.write(cipher.final)
    io.to_s
  end

  def persist(q_and_a_hash)
    list = encrypted_list(q_and_a_hash)
    File.write(file_name, list.to_json)
  end

  def read_answer(file, question)
    json = JSON.parse(File.read(file))
    encrypted_strings = json.as_a.map(&.as_s)
    encrypted_strings.each do |cipher_text|
      answer = aes_decrypt(cipher_text, "#{private_key}#{question}")
      return answer
    rescue error
      next
    end
    "No answer found!"
  end

  def file_name
    @file_name
  end
end
