require 'ostruct'
StoreData = Struct.new(:country, :host)
Address = Struct.new(:first_name ,:last_name ,:street_address ,:city ,:country ,:country_iso ,:state ,:zip ,:phone, :date, :email)

class TestData
  AdminUser = OpenStruct.new({
    email: 'admin@example.com',
    password: 'test123'})

  Users = OpenStruct.new({
      valid: 'user@example.com',
      denied: 'user+denied@example.com',
      no_credit: 'user+red@example.com',
      no_options_available: 'email+red@test.com',
      signup: 'user+signup_required@example.com',
      pending_accepted: 'user+pend-accept-05@example.com',
      pending_rejected: 'user+pend-reject-05@example.com',
    })

  def uk_address
    Address.new(
      'Testing User',
      'UK person',
      '222 Oxford st',
      'London',
      'United Kingdom',
      'GB',
      'London, City of',
      'W1C 1DD',
      '2076367700',
      nil,
      'ukmail@email.com'   # Email
    )
  end

  def us_address
    Address.new(
      'Testing User',             # Name
      'US person',                # Last Name
      '1436 Adriel Dr',           # Stree
      'Fort Collins',             # City
      'United States of America', # Country
      'US',                       # Country ISO
      'Colorado',                 # Distric
      '80524',                    # Postal Code
      '4075631020',               # Phone
      nil,                        # Age
      'usemail@email.com'       # Email
    )
  end

  def de_address
    Address.new(
      'Testperson-de',        # Name
      'Approved',             # Last Name
      'Hellersbergstraße 14', # Stree
      'Neuss',                # City
      'Germany',              # Country
      'DE',                   # Country ISO
      'Nordrhein-Westfalen',  # Distric
      '41460',                # Postal Code
      '01522113356',          # Phone
      '07.07.1960',           # Age
      'deuser@example.com'   # Email
    )
  end

  def se_address
    Address.new(
      'Testperson-se',        # Name
      'Approved',             # Last Name
      'Stårgatan 1',          # Stree
      'Ankeborg',             # City
      'Sweden',               # Country
      'SE',                   # Country ISO
      'Jönköpings län',       # Distric
      '12345',                # Postal Code
      '0765260000',           # Phone
      nil,                    # Age
      'seemail@email.com'   # Email
    )
  end

  def no_address
    Address.new(
      'Testperson-no',        # Name
      'Approved',             # Last Name
      'Sæffleberggate 56',    # Stree
      'Oslo',                 # City
      'Norway',               # Country
      'NO',                   # Country ISO
      'Oslo',                 # Distric
      '0563',                 # Postal Code
      '40 123 456',           # Phone
      nil,                    # Age
      'nouser@example.com'      # Email
    )
  end

  def fi_address
    Address.new(
      'Testperson-fi',        # Name
      'Approved',             # Last Name
      'Kiväärikatu 10',       # Stree
      'Pori',                 # City
      'Finland',              # Country
      'FI',                   # Country ISO
      'Satakunta',            # Distric
      '28100',                # Postal Code
      '0401234567',           # Phone
      nil,                    # Age
      'fiuser@example.com'      # Email
    )
  end

  def ca_address
    Address.new(
      'Testperson-fi',        # Name
      'Approved',             # Last Name
      '17007 107 Ave',        # Stree
      'Edmonton',             # City
      'Canada',               # Country
      'CA',                   # Country ISO
      'Alberta',              # Distric
      'T6C 1B6',              # Postal Code
      '780 452 8770',         # Phone
      nil,                    # Age
      'causer@example.com'      # Email
    )
  end

  def initialize(store_id)
    @store_id = store_id
  end

  def country
    @store_id
  end

  def address
    @address ||= case @store_id
      when 'uk'
        uk_address
      when 'de'
        de_address
      when 'se'
        se_address
      when 'no'
        no_address
      when 'fi'
        fi_address
      when 'ca'
        ca_address
      else
        us_address
    end
  end

  def us?
    country == 'us'
  end

  def uk?
    country == 'uk'
  end

  def de?
    country == 'de'
  end

  def se?
    country == 'se'
  end

  def no?
    country == 'no'
  end

  def fi?
    country == 'fi'
  end

  def ca?
    country == 'ca'
  end

  def payment_name
    "Klarna #{@store_id.upcase}"
  end

  def local?
    true
  end
end
