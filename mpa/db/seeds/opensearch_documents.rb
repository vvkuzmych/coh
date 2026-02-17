# OpenSearch Test Data Seeds
# 
# Usage: rails runner db/seeds/opensearch_documents.rb

puts "🌱 Creating test documents for OpenSearch..."

# Ensure we have account
account = Account.first || Account.create!(name: "Test OpenSearch Account")
user_id = 1  # Default user ID

# Sample documents data
documents_data = [
  {
    title: "Employment Contract Agreement",
    content: "This employment contract agreement is made between the employer and employee. The terms include salary, working hours, benefits, and termination conditions. Both parties agree to the terms specified in this document.",
    status: "signed"
  },
  {
    title: "Software License Agreement",
    content: "This software license grants the user the right to use the software under specific conditions. The license is non-transferable and includes support for 12 months. Payment terms are net 30 days.",
    status: "signed"
  },
  {
    title: "Real Estate Purchase Contract",
    content: "Property purchase agreement for residential real estate. Includes property description, purchase price, payment schedule, and closing date. Buyer and seller responsibilities are outlined.",
    status: "signed"
  },
  {
    title: "Project Proposal - Mobile App Development",
    content: "Proposal for developing a mobile application for iOS and Android platforms. Timeline: 6 months. Budget: $50,000. Deliverables include design, development, testing, and deployment.",
    status: "uploaded"
  },
  {
    title: "Marketing Strategy 2024",
    content: "Comprehensive marketing strategy document outlining digital marketing campaigns, social media strategy, SEO optimization, and content marketing plans for the upcoming year.",
    status: "uploaded"
  },
  {
    title: "Meeting Notes - Q1 Review",
    content: "Quarterly review meeting notes discussing performance metrics, sales targets, customer feedback, and action items for the next quarter. Attendance: 15 people.",
    status: "signed"
  },
  {
    title: "Non-Disclosure Agreement (NDA)",
    content: "Confidentiality agreement between parties to protect sensitive business information. Covers trade secrets, proprietary data, and business strategies. Valid for 5 years.",
    status: "signed"
  },
  {
    title: "API Documentation - Payment Gateway",
    content: "Technical documentation for payment gateway API integration. Includes authentication methods, endpoint specifications, request/response examples, and error handling.",
    status: "uploaded"
  },
  {
    title: "Partnership Agreement Draft",
    content: "Draft partnership agreement outlining profit sharing, responsibilities, decision-making process, and dispute resolution. Equity split: 50/50 between partners.",
    status: "uploaded"
  },
  {
    title: "Annual Financial Report 2023",
    content: "Complete financial report for fiscal year 2023. Includes revenue analysis, expense breakdown, profit margins, cash flow statements, and balance sheet.",
    status: "signed"
  },
  {
    title: "Product Roadmap - Next 12 Months",
    content: "Strategic product roadmap outlining new features, improvements, and releases planned for the next year. Priority features include user authentication and payment integration.",
    status: "uploaded"
  },
  {
    title: "Customer Service Guidelines",
    content: "Internal guidelines for customer service representatives. Covers communication standards, escalation procedures, response time expectations, and quality metrics.",
    status: "signed"
  },
  {
    title: "Vendor Contract - Office Supplies",
    content: "Contract with office supplies vendor for recurring monthly deliveries. Payment terms: net 45 days. Discount: 15% on bulk orders over $1,000.",
    status: "signed"
  },
  {
    title: "Security Audit Report",
    content: "Comprehensive security audit findings covering network security, access controls, data encryption, and compliance with industry standards. Several medium-priority vulnerabilities identified.",
    status: "uploaded"
  },
  {
    title: "Training Manual - New Employees",
    content: "Onboarding training manual for new employees covering company culture, policies, tools, and procedures. Includes week-by-week training schedule.",
    status: "signed"
  },
  {
    title: "Lease Agreement - Office Space",
    content: "Commercial lease agreement for office space at 123 Main Street. Duration: 3 years with option to renew. Monthly rent: $5,000 including utilities.",
    status: "signed"
  },
  {
    title: "Data Privacy Policy Update",
    content: "Updated data privacy policy compliant with GDPR and CCPA regulations. Covers data collection, storage, usage, user rights, and breach notification procedures.",
    status: "uploaded"
  },
  {
    title: "Consulting Agreement - IT Services",
    content: "Consulting services agreement for IT infrastructure support. Hourly rate: $150. Minimum 20 hours per month. Includes on-call emergency support.",
    status: "signed"
  },
  {
    title: "Website Redesign Proposal",
    content: "Proposal for complete website redesign including UX/UI improvements, responsive design, performance optimization, and content migration. Estimated timeline: 4 months.",
    status: "uploaded"
  },
  {
    title: "Intellectual Property Agreement",
    content: "Agreement transferring intellectual property rights for software code, designs, and documentation. Includes licensing terms and usage restrictions.",
    status: "signed"
  }
]

# Create documents
created_count = 0
documents_data.each_with_index do |data, index|
  doc = Document.create!(
    title: data[:title],
    content: data[:content],
    status: data[:status],
    user_id: user_id
  )
  created_count += 1
  print "." if (index + 1) % 5 == 0
end

puts "\n✅ Created #{created_count} test documents"
puts "\nDocument breakdown:"
puts "  Signed: #{Document.status_signed.count}"
puts "  Uploaded: #{Document.status_uploaded.count}"
puts "  Reviewed: #{Document.status_reviewed.count}"
puts "\nNow run: rails opensearch:reset"
