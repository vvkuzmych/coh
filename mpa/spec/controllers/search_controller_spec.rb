require 'rails_helper'

RSpec.describe SearchController, type: :controller do
  describe 'GET #index' do
    it 'renders the search form' do
      get :index
      expect(response).to be_successful
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #search' do
    context 'with blank query' do
      it 'shows error message' do
        get :search, params: { q: '' }
        
        expect(assigns(:documents)).to eq([])
        expect(assigns(:total)).to eq(0)
        expect(flash[:alert]).to eq("Please enter a search query")
      end
    end

    context 'with valid query' do
      let(:search_result) do
        {
          total: 2,
          documents: [
            { id: '1', title: 'Doc 1', content: 'Content 1', status: 'signed', score: 1.0 },
            { id: '2', title: 'Doc 2', content: 'Content 2', status: 'uploaded', score: 0.8 }
          ]
        }
      end

      before do
        allow(Opensearch::DocumentSearcher).to receive(:new).and_return(
          double(call: search_result)
        )
      end

      it 'performs search and assigns results' do
        get :search, params: { q: 'contract' }
        
        expect(assigns(:documents)).to eq(search_result[:documents])
        expect(assigns(:total)).to eq(2)
        expect(flash[:success]).to eq("Found 2 document(s)")
      end

      it 'passes status filter to service' do
        searcher = instance_double(Opensearch::DocumentSearcher)
        allow(Opensearch::DocumentSearcher).to receive(:new)
          .with(query: 'contract', status: 'signed')
          .and_return(searcher)
        allow(searcher).to receive(:call).and_return(search_result)

        get :search, params: { q: 'contract', status: 'signed' }
        
        expect(searcher).to have_received(:call)
      end
    end

    context 'with no results' do
      before do
        allow(Opensearch::DocumentSearcher).to receive(:new).and_return(
          double(call: { total: 0, documents: [] })
        )
      end

      it 'shows no results message' do
        get :search, params: { q: 'nonexistent' }
        
        expect(assigns(:documents)).to eq([])
        expect(flash[:notice]).to eq("No documents found for 'nonexistent'")
      end
    end

    context 'when search error occurs' do
      before do
        searcher = instance_double(Opensearch::DocumentSearcher)
        allow(Opensearch::DocumentSearcher).to receive(:new).and_return(searcher)
        allow(searcher).to receive(:call)
          .and_raise(Opensearch::DocumentSearcher::SearchError, 'Connection failed')
        allow(Rails.logger).to receive(:error)
      end

      it 'handles error gracefully' do
        get :search, params: { q: 'test' }
        
        expect(assigns(:documents)).to eq([])
        expect(flash[:alert]).to match(/Search error/)
      end

      it 'logs the error' do
        get :search, params: { q: 'test' }
        
        expect(Rails.logger).to have_received(:error)
          .with(/Search error/)
      end
    end
  end
end
