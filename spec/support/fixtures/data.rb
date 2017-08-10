require 'ostruct'
StoreData = Struct.new(:country, :host)
Address = Struct.new(:first_name ,:last_name ,:street_address ,:city ,:country ,:state ,:zip ,:phone, :date)

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
                nil)

  USAddress = Address.new(
                'Testing User',
                'US person',
                '1436 Adriel Dr',
                'Fort Collins',
                'United States of America',
                'Colorado',
                '80524',
                '4075631020',
                nil)

  DEAddress = Address.new(
                'Testing User',
                'DE person',
                'Torstrasse 56',
                'Berlin',
                'Germany',
                'Berlin',
                '10119',
                '2076367300',
                '10.10.1970')


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

  def payment_name
    "Klarna Credit #{@store_id.upcase}"
  end

  def local?
    true
  end
end
