require 'ostruct'
StoreData = Struct.new(:country, :host)
Address = Struct.new(:first_name ,:last_name ,:street_address ,:city ,:country ,:state ,:zip ,:phone, :date, :email)

class TestData
  AdminUser = OpenStruct.new({
    email: 'admin@example.com',
    password: 'test123'})

  Users = OpenStruct.new({
      valid: 'user@example.com',
      denied: 'user+denied@example.com',
      no_credit: 'user+red@example.com',
      signup: 'user+signup_required@example.com',
      pending_accepted: 'user+pend-accept-05@example.com',
      pending_rejected: 'user+pend-reject-05@example.com',
    })

  UKAddress = Address.new(
                'Testing User',
                'UK person',
                '222 Oxford st',
                'London',
                'United Kingdom',
                'London, City of',
                'W1C 1DD',
                '2076367700',
                nil,
                'youremail@email.com'   # Email
                )

  USAddress = Address.new(
                'Testing User',             # Name
                'US person',                # Last Name
                '1436 Adriel Dr',           # Stree
                'Fort Collins',             # City
                'United States of America', # Country
                'Colorado',                 # Distric
                '80524',                    # Postal Code
                '4075631020',               # Phone
                nil,                        # Age
                'youremail@email.com'       # Email
                )

  DEAddress = Address.new(
                'Testperson-de',        # Name
                'Approved',             # Last Name
                'Hellersbergstraße 14', # Stree
                'Neuss',                # City
                'Germany',              # Country
                'Nordrhein-Westfalen',  # Distric
                '41460',                # Postal Code
                '01522113356',          # Phone
                '07.07.1960',           # Age
                'user@example.com'   # Email
                )

  SEAddress = Address.new(
                'Testperson-se',        # Name
                'Approved',             # Last Name
                'Stårgatan 1',          # Stree
                'Ankeborg',             # City
                'Sweden',              # Country
                'Jönköpings län',       # Distric
                '12345',                # Postal Code
                '0765260000',           # Phone
                nil,                    # Age
                'youremail@email.com'   # Email
                )

  NOAddress = Address.new(
                'Testperson-no',        # Name
                'Approved',             # Last Name
                'Sæffleberggate 56',    # Stree
                'Oslo',                 # City
                'Norway',              # Country
                'Oslo',                 # Distric
                '0563',                 # Postal Code
                '40 123 456',           # Phone
                nil,                    # Age
                'user@example.com'      # Email
                )

  FIAddress = Address.new(
                'Testperson-fi',        # Name
                'Approved',             # Last Name
                'Kiväärikatu 10',       # Stree
                'Pori',                 # City
                'Finland',              # Country
                'Satakunta',            # Distric
                '28100',                # Postal Code
                '0401234567',           # Phone
                nil,                    # Age
                'user@example.com'      # Email
                )


  def initialize(store_id)
    @store_id = store_id
  end

  def country
    @store_id
  end

  def address
    case @store_id
      when 'uk'
        UKAddress
      when 'de'
        DEAddress
      when 'se'
        SEAddress
      when 'no'
        NOAddress
      when 'fi'
        FIAddress
      else
        USAddress
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

  def payment_name
    "Klarna #{@store_id.upcase}"
  end

  def local?
    true
  end
end
