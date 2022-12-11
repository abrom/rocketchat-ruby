# frozen_string_literal: true

require 'spec_helper'

describe RocketChat::RequestHelper do
  describe '#create_request' do
    let(:including_class) { Class.new { include RocketChat::RequestHelper } }
    let(:instance) { including_class.new }

    describe 'URI-encoding' do
      subject(:req) { instance.send(:create_request, '/api/endpoint', body: request_params) }

      context 'when encoding multiple, simple parameters' do
        let(:request_params) { { foo: 1, bar: 'string' } }

        it 'URI-encodes each of them into the query string' do
          expect(req.path).to end_with('?foo=1&bar=string')
        end
      end

      context 'when encoding parameters containing spaces, ampersands, and other specials' do
        let(:request_params) { { foo: 'This & That', bar: '+ Plusses, too, with 98% success!' } }

        it 'URI-encodes them properly into the query string' do
          expect(req.path).to end_with('?foo=This+%26+That&bar=%2B+Plusses%2C+too%2C+with+98%25+success%21')
        end
      end

      context 'when encoding empty strings and nil parameters' do
        let(:request_params) { { empty: '', null: nil } }

        it 'preserves empty strings but drops nils from the query string' do
          expect(req.path).to end_with('?empty=')
        end
      end
    end
  end
end
