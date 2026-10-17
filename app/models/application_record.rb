class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # Primary keys are UUID v7 (time-ordered, so sorting by id ~ creation order).
  # The column default gen_random_uuid() is v4 and only a fallback for raw SQL.
  # Tables that still use integer ids (e.g. Ahoy's) are left alone.
  before_create { self.id ||= SecureRandom.uuid_v7(extra_timestamp_bits: 12) if self.class.uuid_primary_key? }

  def self.uuid_primary_key?
    columns_hash[primary_key]&.type == :uuid
  end
end
