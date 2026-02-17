require 'rails_helper'

RSpec.describe Opensearch::DocumentFetcher do
  let(:document_id) { 'test123' }
  let(:service) { described_class.new(document_id) }

  describe '#call' do
    context 'when document exists' do
      let(:opensearch_response) do
        {
          '_id' => 'test123',
          '_source' => {
            'title' => 'Test Document',
            'content' => 'Test content',
            'status' => 'signed'
          },
          '_score' => 1.0
        }
      end

      before do
        allow(OPENSEARCH_CLIENT).to receive(:get).and_return(opensearch_response)
      end

      it 'returns formatted document' do
        result = service.call

        expect(result).to eq({
          id: 'test123',
          title: 'Test Document',
          content: 'Test content',
          status: 'signed',
          score: 1.0
        })
      end

      it 'calls OpenSearch with correct params' do
        service.call

        expect(OPENSEARCH_CLIENT).to have_received(:get).with(
          index: 'test_documents',
          id: 'test123'
        )
      end
    end

    context 'when document not found' do
      before do
        allow(OPENSEARCH_CLIENT).to receive(:get)
          .and_raise(OpenSearch::Transport::Transport::Errors::NotFound)
      end

      it 'raises DocumentNotFoundError' do
        expect { service.call }.to raise_error(
          Opensearch::DocumentFetcher::DocumentNotFoundError,
          'Document with ID test123 not found'
        )
      end
    end

    context 'when OpenSearch error occurs' do
      before do
        allow(OPENSEARCH_CLIENT).to receive(:get)
          .and_raise(StandardError, 'Connection failed')
        allow(Rails.logger).to receive(:error)
      end

      it 'raises DocumentFetchError' do
        expect { service.call }.to raise_error(
          Opensearch::DocumentFetcher::DocumentFetchError,
          'Connection failed'
        )
      end

      it 'logs the error' do
        service.call rescue nil

        expect(Rails.logger).to have_received(:error)
          .with(/Error fetching document test123/)
      end
    end
  end
end
