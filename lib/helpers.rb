def encrypt(plaintext="")
  aes = OpenSSL::Cipher.new("AES-256-CBC")
  aes.encrypt
  aes.key = Digest::SHA2.digest(ENV["SECRET_KEY"] || "Srljxgd7KfT2InjUx9mI")
  (aes.update(plaintext) + aes.final).unpack("H*")[0]
end

def decrypt(enc_str)
  aes = OpenSSL::Cipher.new("AES-256-CBC")
  aes.decrypt
  aes.key = Digest::SHA2.digest(ENV["SECRET_KEY"] || "Srljxgd7KfT2InjUx9mI")
  aes.update([enc_str].pack("H*")) + aes.final
end