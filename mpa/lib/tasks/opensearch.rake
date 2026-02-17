# OpenSearch Rake Tasks
#
# Usage:
#   rails opensearch:create_indices
#   rails opensearch:reindex
#   rails opensearch:reset

namespace :opensearch do
  desc "Check OpenSearch connection"
  task status: :environment do
    unless defined?(OPENSEARCH_CLIENT)
      puts "❌ OpenSearch client not initialized"
      puts "   Add 'opensearch-ruby' gem and uncomment config/initializers/opensearch.rb"
      exit 1
    end

    begin
      info = OPENSEARCH_CLIENT.info
      health = OPENSEARCH_CLIENT.cluster.health
      
      puts "✅ OpenSearch Status:"
      puts "   Distribution: #{info['version']['distribution']}"
      puts "   Version: #{info['version']['number']}"
      puts "   Cluster: #{info['cluster_name']}"
      puts "   Health: #{health['status']}"
      puts "   Nodes: #{health['number_of_nodes']}"
    rescue => e
      puts "❌ Connection failed: #{e.message}"
      exit 1
    end
  end

  desc "List all indices"
  task list_indices: :environment do
    unless defined?(OPENSEARCH_CLIENT)
      puts "❌ OpenSearch not available"
      exit 1
    end

    indices = OPENSEARCH_CLIENT.cat.indices(format: 'json')
    
    if indices.empty?
      puts "No indices found"
    else
      puts "Indices:"
      indices.each do |idx|
        puts "  - #{idx['index']} (docs: #{idx['docs.count']}, size: #{idx['store.size']})"
      end
    end
  end

  desc "Create all OpenSearch indices"
  task create_indices: :environment do
    models = [Document] # Add other searchable models here
    
    models.each do |model|
      if model.respond_to?(:create_index!)
        model.create_index!
        puts "✅ Created index for #{model.name}"
      end
    end
  end

  desc "Delete all OpenSearch indices"
  task delete_indices: :environment do
    models = [Document] # Add other searchable models here
    
    models.each do |model|
      if model.respond_to?(:delete_index!)
        model.delete_index!
        puts "✅ Deleted index for #{model.name}"
      end
    end
  end

  desc "Reindex all documents"
  task reindex: :environment do
    models = [Document] # Add other searchable models here
    
    models.each do |model|
      if model.respond_to?(:reindex_all!)
        count = model.reindex_all!
        puts "✅ Reindexed #{count} #{model.name.pluralize}"
      end
    end
  end

  desc "Reset OpenSearch (delete + create + reindex)"
  task reset: :environment do
    puts "🔄 Resetting OpenSearch..."
    puts
    
    Rake::Task['opensearch:delete_indices'].invoke
    puts
    Rake::Task['opensearch:create_indices'].invoke
    puts
    Rake::Task['opensearch:reindex'].invoke
    puts
    puts "✅ Reset complete!"
  end

  desc "Test search functionality"
  task test_search: :environment do
    unless Document.respond_to?(:search)
      puts "❌ Document model doesn't include Searchable concern"
      exit 1
    end

    puts "Testing search functionality..."
    puts
    
    # Create test document
    doc = Document.create!(
      title: "Test Document for OpenSearch",
      content: "This is a test document content",
      status: "draft",
      account_id: Account.first&.id || 1,
      created_by_id: User.first&.id || 1
    )
    
    puts "✅ Created test document ##{doc.id}"
    sleep 1 # Wait for indexing
    
    # Search
    results = Document.search({
      match: { title: "OpenSearch" }
    })
    
    if results.any?
      puts "✅ Search works! Found #{results.count} result(s)"
      results.each do |result|
        puts "   - #{result.title}"
      end
    else
      puts "⚠️  No results found (might need to wait for indexing)"
    end
    
    # Cleanup
    doc.destroy
    puts "✅ Cleaned up test document"
  end
end
