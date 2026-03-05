Rails.application.config.active_record.encryption.primary_key = ENV.fetch("ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY", "ttaKFWp5x3GbdZgCJTTe06EsqKOTJzPb")
Rails.application.config.active_record.encryption.deterministic_key = ENV.fetch("ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY", "CyaiNSS7CUMOLVWWEYJHRUTFbtiaEh7t")
Rails.application.config.active_record.encryption.key_derivation_salt = ENV.fetch("ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT", "IktEp2Otu3KqSMY2Cs0w5FH4rr9R7kl1")
