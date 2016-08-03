# https://developer.akamai.com/api/purge/ccu-v2/overview.html
# https://github.com/akamai-open/AkamaiOPEN-edgegrid-ruby

require 'akamai/edgegrid'
require 'uri'
require 'json'

require 'akamai_ccu/version'

class AkamaiCCU
  MOCK_URI = URI('http://private-anon-5a5ba05b2-akamaiopen2purgeccuproduction.apiary-mock.com').freeze

  QUEUE_DEFAULT = :default
  QUEUE_EMERGENCY = :emergency

  DOMAIN_PRODUCTION = :production
  DOMAIN_STAGING = :staging

  ACTION_REMOVE = :remove
  ACTION_INVALIDATE = :invalidate

  TYPE_ARL = :arl
  TYPE_CPCODE = :cpcode

  def initialize(opts)
    @base_uri = URI(opts[:base_uri])
    @access_token = opts[:access_token]
    @client_token = opts[:client_token]
    @client_secret = opts[:client_secret]
  end

  def invalidate(*args)
    objects, opts = extract_opts(args)
    do_purge(opts.merge!(objects: objects, action: ACTION_INVALIDATE, type: TYPE_ARL))
  end

  def invalidate_cpcode(*args)
    objects, opts = extract_opts(args)
    do_purge(opts.merge!(objects: objects, action: ACTION_INVALIDATE, type: TYPE_CPCODE))
  end

  def remove(*args)
    objects, opts = extract_opts(args)
    do_purge(opts.merge!(objects: objects, action: ACTION_REMOVE, type: TYPE_ARL))
  end

  def remove_cpcode(*args)
    objects, opts = extract_opts(args)
    do_purge(opts.merge!(objects: objects, action: ACTION_REMOVE, type: TYPE_CPCODE))
  end

  def status(id)
    get("/ccu/v2/purges/#{id}")
  end

  def queue_length(queue: QUEUE_DEFAULT)
    get(queue_path(queue))
  end

  private

  def do_purge(opts)
    queue = opts.delete(:queue) || QUEUE_DEFAULT
    post(queue_path(queue), opts)
  end

  def extract_opts(args)
    args = args.dup
    opts = args.last.is_a?(Hash) ? args.pop : {}
    [args, opts]
  end

  def client
    @client ||= Akamai::Edgegrid::HTTP.new(@base_uri.host, @base_uri.port).tap do |h|
      h.setup_edgegrid(
        client_token: @client_token,
        client_secret: @client_secret,
        access_token: @access_token,
      )
    end
  end

  def queue_path(name)
    "/ccu/v2/queues/#{name}"
  end

  def get(path)
    req = Net::HTTP::Get.new((@base_uri + path).to_s, 'Content-Type' => 'application/json', 'Accept' => 'application/json')
    JSON.parse(client.request(req).body)
  end

  def post(path, payload)
    req = Net::HTTP::Post.new((@base_uri + path).to_s, 'Content-Type' => 'application/json', 'Accept' => 'application/json')
    req.body = JSON.dump(payload)
    JSON.parse(client.request(req).body)
  end
end
