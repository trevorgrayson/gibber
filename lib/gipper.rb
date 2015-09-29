require 'logger'
require 'socket'
require 'uri'
require 'timeout'

class Gipper

  @@logger = nil

  def initialize *args, &block
    reset
    envs = [] + args

    envs.each do |e|
      @env.merge! e
    end

    self.instance_eval &block

    if !@errors.empty?
      message = @errors.map{|k,v| "#{k} is #{v}"}.join(", ")[0..-1]
      @@logger.error message if @@logger
      raise GipperError, message
    end

    if !@warnings.empty?
      @warnings.map{|k,v| 
        @@logger.warn "#{k} is #{v}"
      } if @@logger
    end
  end

  def self.review *args, &block
    g = Gipper.new *args do
      self.instance_eval &block
    end
    g.env
  end

  def verify_service *fields, &block
    options = fields[fields.size].is_a?(Hash) ? fields.delete(fields.size) : nil

    fields.each do |field|
      field = field.to_s
      uri = URI.parse( check_field(field) )

      unless is_port_open?( uri.host, uri.port )
        @errors[field] = "isn't running" #options[:fail_message] ? options[:fail_message] : "isn't running"

        if block
          block.call
        end
      end
    end
  end

  def verify *fields
    options = fields[fields.size].is_a?(Hash) ? fields.delete(fields.size) : nil

    fields.each do |field|
      unless check_field field
        @errors[field] = "not set"
      end

      #if options.respond_to? :probe && options[:probe]
      #  @errors[field] = "does not respond on port blah"
      #end
    end
  end

  def trust *fields
    options = fields[fields.size].is_a?(Hash) ? fields.delete(fields.size) : nil

    fields.each do |field|
      unless check_field field
        @warnings[field] = "not set"
      end
    end
  end

  def check_field field
    @env[field]
  end

  # Thanks to Chris Rice!
  # http://stackoverflow.com/questions/517219/ruby-see-if-a-port-is-open
  def is_port_open?(ip, port, timeout=1)
    begin
      Timeout::timeout(timeout) do
        begin
          s = TCPSocket.new(ip, port)
          s.close
          return true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          return false
        end
      end
    rescue Timeout::Error
    end

    return false
  end

  def reset
    @env = ENV.is_a?(Hash) ? ENV : ENV.to_h
    @errors = {}
    @warnings = {}
  end

  attr_accessor :logger

  def env
    @env
  end

  alias doveryai trust 
  alias proveryai verify 

  class << self
    def logger=(logger=Logger.new(STDOUT))
      @@logger=logger
    end
  end

end

class GipperError < StandardError
end



  #def trust *fields
  #  options = fields[fields.size].is_a?(Hash) ? fields.delete(fields.size) : nil

  #  @@logger.warn ("'%s' field is not set" % field) unless @@env[field]
  #end

