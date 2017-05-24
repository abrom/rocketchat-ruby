require 'spec_helper'

describe RocketChat::Messages::Channel do
  include_examples 'room_behavior', room_type: 'c', query: true
end
