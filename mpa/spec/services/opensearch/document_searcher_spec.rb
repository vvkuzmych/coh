require 'rails_helper'

RSpec.describe Opensearch::DocumentSearcher do
  describe '#call' do
    context 'with simple query' do
      let(:service) { described_class.new(query: 'contract') }
      let(:opensearch_response) do
        {
          'hits' => {
            'total' => { 'value' => 2 },
            'hits' => [
              {
                '_id' => 'doc1',
                '_source' => {
                  'title' => 'Contract 1',
                  'content' => 'Content 1',
                  'status' => 'signed'
                },
                '_score' => 1.5,
                'highlight' => { 'title' => ['<em>Contract</em> 1'] }
              },
              {
                '_id' => 'doc2',
                '_source' => {
                  'title' => 'Contract 2',
                  'content' => 'Content 2',
                  'status' => 'uploaded'
                },
                '_score' => 1.2,
                'highlight' => {}
              }
            ]
          }
        }
      end

      before do
        allow(OPENSEARCH_CLIENT).to receive(:search).and_return(opensearch_response)
      end

      it 'returns total count' do
        result = service.call
        expect(result[:total]).to eq(2)
      end

      it 'returns formatted documents' do
        result = service.call

        expect(result[:documents]).to eq([
          {
            id: 'doc1',
            title: 'Contract 1',
            content: 'Content 1',
            status: 'signed',
            score: 1.5,
            highlight: { 'title' => ['<em>Contract</em> 1'] }
          },
          {
            id: 'doc2',
            title: 'Contract 2',
            content: 'Content 2',
            status: 'uploaded',
            score: 1.2,
            highlight: {}
          }
        ])
      end

      it 'builds correct search query' do
        service.call

        expect(OPENSEARCH_CLIENT).to have_received(:search).with(
          index: 'test_documents',
          body: hash_including(
            query: hash_including(
              bool: hash_including(
                must: array_including(
                  hash_including(
                    multi_match: hash_including(
                      query: 'contract',
                      fields: ['title^2', 'content'],
                      fuzziness: 'AUTO'
                    )
                  )
                )
              )
            )
          )
        )
      end
    end

    context 'with status filter' do
      let(:service) { described_class.new(query: 'test', status: 'signed') }

      before do
        allow(OPENSEARCH_CLIENT).to receive(:search).and_return({
          'hits' => { 'total' => { 'value' => 0 }, 'hits' => [] }
        })
      end

      it 'includes status filter in query' do
        service.call

        expect(OPENSEARCH_CLIENT).to have_received(:search).with(
          index: 'test_documents',
          body: hash_including(
            query: hash_including(
              bool: hash_including(
                filter: [{ term: { status: 'signed' } }]
              )
            )
          )
        )
      end
    end

    context 'with wildcard query' do
      let(:service) { described_class.new(query: '*') }

      before do
        allow(OPENSEARCH_CLIENT).to receive(:search).and_return({
          'hits' => { 'total' => { 'value' => 0 }, 'hits' => [] }
        })
      end

      it 'uses match_all query' do
        service.call

        expect(OPENSEARCH_CLIENT).to have_received(:search).with(
          index: 'test_documents',
          body: hash_including(
            query: hash_including(
              bool: hash_including(
                must: [{ match_all: {} }]
              )
            )
          )
        )
      end
    end

    context 'when OpenSearch error occurs' do
      before do
        allow(OPENSEARCH_CLIENT).to receive(:search)
          .and_raise(StandardError, 'Search failed')
        allow(Rails.logger).to receive(:error)
      end

      it 'raises SearchError' do
        service = described_class.new(query: 'test')

        expect { service.call }.to raise_error(
          Opensearch::DocumentSearcher::SearchError,
          'Search failed'
        )
      end

      it 'logs the error' do
        service = described_class.new(query: 'test')
        service.call rescue nil

        expect(Rails.logger).to have_received(:error)
          .with(/Error searching documents/)
      end
    end
  end
end
