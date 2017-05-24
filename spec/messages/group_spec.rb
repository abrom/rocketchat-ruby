require 'spec_helper'

describe RocketChat::Messages::Group do
  include_examples 'room_behavior', room_type: 'p', query: false
end
