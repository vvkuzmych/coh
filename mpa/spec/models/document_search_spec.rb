# Example RSpec tests for Document search
require 'rails_helper'

RSpec.describe "Document Search", type: :model do
  let(:account) { Account.first || create(:account) }
  let(:user) { User.first || create(:user) }

  before(:all) do
    skip "OpenSearch not available" unless defined?(OPENSEARCH_CLIENT)
  end

  describe ".search" do
    before do
      # Create test documents
      @doc1 = Document.create!(
        title: "Important Contract Agreement",
        content: "This is a legal contract document about payment terms",
        status: "published",
        account: account,
        created_by: user
      )

      @doc2 = Document.create!(
        title: "Project Proposal Draft",
        content: "Draft proposal for new software project",
        status: "draft",
        account: account,
        created_by: user
      )

      @doc3 = Document.create!(
        title: "Meeting Notes",
        content: "Notes from contract negotiation meeting",
        status: "published",
        account: account,
        created_by: user
      )

      # Wait for indexing
      sleep 1
      Document.refresh_index!
    end

    after do
      [@doc1, @doc2, @doc3].each(&:destroy)
    end

    it "finds documents by title" do
      results = Document.search({
        match: { title: "Contract" }
      })

      expect(results).to include(@doc1)
      expect(results).not_to include(@doc2)
    end

    it "finds documents by content" do
      results = Document.search({
        match: { content: "contract" }
      })

      expect(results).to include(@doc1, @doc3)
      expect(results).not_to include(@doc2)
    end

    it "searches across multiple fields" do
      results = Document.search({
        multi_match: {
          query: "contract",
          fields: ['title', 'content']
        }
      })

      expect(results).to include(@doc1, @doc3)
    end

    it "filters by status" do
      results = Document.search({
        bool: {
          must: [
            { match: { content: "contract" } }
          ],
          filter: [
            { term: { status: "published" } }
          ]
        }
      })

      expect(results).to include(@doc1, @doc3)
      expect(results).not_to include(@doc2)
    end

    it "supports pagination" do
      results = Document.search(
        { match_all: {} },
        size: 2,
        from: 0
      )

      expect(results.size).to eq(2)
    end

    it "returns records with scores" do
      results = Document.search(
        { match: { title: "Contract" } },
        include_score: true
      )

      expect(results.first).to have_key(:record)
      expect(results.first).to have_key(:score)
      expect(results.first[:score]).to be > 0
    end
  end

  describe "#index_document" do
    it "indexes document after creation" do
      doc = Document.create!(
        title: "New Document",
        content: "Test content",
        status: "draft",
        account: account,
        created_by: user
      )

      sleep 1
      Document.refresh_index!

      results = Document.search({ match: { title: "New Document" } })
      expect(results).to include(doc)

      doc.destroy
    end

    it "updates index after document update" do
      doc = Document.create!(
        title: "Original Title",
        content: "Original content",
        status: "draft",
        account: account,
        created_by: user
      )

      sleep 1
      Document.refresh_index!

      doc.update!(title: "Updated Title")

      sleep 1
      Document.refresh_index!

      results = Document.search({ match: { title: "Updated" } })
      expect(results).to include(doc)

      doc.destroy
    end
  end

  describe "#remove_document" do
    it "removes document from index after deletion" do
      doc = Document.create!(
        title: "To Be Deleted",
        content: "This will be deleted",
        status: "draft",
        account: account,
        created_by: user
      )

      sleep 1
      Document.refresh_index!

      doc_id = doc.id
      doc.destroy

      sleep 1
      Document.refresh_index!

      results = Document.search({ match: { title: "Deleted" } })
      expect(results).to be_empty
    end
  end
end
