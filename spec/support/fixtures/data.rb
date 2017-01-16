require 'ostruct'
StoreData = Struct.new(:country, :host)
Address = Struct.new(:first_name ,:last_name ,:street_address ,:city ,:country ,:state ,:zip ,:phone, :date)

class TestData
  AdminUser = OpenStruct.new({
    email: 'admin@example.com',
    password: 'test123'})

  Users = OpenStruct.new({
      valid: 'user@example.com',
      no_credit: 'user+red@example.com',
      signup: 'user+signup_required@example.com',
      pending_accepted: 'user+pend-accept-05@example.com',
      pending_rejected: 'user+pend-reject-05@example.com',
    })

  LocalStore = StoreData.new('us', 'http://localhost:3000')
  USStore = StoreData.new('us', 'https://klarna-solidus-demo.herokuapp.com')
  UKStore = StoreData.new('uk', 'https://klarna-solidus-demo-uk.herokuapp.com')
  DEStore = StoreData.new('de', 'https://klarna-solidus-demo-de.herokuapp.com')



  UKAddress = Address.new(
                'Testing User',
                'UKed',
                '222 Oxford st',
                'London',
                'United Kingdom',
                'London, City of',
                'W1C 1DD',
                '2076367700',
                nil)

  USAddress = Address.new(
                'Testing User',
                'USed',
                '1436 Adriel Dr',
                'Fort Collins',
                'United States of America',
                'Colorado',
                '80524',
                '4075631020',
                nil)

  DEAddress = Address.new(
                'Testing User',
                'DEed',
                'Torstrasse 56',
                'Berlin',
                'Deutschland',
                'Berlin',
                '10119',
                '2076367300',
                '10.10.1970')


  def initialize(store_id)
    @store_id = store_id
  end

  def host
    store.host
  end

  def store
    case @store_id
      when 'us'
        USStore
      when 'uk'
        UKStore
      when 'de'
        DEStore
      when nil
        LocalStore
      else
        StoreData.new('us', @store_id)
    end
  end

  def country
    case @store_id
      when 'uk', 'de'
        @store_id
      else
        'us'
    end
  end

  def address
    case @store_id
      when 'us'
        USAddress
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
end
