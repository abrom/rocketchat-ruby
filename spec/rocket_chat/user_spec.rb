require 'spec_helper'

describe RocketChat::User do
  let(:data) do
    {
      '_id' => 'nSYqWzZ4GsKTX4dyK',
      'createdAt' => '2016-12-07T15:47:46.861Z',
      'services' => {
        'password' => {
          'bcrypt' => '569d6dec47b11596d0375d27b044dcd28b4695eb'
        },
        'email' => {
          'verificationTokens' => [
            {
              'token' => 'fe8206790c72841f105b9733cfc49d4085ce15e8',
              'address' => 'example@example.com',
              'when' => '2016-12-07T15:47:46.930Z'
            }
          ]
        },
        'resume' => {
          'loginTokens' => [
            {
              'when' => '2016-12-07T15:47:47.334Z',
              'hashedToken' => '336f635ba4b28036a35495ae0d45968e81311dd4'
            }
          ]
        }
      },
      'emails' => [
        {
          'address' => 'example@example.com',
          'verified' => true
        }
      ],
      'type' => 'user',
      'status' => 'offline',
      'active' => true,
      'roles' => [
        'user'
      ],
      'name' => 'Example User',
      'lastLogin' => '2016-12-08T00:22:15.167Z',
      'statusConnection' => 'online',
      'utcOffset' => 10,
      'username' => 'example'
    }
  end
  let(:user) { described_class.new data }

  describe '#id' do
    it { expect(user.id).to eq 'nSYqWzZ4GsKTX4dyK' }
  end

  describe '#name' do
    it { expect(user.name).to eq 'Example User' }
  end

  describe '#emails' do
    it do
      expect(user.emails).to eq(
        [{
          'address' => 'example@example.com',
          'verified' => true
        }]
      )
    end
  end

  describe '#email' do
    it { expect(user.email).to eq 'example@example.com' }
  end

  describe '#email_verified?' do
    it { expect(user.email_verified?).to eq true }
  end

  describe '#status' do
    it { expect(user.status).to eq 'offline' }
  end

  describe '#status_connection' do
    it { expect(user.status_connection).to eq 'online' }
  end

  describe '#username' do
    it { expect(user.username).to eq 'example' }
  end

  describe '#utc_offset' do
    it { expect(user.utc_offset).to eq 10 }
  end

  describe '#active?' do
    it { expect(user.active?).to eq true }
  end

  describe '#roles' do
    it { expect(user.roles).to eq ['user'] }
  end
end
