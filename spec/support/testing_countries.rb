module TestingCountries
  def populate_countr(iso)
    case iso
    when 'de'
      create(:country, {
        iso_name: "GERMANY",
        iso: "DE",
        iso3: "DEU",
        name: "Germany",
        numcode: 276,
        states_required: true
      })
    when 'fi'
      create(:country, {
        iso_name: "FINLAND",
        iso: "FI",
        iso3: "FIN",
        name: "Finland",
        numcode: 246,
        states_required: true
      })
    when 'no'
      create(:country, {
        iso_name: "NORWAY",
        iso: "NO",
        iso3: "NOR",
        name: "Norway",
        numcode: 578,
        states_required: true
      })
    when 'se'
      create(:country, {
        iso_name: "SWEDEN",
        iso: "SE",
        iso3: "SWE",
        name: "Sweden",
        numcode: 752,
        states_required: true
      })
    when 'us'
      create(:country, {
        iso_name: "UNITED STATES",
        iso: "US",
        iso3: "USA",
        name: "United States",
        numcode: 840,
        states_required: true
      })
    when 'uk'
      create(:country, {
        iso_name: "UNITED KINGDOM",
        iso: "GB",
        iso3: "GBR",
        name: "United Kingdom",
        numcode: 826,
        states_required: true
      })
    end
  end
end
