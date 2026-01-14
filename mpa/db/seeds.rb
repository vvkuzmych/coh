# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Starting database seeding..."

# Clear existing data (in reverse order of dependencies)
puts "🧹 Clearing existing data..."
Document.destroy_all
UserManagement::User.destroy_all
Account.destroy_all

puts "✅ Data cleared"

# Create 30 Accounts
puts "📊 Creating 30 accounts..."
accounts = []
30.times do |i|
  accounts << Account.create!(
    name: "Account #{i + 1}"
  )
end
puts "✅ Created #{accounts.count} accounts"

# Create 30 Users (distributed across accounts with different roles)
puts "👥 Creating 30 users..."
roles = [ :guest, :member, :admin, :super_admin ]
first_names = %w[Alice Bob Carol Dave Emma Frank Grace Henry Ivy Jack Kelly Leo Maria Nick Olivia Paul Quinn Rita Sam Tina Uma Victor Wendy Xavier Yara Zoe Alex Blake Casey Dana]
last_names = %w[Smith Johnson Williams Brown Jones Garcia Miller Davis Rodriguez Martinez Hernandez Lopez Gonzalez Wilson Anderson Thomas Taylor Moore Jackson Martin Lee Perez Thompson White Harris Sanchez Clark Ramirez Lewis Robinson Walker Young Allen]

users = []
30.times do |i|
  users << UserManagement::User.create!(
    email: "user#{i + 1}@example.com",
    first_name: first_names[i % first_names.length],
    last_name: last_names[i % last_names.length],
    account_id: accounts[i % accounts.length].id,
    role: roles[i % roles.length]
  )
end
puts "✅ Created #{users.count} users"

# Create 300+ documents for each status (1200+ total)
puts "📄 Creating documents..."

statuses = [ "uploaded", "reviewed", "signed", "archived" ]
document_titles = [
  "Resume", "Cover Letter", "Portfolio", "Reference Letter", "Transcript",
  "Certificate", "Work Sample", "Project Documentation", "Skills Assessment",
  "Background Check", "ID Verification", "Employment Agreement", "NDA",
  "Tax Forms", "Benefits Enrollment", "Emergency Contact Form",
  "Code Sample", "Design Portfolio", "Writing Sample", "Presentation Deck"
]

content_samples = [
  "This document contains important information about the candidate's qualifications and experience.",
  "Detailed overview of professional background and achievements in the field.",
  "Comprehensive analysis of skills, competencies, and career progression.",
  "Supporting documentation for employment verification and reference checks.",
  "Technical documentation demonstrating proficiency in relevant technologies.",
  "Creative work showcasing design thinking and problem-solving abilities.",
  "Written communication samples highlighting clarity and analytical thinking.",
  "Project deliverables and outcomes from previous professional engagements.",
  "Certifications and training records validating expertise and qualifications.",
  "Legal and compliance documentation required for employment processing."
]

documents_created = 0
statuses.each do |status|
  puts "  Creating documents with status: #{status}..."
  300.times do
    user = users.sample
    Document.create!(
      title: "#{document_titles.sample} - #{status.capitalize}",
      content: content_samples.sample,
      user_id: user.id,
      status: status
    )
    documents_created += 1
  end
end

puts "✅ Created #{documents_created} documents across all statuses"

# Print summary statistics
puts "\n📈 Seeding Summary:"
puts "=" * 50
puts "Accounts created:        #{Account.count}"
puts "Users created:           #{UserManagement::User.count}"
puts "Documents created:       #{Document.count}"
puts ""
puts "Documents by status:"
puts "  - Uploaded:            #{Document.where(status: "uploaded").count}"
puts "  - Reviewed:            #{Document.where(status: "reviewed").count}"
puts "  - Signed:              #{Document.where(status: "signed").count}"
puts "  - Archived:            #{Document.where(status: "archived").count}"
puts ""
puts "Users by role:"
puts "  - Guest:               #{UserManagement::User.where(role: :guest).count}"
puts "  - Member:              #{UserManagement::User.where(role: :member).count}"
puts "  - Admin:               #{UserManagement::User.where(role: :admin).count}"
puts "  - Super Admin:         #{UserManagement::User.where(role: :super_admin).count}"
puts "=" * 50
puts "🎉 Database seeding completed successfully!"
