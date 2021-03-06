require 'minitest/autorun'
require 'uri'
require 'csv'

class SyncTest < Minitest::Test
  def setup
    if EXPA.client.nil?
      xp = EXPA.setup()
      xp.auth(ENV['MEGAZORD_EMAIL'],ENV['MEGAZORD_PASSWORD'])
    end
=begin
    SyncControl.new do |sync|
      sync.start_sync = DateTime.now - 0.2
      sync.sync_type = 'open_people'
      sync.end_sync = DateTime.now
      sync.get_error = false
      sync.count_itens = 10
      sync.save
    end
=end
  end

=begin
  def teardown
    Archive.all.each do |archive|
      archive.destroy
    end
    ExpaApplication.all.each do |application|
      application.destroy
    end
    ExpaCurrentPosition.all.each do |current_position|
      current_position.destroy
    end
    ExpaOffice.all.each do |office|
      office.destroy
    end
    ExpaOpportunity.all.each do |opportuniy|
      opportuniy.destroy
    end
    ExpaPerson.all.each do |person|
      person.destroy
    end
    ExpaTeam.all.each do |team|
      team.destroy
    end
    SyncControl.all.each do |sync|
      sync.destroy
    end
  end

  def test_api_call
    params = {'per_page' => 500}
    params['filters['+'experience_end_date'+'][from]'] = Date.today.to_s
    params['filters['+'experience_end_date'+'][to]'] = Date.today.to_s
    params['filters[person_home_mc][]'] = 1606 #from MC Brazil
    params['filters[opportunity_programme][]'] = 1 #GCDP
    params['access_token'] = '83bcb5013acc57f07b5dfdd824c86826271d16f36559e0f9de80b5871edd1ecc' #GCDP
    uri = URI('https://gis-api.aiesec.org:443/v1/applications.json')
    uri.query = URI.encode_www_form(params)
    res = Net::HTTP.get(uri)
    res = JSON.parse(res) unless res.nil?
    puts res
    #total_items = EXPA::Applications.list_by_param(params)
  end
  def test_list_opens
    assert(ExpaPerson.all.count == 0, 'DB have registers. Make sure to clean DB before run tests, and it has ' + ExpaPerson.all.count.to_s)
    Sync.new.get_new_people_from_expa
    assert(ExpaPerson.all.count > 1, 'DB should have more than 1 register, but it has ' + ExpaPerson.all.count.to_s)
  end

  def test_list_applieds
    assert(ExpaApplication.all.count == 0, 'DB have registers. Make sure to clean DB before run tests, and it has ' + ExpaApplication.all.count.to_s)
    Sync.new.update_status('open', [1])
    assert(ExpaApplication.all.count > 1, 'DB should have more than 1 register, but it has ' + ExpaApplication.all.count.to_s)
  end

  def test_list_accepteds
    assert(ExpaApplication.all.count == 0, 'DB have registers. Make sure to clean DB before run tests, and it has ' + ExpaApplication.all.count.to_s)
    Sync.new.update_status('accepted', [1])
    assert(ExpaApplication.all.count > 1, 'DB should have more than 1 register, but it has ' + ExpaApplication.all.count.to_s)
  end

  def test_list_in_progress
    assert(ExpaApplication.all.count == 0, 'DB have registers. Make sure to clean DB before run tests, and it has ' + ExpaApplication.all.count.to_s)
    Sync.new.update_status('in_progress', [1])
    assert(ExpaApplication.all.count > 1, 'DB should have more than 1 register, but it has ' + ExpaApplication.all.count.to_s)
  end

  def test_list_approveds
    assert(ExpaApplication.all.count == 0, 'DB have registers. Make sure to clean DB before run tests, and it has ' + ExpaApplication.all.count.to_s)
    Sync.new.update_status('approved', [1])
    assert(ExpaApplication.all.count > 1, 'DB should have more than 1 register, but it has ' + ExpaApplication.all.count.to_s)
  end

  def test_list_realizeds
    assert(ExpaApplication.all.count == 0, 'DB have registers. Make sure to clean DB before run tests, and it has ' + ExpaApplication.all.count.to_s)
    Sync.new.update_status('realized', [1])
    assert(ExpaApplication.all.count > 1, 'DB should have more than 1 register, but it has ' + ExpaApplication.all.count.to_s)
  end

  def test_list_completeds
    assert(ExpaApplication.all.count == 0, 'DB have registers. Make sure to clean DB before run tests, and it has ' + ExpaApplication.all.count.to_s)
    Sync.new.update_status('completed', [1])
    assert(ExpaApplication.all.count > 1, 'DB should have more than 1 register, but it has ' + ExpaApplication.all.count.to_s)
  end

  def test_update_podio_with_new_fields
    assert(ExpaApplication.all.count == 0, 'DB have registers. Make sure to clean DB before run tests, and it has ' + ExpaApplication.all.count.to_s)
    ExpaOffice.new(id:20,xp_full_name:'AIESEC in Aracaju',xp_id:100,xp_name:'ARACAJU').save
    ExpaPerson.new(xp_id:299099230,xp_full_name: 'Robozinho dos testes',xp_email: 'robozobo@hahahah',how_got_to_know_aiesec:18,
      want_contact_by_email: true,want_contact_by_phone: false, want_contact_by_whatsapp: true,travel_interest:3,
      control_podio:'{}',entity_exchange_lc_id:20).save
    Sync.new.update_podio
  end

  def test_upload_applications_with_error
    Sync.new.upload_applications_with_error([1893278,1895086,1895304,1891660,1891689,1891729,1891731,1891738])
  end

  def test_send_expa_data_to_OD
    Sync.new.send_to_od
  end
  def test_expa_comparisson
    Sync.new.check_problematic_applications(Date.new(2016,1,1),Date.new(2016,9,1))
  end
  def test_analytics
    Sync.new.populate_od(Date.new(2016,9,14),Date.new(2016,9,26))
  end
  def test_update_podio
    Sync.new.expa_refresh
  end
  def test_joga_os_nego
    Sync.new.resolvendo_tretas
  end
  def test_expa_comparisson
    Sync.new.check_problematic_applications(Date.new(2016,3,21),Date.new(2016,3,21),[2],'people')
  end

  def test_send_to_rd
    #TODO: colocar todos os campos do peoples e applications aqui no RD
    #TODO: colocar breaks conferindo todos os campos
    json_to_rd = {}
    json_to_rd['token_rdstation'] = '41825a69a6fe5c2f1bae7452bfdd2b69'
    json_to_rd['identificador'] = 'approved'
    json_to_rd['email'] = 'luan@corumba.net'
    #json_to_rd['status'] = 'in_progress'
    json_to_rd['tags'] = "'GV','Teste','Apd'"
    uri = URI(ENV['RD_STATION_URL'])
    https = Net::HTTP.new(uri.host,uri.port)
    https.use_ssl = true
    req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
    req.body = json_to_rd.to_json
    begin
      response = https.request(req)
      puts 'RD Message: '+response.message
      puts 'RD Message: '+response.code
    rescue => exception
      puts exception.to_s
    end
  end
  def test_get_all_appllications
    Sync.new.check_problematic_applications(Date.new(2016,10,1),Date.new(2016,10,25))
  end

  def test_get_opportunities
    Sync.new.check_problematic_applications(Date.new(2017,1,1),Date.new(2017,02,22),[1],'opportunities')
  end

  def test_update_podio_ogx_people
    Sync.new.update_podio_ogx_people(590498244, 'approved', Date.new(2017,3,2))
  end

  def test_send_icx_application
    PodioSync.new.send_icx_application('approved', ExpaApplication.find_by_xp_id(1131006))
  end
  def test_send_icx_opportunity
    PodioSync.new.send_icx_opportunity(ExpaOpportunity.find_by_xp_id(722065))
  end
  def test_update_icx_applications
    Sync.new.update_status({"status" => "realized", "programs" => "1", "for_filter" => "opportunities" })
  end
  def test_update_offices
    EXPA::Offices.list_lcs.each do |lc|
      office = ExpaOffice.find_by_xp_id(lc.id)
      office = ExpaOffice.new if office.nil?
      office.update_from_expa(lc)
      office.save
      puts office.xp_name
    end
  end
  def test_opportunity_in_brazil
    puts Sync.new.opportunity_in_brazil(ExpaApplication.find_by_xp_id(1131006))
  end
  def test_get_skills
    CSV.open('opportunity_skills.csv', "wb") do |skills|
    CSV.open('opportunity_backgrounds.csv', "wb") do |bgs|
    CSV.open('opportunity_issues.csv', "wb") do |issues|
    CSV.open('opportunity_workk_fields.csv', "wb") do |works|
        skills << ['Opportunity ID','Skill ID', 'Skill', 'Option']
        bgs << ['Opportunity ID','Background ID', 'Background', 'Option']
        issues << ['Opportunity ID','Issue ID', 'Issue']
        works << ['Opportunity ID','Work Field ID', 'Work Field']
      ExpaOpportunity.all.each do |opportunity|
        opportunity.xp_skills.each do |skill|
          skills << [opportunity.xp_id,skill['id'],skill['name'],skill['option']]
        end
        opportunity.xp_backgrounds.each do |bg|
          bgs << [opportunity.xp_id,bg['id'],bg['name'],bg['option']]
        end
        opportunity.xp_issues.each do |issue|
          issues << [opportunity.xp_id,issue['id'],issue['name']]
        end
        opportunity.xp_work_fields.each do |work_field|
          works << [opportunity.xp_id,work_field['id'],work_field['name']]
        end
      end
    end
    end
    end
    end
  end
  def test_opportunites_update
    ManualSync.new.update_opportunities_without_lc
  end

  def test_opportunites_update
    PodioSync.new.send_icx_application(ExpaApplication.find_by_xp_id(3065454), 594310097)
  end

  def test_ogx_applications_update
    PodioSync.new.send_ogx_application(ExpaApplication.find_by_xp_id(3107344), 610873057)
  end
=end
  def test_ogx_applications_update2
    Sync.new.update_status(
        {
          "status" => 'approved', 
          "programs" => "1",
          "for_filter" => "people",
        }
      )
  end
end