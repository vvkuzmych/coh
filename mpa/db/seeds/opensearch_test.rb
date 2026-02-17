# Simple OpenSearch test data
puts "🌱 Creating simple test documents..."

# Create 5 simple documents
documents = [
  { title: "Contract Agreement", content: "This is a contract document about business agreement and payment terms.", status: :signed },
  { title: "Project Proposal", content: "Proposal for software development project with timeline and budget.", status: :uploaded },
  { title: "Meeting Notes", content: "Notes from the quarterly review meeting discussing goals and metrics.", status: :reviewed },
  { title: "Technical Documentation", content: "API documentation for payment gateway integration with examples.", status: :signed },
  { title: "Financial Report", content: "Annual financial report with revenue analysis and profit margins.", status: :archived }
]

count = 0
documents.each do |data|
  Document.create!(
    title: data[:title],
    content: data[:content],
    status: data[:status],
    user_id: 1
  )
  count += 1
  print "."
end

puts "\n✅ Created #{count} test documents"
puts "\nDocument statuses:"
puts "  Signed: #{Document.status_signed.count}"
puts "  Uploaded: #{Document.status_uploaded.count}"
puts "  Reviewed: #{Document.status_reviewed.count}"
puts "  Archived: #{Document.status_archived.count}"
puts "\nNow run: rails opensearch:reset"
