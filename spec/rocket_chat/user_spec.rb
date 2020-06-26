# frozen_string_literal: true

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

  describe '#rooms' do
    it { expect(user.rooms).to eq [] }

    context 'when rooms hash is available' do
      let(:user) { described_class.new data_with_rooms }
      let(:data_with_rooms) do
        data.merge(
          'rooms' => [
            { '_id' => 'sub1.id', 'rid' => 'room1.id', 'name' => 'Room 1 name', 't' => 'c' },
            { '_id' => 'sub2.id', 'rid' => 'room2.id', 'name' => 'Room 2 name', 't' => 'd' },
            { '_id' => 'sub3.id', 'rid' => 'room3.id', 'name' => 'Room 3 name', 't' => 'p' }
          ]
        )
      end

      it 'returns an array of rooms' do
        expect(user.rooms.length).to eq 3
        expect(user.rooms.map(&:class)).to eq [RocketChat::Room, RocketChat::Room, RocketChat::Room]
        expect(user.rooms.map(&:id)).to eq %w[room1.id room2.id room3.id]
        expect(user.rooms.map(&:type)).to eq %w[public IM private]
      end
    end
  end
end
