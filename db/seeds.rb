# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding database..."

# ── Clients ────────────────────────────────────────────────────────
demo_client = Client.find_or_create_by!(name: "Acme Corp") do |c|
  c.industry = "E-Commerce"
  c.status   = "active"
end

second_client = Client.find_or_create_by!(name: "Bella Boutique") do |c|
  c.industry = "Fashion & Retail"
  c.status   = "active"
end

puts "  Created #{Client.count} clients"

# ── Users ──────────────────────────────────────────────────────────
admin = User.find_or_create_by!(email: "admin@pixelia.com") do |u|
  u.password              = "password123"
  u.password_confirmation = "password123"
  u.role                  = :super_admin
  u.client                = nil
end

client_user = User.find_or_create_by!(email: "user@acmecorp.com") do |u|
  u.password              = "password123"
  u.password_confirmation = "password123"
  u.role                  = :client_user
  u.client                = demo_client
end

client_user_2 = User.find_or_create_by!(email: "user@bellaboutique.com") do |u|
  u.password              = "password123"
  u.password_confirmation = "password123"
  u.role                  = :client_user
  u.client                = second_client
end

puts "  Created #{User.count} users"

# ── Projects ──────────────────────────────────────────────────────
ActsAsTenant.without_tenant do
  p1 = Project.find_or_create_by!(name: "Acme Corporate Website", client: demo_client) do |p|
    p.project_type = "Website"
    p.status       = "active"
    p.launch_date  = Date.new(2026, 4, 15)
  end

  p2 = Project.find_or_create_by!(name: "Acme Shopify Store", client: demo_client) do |p|
    p.project_type = "E-Commerce"
    p.status       = "active"
    p.launch_date  = Date.new(2026, 3, 1)
  end

  p3 = Project.find_or_create_by!(name: "Acme SEO Campaign", client: demo_client) do |p|
    p.project_type = "SEO"
    p.status       = "in_progress"
    p.launch_date  = nil
  end

  p4 = Project.find_or_create_by!(name: "Bella Boutique Online Store", client: second_client) do |p|
    p.project_type = "E-Commerce"
    p.status       = "active"
    p.launch_date  = Date.new(2026, 5, 1)
  end

  puts "  Created #{Project.count} projects"

  # ── E-Commerce Stores ────────────────────────────────────────────
  EcommerceStore.find_or_create_by!(project: p2, platform: "Shopify") do |s|
    s.client     = demo_client
    s.store_url  = "https://acme-store.myshopify.com"
    s.api_key    = "shpka_demo_key_acme"
    s.api_secret = "shpss_demo_secret_acme"
  end

  EcommerceStore.find_or_create_by!(project: p4, platform: "WooCommerce") do |s|
    s.client     = second_client
    s.store_url  = "https://bellaboutique.com/shop"
    s.api_key    = "ck_demo_key_bella"
    s.api_secret = "cs_demo_secret_bella"
  end

  puts "  Created #{EcommerceStore.count} e-commerce stores"
end

# ── Leads ──────────────────────────────────────────────────────────
Lead.find_or_create_by!(email: "prospect@example.com") do |l|
  l.first_name   = "Carlos"
  l.project_type = "Full 360° Package"
  l.status       = "new"
end

Lead.find_or_create_by!(email: "maria@startup.io") do |l|
  l.first_name   = "Maria"
  l.project_type = "E-Commerce Store"
  l.status       = "new"
end

puts "  Created #{Lead.count} leads"
puts "Seeding complete!"
