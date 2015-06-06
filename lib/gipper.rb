require 'logger'

class Gipper

  @logger = Logger.new(STDOUT)

  def initialize *args, &block
    reset
    envs = [] + args

    envs.each do |e|
      @env.merge! e
    end

    self.instance_eval &block

    if !@errors.empty?
      message = @errors.map{|k,v| "#{k} is #{v}"}.join(", ")[0..-1]
      @logger.error message if @logger
      raise GipperError, message
    end
  end

  def verify *fields
    options = fields[fields.size].is_a?(Hash) ? fields.delete(fields.size) : nil

    fields.each do |field|
      unless check_field field
        @errors[field] = "not set"
      end
    end

  end

  def check_field field
    @env[field]
  end

  def reset
    @env   = ENV.to_h
    @errors = {}
    @warnings = {}
  end

  attr_accessor :logger

  def env
    @env
  end
end

class GipperError < StandardError
end



  #def trust *fields
  #  options = fields[fields.size].is_a?(Hash) ? fields.delete(fields.size) : nil

  #  @@logger.warn ("'%s' field is not set" % field) unless @@env[field]
  #end

