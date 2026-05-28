# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding database..."

# ── Accounts ──────────────────────────────────────────────────────
demo_account = Account.find_or_create_by!(name: "Acme Corp") do |a|
  a.industry            = "E-Commerce"
  a.status              = "active"
  a.plan                = "growth"
  a.subscription_status = "active"
end

second_account = Account.find_or_create_by!(name: "Bella Boutique") do |a|
  a.industry            = "Fashion & Retail"
  a.status              = "active"
  a.plan                = "starter"
  a.subscription_status = "active"
end

puts "  Created #{Account.count} accounts"

# ── Users ──────────────────────────────────────────────────────────
admin = User.find_or_create_by!(email: "admin@pixelia.com") do |u|
  u.password              = "password123"
  u.password_confirmation = "password123"
  u.role                  = :super_admin
  u.account               = nil
end

owner_user = User.find_or_create_by!(email: "user@acmecorp.com") do |u|
  u.password              = "password123"
  u.password_confirmation = "password123"
  u.role                  = :owner
  u.account               = demo_account
end

owner_user_2 = User.find_or_create_by!(email: "user@bellaboutique.com") do |u|
  u.password              = "password123"
  u.password_confirmation = "password123"
  u.role                  = :owner
  u.account               = second_account
end

puts "  Created #{User.count} users"

# ── E-Commerce Stores ────────────────────────────────────────────
ActsAsTenant.without_tenant do
  EcommerceStore.find_or_create_by!(account: demo_account, platform: "shopify") do |s|
    s.store_url  = "https://acme-store.myshopify.com"
    s.api_key    = "shpka_demo_key_acme"
    s.api_secret = "shpss_demo_secret_acme"
  end

  EcommerceStore.find_or_create_by!(account: second_account, platform: "woocommerce") do |s|
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
