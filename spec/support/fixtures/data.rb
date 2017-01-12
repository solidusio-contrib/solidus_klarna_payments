require 'ostruct'
StoreData = Struct.new(:country, :host)
Address = Struct.new(:first_name ,:last_name ,:street_address ,:city ,:country ,:state ,:zip ,:phone)

module TestData
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
                '2076367700')

  USAddress = Address.new(
                'Testing User',
                'USed',
                '1436 Adriel Dr',
                'Fort Collins',
                'United States of America',
                'Colorado',
                '80524',
                '4075631020')

  DEAddress = Address.new(
                'Testing User',
                'DEed',
                'Torstrasse 56',
                'Berlin',
                'Germany',
                'Berlin',
                '10119',
                '2076367300')
end
