require 'spec_helper'

describe RocketChat::Messages::Channel do
  include_examples 'room_behavior', 'c', query: true
end
