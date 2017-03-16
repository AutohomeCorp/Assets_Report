$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))
require "rubygems"
require 'puppet'
require 'puppet/network/http_pool'
require 'uri'
require 'yaml'
require 'pathname'
require 'json'
require 'net/http'
require 'pp'
require 'auth'

Puppet::Reports.register_report(:assets_report) do

  desc <<-DESC
    Send reports via HTTP or HTTPS. This report processor submits reports as
    POST requests to the address in the  settings. The body of each POST
    request is the YAML dump of a Puppet::Transaction::Report object, and the
    Content-Type is set as `application/x-yaml`.
  DESC

  $setting_file = 'report_setting.yaml'
  $fact_dir = Pathname(Puppet[:vardir]) + Pathname('yaml') + Pathname('facts')

  class ReportCache
    def initialize(fact_file, enable_cache)
      @fact_file = fact_file
      @enable_cache = enable_cache
    end

    def get_cache_file
      base_name = File.basename(@fact_file)
      return $fact_dir + "cache.#{base_name}"
    end

    def write_cache(content)
      cache_file = get_cache_file()
      File.open(cache_file, 'w+') do |fp|
        fp.write(content.strip)
      end
    end

    def cached?(data)
      # data is a runy hash of report_data
      unless @enable_cache
        return false
      end
      cache_file = get_cache_file()
      if not File.exist?(cache_file)
        return false
      end

      File.open(cache_file, 'r') do |fp|
        cached_content = fp.read()
        if data == JSON.parse(cached_content)
          return true
        else
          return false
        end
      end
    end
  end



  class NIC
    def self.not_hardware?(nic_name)
      black_list = ['lo', 'tun']
      black_list.each do |e|
        if Regexp.new(e).match(nic_name)
          return true
        end
      end
      return false
    end

    def self.is_hardware?(nic_name)
      hw_names = ['em', 'eth', 'p', 'lan', 'Local']

      hw_names.each do |e|
        if nic_name.start_with?(e)
          return true
        end
      end
      return false
    end
  end


  def process

    cert_name = self.name
    cert_name_tag = "__assets_report__#{cert_name}__"
    setting_file_path = Pathname.new(File.dirname(__FILE__)) + $setting_file

    unless File.exist?(setting_file_path)
      Puppet.err "#{cert_name_tag} setting file is not exist: #{setting_file_path} "
    end

    setting = YAML.load_file(setting_file_path)
    url = URI.parse(setting[:report_url])
    auth_required = setting[:auth_required]
    user = setting[:user]
    passwd = setting[:passwd]
    enable_cache = setting[:enable_cache]

    headers = { 'Content-Type' => 'application/json; charset=UTF-8' }
    options = {}

    fact_file = $fact_dir + Pathname("#{self.name}.yaml")
    if not fact_file.exist?
      Puppet.err "#{cert_name_tag} Fact file is not exist: #{fact_file}"
      return false
    end

    if auth_required
        au = AuthUrl.new(user, passwd, url.path)
        report_path = au.build_auth_url()
    else
        report_path = url.path
    end

    fact_data = YAML::load_file(fact_file)

    ################################################
    # for ram
    ################################################
    ram_slot_hash = {}
    fact_ram_slot = fact_data.values.fetch('ram', '[]')
    total_ram_size = 0

    JSON.load(fact_ram_slot).each do |e|
      size = Integer(e['capacity']) if Integer(e['capacity']) rescue false  # unit GB
      if not size
        size = 0
      end
      ram_slot_hash[e['slot']] =
          {
              'sn' => e['sn'],
              'model' => e['model'],
              'manufactory' => e['manufactory'],
              'capacity' => size,
          }
			total_ram_size += size
    end
    # for windows 2003 and below
    if 0 == total_ram_size
      total_ram_size = fact_data.values.fetch('memorysize_mb', '0').to_i / 1024.0
      # if ram size is below 1G, we can not round it, otherwise it will be zero.
      if total_ram_size > 1
        total_ram_size = total_ram_size.round
      end
    end


    ################################################
    # for nic
    ################################################
    nic_interface = fact_data.values.fetch('interfaces', '')
    nic_bonding_data = fact_data.values.fetch('bonding', '{}')

    nic_bonding_map = JSON.parse(nic_bonding_data)
    nic_interface = fact_data.values.fetch('interfaces', '')
    nic_count = 0
    nic_hash = {}

    if not nic_interface.empty?
      nic_res = fact_data.values.fetch('nic_info')
      nic_hash = JSON.parse(nic_res)
      nic_count = nic_hash.length
    else
      # on some machine Facter do not provide fact interfaces
      nic_count = 1
      nic_hash['local'] = {}
      nic_hash['local']['ipaddress'] = fact_data.values.fetch('ipaddress','')
      nic_hash['local']['macaddress'] = fact_data.values.fetch('macaddress', '')
      nic_hash['local']['netmask'] = fact_data.values.fetch('netmask', '')
      nic_hash['local']['network'] = fact_data.values.fetch('network', '')
      nic_hash['local']['model'] = ''
      nic_hash['local']['hardware'] = 1

    end

    ################################################
    # for disk
    ################################################
    raid_adaptor_count = fact_data.values.fetch('raid_adaptor_count', '0').to_i

    physical_disk_string = fact_data.values.fetch('physical_disk_driver', '[]')
    physical_disk_driver = JSON.parse(physical_disk_string)



    ################################################
    # for raid adaptor
    ################################################
    raid_adaptor_hash = {}
    raid_adaptor_data = fact_data.values.fetch('raid_adaptor', '{}')
    JSON.parse(raid_adaptor_data).each do |k, v|
      raid_adaptor_hash[k] = {}
      v.each_key do |ik|
        raid_adaptor_hash[k]['model'] = v["model"]
        raid_adaptor_hash[k]['sn'] = v["sn"]
        raid_adaptor_hash[k]['memory_size'] = v["memory_size"]
        #raid_adaptor_hash[k]['raid_type'] = v["RAID Level"]
      end
    end


    report_data = {
      'os_type' => fact_data.values.fetch('kernel', '').strip,
      'os_distribution' => fact_data.values.fetch('operatingsystem', '').strip,
      'os_release' => fact_data.values.fetch('operatingsystemrelease', '').strip,
      'not_modify' => 0,
      'setuptime' => fact_data.values.fetch('setuptime',''),
      'sn' => fact_data.values.fetch('serialnumber', '').strip,
      'manufactory' => fact_data.values.fetch('manufacturer', '').strip,
      'productname' => fact_data.values.fetch('productname','').strip,
      'model' => fact_data.values.fetch('productname', '').strip,

      'cpu_count' => fact_data.values.fetch('physicalprocessorcount', ''),
      'cpu_core_count' => fact_data.values.fetch('cpu_core_count', ''),
      'cpu_model' => fact_data.values.fetch('processor0', '').strip,

      'nic_count' => nic_count,
      'nic' => nic_hash,

      'raid_adaptor_count' => raid_adaptor_count,
      'raid_adaptor' => raid_adaptor_hash,
      'raid_type' => fact_data.values.fetch('raid_type', ''),

      'physical_disk_driver' => physical_disk_driver,
      'ram_size' => total_ram_size,
      'ram_slot' => ram_slot_hash,
      'certname' => self.name,
    }

    #PP.pp(report_data)

    report_data_in_json = {}
    cached_flag = false
    cache = ReportCache.new(fact_file, enable_cache)

    if cache.cached?(report_data)
      Puppet.info "Report content is not modified"
      report_data_in_json = JSON.dump({'not_modify' => 1, 'certname' => self.name})
      cached_flag = true
    else
      Puppet.info "Report content is modified"
      report_data_in_json = JSON.dump(report_data)
    end

    #Puppet.info "report_path: #{report_path}"
    #Puppet.info report_path
    conn = Puppet::Network::HttpPool.http_instance(url.host, url.port, use_ssl=false, verify_peer=false)
    response = conn.post(report_path, report_data_in_json, headers, options)

    if response.kind_of?(Net::HTTPSuccess)
      begin
        cache.write_cache(report_data_in_json) unless cached_flag
      rescue Exception => e
          Puppet.err "Write report cache failed #{cert_name_tag}: #{e.message}"
      end
      Puppet.info "Header: #{response.code}"
      Puppet.info "Body: #{response.body}"
    else
      response.each {|k, v| Puppet.err  "#{cert_name_tag} Header: #{k}: #{v}" }
      Puppet.err "#{cert_name_tag} #{response.body}"
      Puppet.err "Unable to submit #{cert_name_tag} report to #{url} [#{response.code}] #{response.msg}"

    end
  end

end
