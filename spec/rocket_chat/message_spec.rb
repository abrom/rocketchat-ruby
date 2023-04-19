# frozen_string_literal: true

require 'spec_helper'

describe RocketChat::Message do
  let(:data) do
    {
      'alias' => 'an alias',
      'msg' => 'This is a test!',
      'parseUrls' => true,
      'groupable' => false,
      'ts' => '2016-12-14T20:56:05.117Z',
      'u' => {
        '_id' => 'y65tAmHs93aDChMWu',
        'username' => 'graywolf336'
      },
      'rid' => 'GENERAL',
      '_updatedAt' => '2016-12-14T20:57:05.119Z',
      '_id' => 'jC9chsFddTvsbFQG7',
      'tmid' => 'gcGai9bRREqokjyPc'
    }
  end
  let(:message) { described_class.new data }

  describe '#id' do
    it { expect(message.id).to eq 'jC9chsFddTvsbFQG7' }
  end

  describe '#timestamp' do
    it { expect(message.timestamp).to eq Time.parse('2016-12-14T20:56:05.117Z') }
  end

  describe '#updated_at' do
    it { expect(message.updated_at).to eq Time.parse('2016-12-14T20:57:05.119Z') }
  end

  describe '#room_id' do
    it { expect(message.room_id).to eq 'GENERAL' }
  end

  describe '#user' do
    it { expect(message.user).to be_a RocketChat::User }
    it { expect(message.user.id).to eq 'y65tAmHs93aDChMWu' }
    it { expect(message.user.username).to eq 'graywolf336' }
  end

  describe '#message' do
    it { expect(message.message).to eq 'This is a test!' }
  end

  describe '#alias' do
    it { expect(message.alias).to eq 'an alias' }
  end

  describe '#parse_urls' do
    it { expect(message.parse_urls).to be true }
  end

  describe '#groupable' do
    it { expect(message.groupable).to be false }
  end

  describe '#tmid' do
    it { expect(message.tmid).to be 'gcGai9bRREqokjyPc' }
  end
end
