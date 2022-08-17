require 'spec_helper'

describe PGP::Encryptor do
  include KeysHelper

  let(:private_key_path)  { Fixtures_Path.join('private_key.asc').to_s }
  let(:public_key_path)   { Fixtures_Path.join('public_key.asc').to_s }

  let(:encryptor) { PGP::Encryptor.new }
  let(:string) { "FooBar" }

  before { remove_all_keys }

  describe '#initialize' do
    let(:encryptor) { PGP::Encryptor.new(File.read public_key_path) }

    it "should accept public key(s) as an argument" do
      encrypted_string = encryptor.encrypt(string, "some filename.txt")

      expect(PGP::RubyDecryptor.decrypt(encrypted_string, private_key_path)).to eq(string)
    end
  end

  describe '#encrypt' do
    after {
      File.delete("some filename.txt") if File.exist?("some filename.txt")
    }

    context 'When the Public Key is from a file' do
      before {
        encryptor.add_keys_from_file(public_key_path)
      }

      it "it's encrypted string should be decryptable. durr" do
        encrypted_string = encryptor.encrypt(string, "some filename.txt")

        expect(File.read("some filename.txt")).to eq(encrypted_string)
        expect(PGP::RubyDecryptor.decrypt(encrypted_string, private_key_path)).to eq(string)
      end

      it "should not require that a filename be specified" do
        encrypted_string = encryptor.encrypt(string)

        expect(PGP::RubyDecryptor.decrypt(encrypted_string, private_key_path)).to eq(string)
      end
    end # context 'When the Public Key is from a file'

    context 'When the Public Key has been read in to memory' do
      before {
        encryptor.add_keys(File.read public_key_path)
      }

      it "it's encrypted string should be decryptable. durr" do
        encrypted_string = encryptor.encrypt(string, "some filename.txt")

        expect(File.read("some filename.txt")).to eq(encrypted_string)
        expect(PGP::RubyDecryptor.decrypt(encrypted_string, private_key_path)).to eq(string)
      end

      it "should not require that a filename be specified" do
        encrypted_string = encryptor.encrypt(string)

        expect(PGP::RubyDecryptor.decrypt(encrypted_string, private_key_path)).to eq(string)
      end
    end # context 'When the Public Key has been read in to memory'

  end # describe '#encrypt'

  describe '#encrypt_file' do
    let(:file_path) { Fixtures_Path.join('unencrypted_file.txt') }
    let(:contents) { File.read(file_path) }

    before {
      encryptor.add_keys(File.read public_key_path)
    }

    pending "should have an encryptStream method to avoid memory bloat"

    it "should encrypt a file" do
      encrypted_file = encryptor.encrypt_file(file_path)

      expect(PGP::RubyDecryptor.decrypt(encrypted_file, private_key_path)).to eq(contents)
    end
  end # describe '#encrypt_file'

end
