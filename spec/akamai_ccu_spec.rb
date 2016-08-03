require 'spec_helper'

describe AkamaiCCU do
  MOCK_URI = URI('http://private-anon-74329c9bea-akamaiopen2purgeccuv2production.apiary-mock.com')

  it 'has a version number' do
    expect(AkamaiCCU::VERSION).not_to be nil
  end

  let(:base_uri) { MOCK_URI }
  let(:access_token) { 'accesstoken' }
  let(:client_token) { 'clienttoken' }
  let(:client_secret) { 'clientsecret' }

  subject {
    described_class.new(
      base_uri: base_uri,
      access_token: access_token,
      client_token: client_token,
      client_secret: client_secret,
    )
  }

  shared_examples_for 'purge method' do |name: , action: , type: |
    let!(:result) do
      params = opts.map {|k, v| '-' + [k, v].map{|s| s.to_s.gsub(/\W/, '') }.join('_') }.join
      VCR.use_cassette "ccu-#{name}#{params}" do
        subject.public_send(name, *objects, opts)
      end
    end

    shared_examples 'basics' do
      it 'requests only once' do
        expect(WebMock).to have_requested(:post, Addressable::Template.new('http://{host}/ccu/v2/queues{/queue}')).once
      end

      it 'requests with correct action, type, and objects' do
        expect(WebMock).to have_requested(:post, Addressable::Template.new('http://{host}/ccu/v2/queues{/queue}')).with {|req|
          expect(req.body).to include_json(objects: objects, action: action, type: type)
        }
      end

      it 'requests with a signature' do
        expect(WebMock).to have_requested(:post, Addressable::Template.new('http://{host}/ccu/v2/queues{/queue}')).with {|req|
          expect(req.headers).to include('Authorization' => include("client_token=#{client_token}").and(include("access_token=#{access_token}")))
        }
      end
    end

    context 'when queue name is not specified' do
      let(:opts) { {} }

      include_examples 'basics'

      it 'posts a purge request in the default queue' do
        expect(WebMock).to have_requested(:post, Addressable::Template.new('http://{host}/ccu/v2/queues/default'))
      end
    end

    context 'when queue name is specified' do
      let(:opts) { {queue: 'emergency'} }

      include_examples 'basics'

      it 'posts a purge request in the specified queue' do
        expect(WebMock).to have_requested(:post, Addressable::Template.new('http://{host}/ccu/v2/queues/emergency'))
      end
    end

    context 'when domain is specified' do
      let(:opts) { {domain: 'staging'} }

      include_examples 'basics'

      it 'sets the domain in a request' do
        expect(WebMock).to have_requested(:post, Addressable::Template.new('http://{host}/ccu/v2/queues{/queue}')).with {|req|
          expect(req.body).to include_json(domain: 'staging')
        }
      end
    end
  end

  describe '#invalidate' do
    it_behaves_like 'purge method', name: 'invalidate', action: 'invalidate', type: 'arl' do
      let(:objects) { ['https://example.com/', 'https://example.net/'] }
    end
  end

  describe '#invalidate_cpcode' do
    it_behaves_like 'purge method', name: 'invalidate_cpcode', action: 'invalidate', type: 'cpcode' do
      let(:objects) { [10000, 20000] }
    end
  end

  describe '#remove' do
    it_behaves_like 'purge method', name: 'remove', action: 'remove', type: 'arl' do
      let(:objects) { ['https://example.com/', 'https://example.net/'] }
    end
  end

  describe '#remove_cpcode' do
    it_behaves_like 'purge method', name: 'remove_cpcode', action: 'remove', type: 'cpcode' do
      let(:objects) { [10000, 20000] }
    end
  end

end
