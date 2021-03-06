require 'curb'
require 'json'
require "net/http"
require 'open-uri'
require 'sharepoint/sharepoint-session'
require 'sharepoint/sharepoint-object'
require 'sharepoint/sharepoint-types'

module Sharepoint
  class SPException < Exception
    def initialize data, uri = nil, body = nil
      @data = data['error']
      @uri  = uri
      @body = body
    end

    def lang         ; @data['message']['lang']  ; end
    def message      ; @data['message']['value'] ; end
    def code         ; @data['code'] ; end
    def uri          ; @uri ; end
    def request_body ; @body ; end
  end

  class Site
    attr_reader   :server_url
    attr_accessor :url, :protocol
    attr_accessor :session
    attr_accessor :name
    attr_accessor :verbose

    def initialize server_url, site_name
      @server_url  = server_url
      @name        = site_name
      @url         = "#{@server_url}/#{@name}"
      @session     = Session.new self
      @web_context = nil
      @protocol    = 'https'
      @verbose     = false
    end

    def authentication_path
      "#{@protocol}://#{@server_url}/_forms/default.aspx?wa=wsignin1.0"
    end

    def api_path uri
      "#{@protocol}://#{@url}/_api/web/#{uri}"
    end

    def filter_path uri
      uri
    end

    def context_info
      query :get, ''
    end

    # Sharepoint uses 'X-RequestDigest' as a CSRF security-like.
    # The form_digest method acquires a token or uses a previously acquired
    # token if it is still supposed to be valid.
    def form_digest
      if @web_context.nil? or (not @web_context.is_up_to_date?)
        @getting_form_digest = true
        @web_context         = query :post, "#{@protocol}://#{@server_url}/sites/mobileapp/_api/contextinfo"
        @getting_form_digest = false
      end
      @web_context.form_digest_value
    end

    def form_digest_second sites
      puts sites
      puts "888888888"
      if @web_context.nil? or (not @web_context.is_up_to_date?)
        @getting_form_digest = true
        @web_context         = query :post, "#{@protocol}://#{@server_url}/sites/#{sites}/_api/contextinfo"
        @getting_form_digest = false
      end
      @web_context.form_digest_value
    end

    def form_digest_third sites
      puts sites
      puts "888888888"
      if @web_context.nil? or (not @web_context.is_up_to_date?)
        @getting_form_digest = true
        @web_context         = query :post, "#{@protocol}://#{@server_url}/#{sites}/_api/contextinfo"
        @getting_form_digest = false
      end
      @web_context.form_digest_value
    end


    def query method, uri, body = nil, skip_json=false, &block
      uri        = if uri =~ /^http/ then uri else api_path(uri) end
      arguments  = [ uri ]
      arguments << body if method != :get
      result = Curl::Easy.send "http_#{method}", *arguments do |curl|
        curl.headers["Cookie"]          = @session.cookie
        curl.headers["Accept"]          = "application/json;odata=verbose"
        if method != :get
          curl.headers["Content-Type"]    = curl.headers["Accept"]
          curl.headers["X-HTTP-Method"]    = curl.headers["Accept"]
          curl.headers["X-RequestDigest"] = form_digest unless @getting_form_digest == true
        end
        curl.verbose = @verbose
        @session.send :curl, curl unless not @session.methods.include? :curl
        block.call curl           unless block.nil?
      end

      unless skip_json || (result.body_str.nil? || result.body_str.empty?)
        begin
          data = JSON.parse result.body_str
          raise Sharepoint::SPException.new data, uri, body unless data['error'].nil?
          make_object_from_response data
          rescue JSON::ParserError => e
            raise Exception.new("Exception with body=#{body}, e=#{e.inspect}, #{e.backtrace.inspect}, response=#{result.body_str}")
         end
      else
        result.body_str
      end
    end

    def query_second method, uri,sites = nil, body = nil, skip_json=false, &block
      if sites == nil
        sites = "mobileapp"
      end
      uri        = if uri =~ /^http/ then uri else api_path(uri) end
      arguments  = [ uri ]
      arguments << body if method != :get
      result = Curl::Easy.send "http_#{method}", *arguments do |curl|
        curl.headers["Cookie"]          = @session.cookie
        curl.headers["Accept"]          = "application/json;odata=verbose"
        if method != :get
          curl.headers["Content-Type"]    = curl.headers["Accept"]
          curl.headers["X-HTTP-Method"]    = curl.headers["Accept"]
          curl.headers["X-RequestDigest"] = form_digest_second(sites) unless @getting_form_digest == true
        end
        curl.verbose = @verbose
        @session.send :curl, curl unless not @session.methods.include? :curl
        block.call curl           unless block.nil?
      end

      unless skip_json || (result.body_str.nil? || result.body_str.empty?)
        begin
          data = JSON.parse result.body_str
          raise Sharepoint::SPException.new data, uri, body unless data['error'].nil?
          make_object_from_response data
        rescue JSON::ParserError => e
          raise Exception.new("Exception with body=#{body}, e=#{e.inspect}, #{e.backtrace.inspect}, response=#{result.body_str}")
        end
      else
        result.body_str
      end
    end

    def query_third method, uri,sites = nil, body = nil, skip_json=false, &block
      if sites == nil
        sites = "mobileapp"
      end
      uri        = if uri =~ /^http/ then uri else api_path(uri) end
      arguments  = [ uri ]
      arguments << body if method != :get
      result = Curl::Easy.send "http_#{method}", *arguments do |curl|
        curl.headers["Cookie"]          = @session.cookie
        curl.headers["Accept"]          = "application/json;odata=verbose"
        if method != :get
          curl.headers["Content-Type"]    = curl.headers["Accept"]
          curl.headers["X-HTTP-Method"]    = curl.headers["Accept"]
          curl.headers["X-RequestDigest"] = form_digest_third(sites) unless @getting_form_digest == true
        end
        curl.verbose = @verbose
        @session.send :curl, curl unless not @session.methods.include? :curl
        block.call curl           unless block.nil?
      end

      unless skip_json || (result.body_str.nil? || result.body_str.empty?)
        begin
          data = JSON.parse result.body_str
          raise Sharepoint::SPException.new data, uri, body unless data['error'].nil?
          make_object_from_response data
        rescue JSON::ParserError => e
          raise Exception.new("Exception with body=#{body}, e=#{e.inspect}, #{e.backtrace.inspect}, response=#{result.body_str}")
        end
      else
        result.body_str
      end
    end



    def image_list method, uri,sites = nil, body = nil, skip_json=false, &block
      if sites == nil
        sites = "mobileapp"
      end
      # uri        = if uri =~ /^http/ then uri else api_path(uri) end
      arguments  = [ uri ]
      arguments << body if method != :get
      result = Curl::Easy.send "http_#{method}", *arguments do |curl|
        curl.headers["Cookie"]          = @session.cookie
        curl.headers["Accept"]          = "application/json;odata=verbose"
        if method != :get
          curl.headers["Content-Type"]    = curl.headers["Accept"]
          curl.headers["X-HTTP-Method"]    = curl.headers["Accept"]
          curl.headers["X-RequestDigest"] = form_digest_second(sites) unless @getting_form_digest == true
        end
        curl.verbose = @verbose
        @session.send :curl, curl unless not @session.methods.include? :curl
        block.call curl           unless block.nil?
      end
        return  result.body_str


    end




    def subscribtion method, uri,sites = nil, body = nil, skip_json=false, &block
      if sites == nil
        sites = "mobileapp"
      end
      uri        = if uri =~ /^http/ then uri else api_path(uri) end
      arguments  = [ uri ]
      arguments << body if method != :get
      result = Curl::Easy.send "http_#{method}", *arguments do |curl|
        curl.headers["Cookie"]          = @session.cookie
        curl.headers["Accept"]          = "application/json"
        if method != :get
          curl.headers["Content-Type"]  = curl.headers["Accept"]
          curl.headers["X-RequestDigest"] = form_digest_second(sites) unless @getting_form_digest == true
        end
        curl.verbose = @verbose
        @session.send :curl, curl unless not @session.methods.include? :curl
        block.call curl           unless block.nil?
      end
      puts arguments
      data = JSON.parse result.body_str
      puts data

    end



    def query_update method, uri, body = nil, skip_json=false, &block
      uri        = if uri =~ /^http/ then uri else api_path(uri) end
      arguments  = [ uri ]
      arguments << body if method != :get
      result = Curl::Easy.send "http_#{method}", *arguments do |curl|
        curl.headers["Cookie"]          = @session.cookie
        curl.headers["Accept"]          = "application/json;odata=verbose"
        if method != :get
          curl.headers["Content-Type"]    = curl.headers["Accept"]
          curl.headers["X-HTTP-Method"]    = 'MERGE'
          curl.headers["If-Match"]    = '*'
          curl.headers["X-RequestDigest"] = form_digest unless @getting_form_digest == true
        end
        curl.verbose = @verbose
        @session.send :curl, curl unless not @session.methods.include? :curl
        block.call curl           unless block.nil?
      end

      unless skip_json || (result.body_str.nil? || result.body_str.empty?)
        begin
          data = JSON.parse result.body_str
          raise Sharepoint::SPException.new data, uri, body unless data['error'].nil?
          make_object_from_response data
        rescue JSON::ParserError => e
          raise Exception.new("Exception with body=#{body}, e=#{e.inspect}, #{e.backtrace.inspect}, response=#{result.body_str}")
        end
      else
        result.body_str
      end
    end

    def attachment method, uri,site, body = nil, skip_json=false, &block
      if site == nil
        site = "mobileapp"
      end
      uri        = if uri =~ /^http/ then uri else api_path(uri) end
      arguments  = [ uri ]
      arguments << body if method != :get
      result = Curl::Easy.send "http_#{method}", *arguments do |curl|
        # curl.multipart_form_post = true
        curl.headers["Cookie"]          = @session.cookie
        curl.headers["Accept"]          = "application/json;odata=verbose"
        if method != :get
          curl.headers["Content-Type"]    = curl.headers["Accept"]
          curl.headers["X-HTTP-Method"]    = 'POST'
          curl.headers["If-Match"]    = '*'
          curl.headers["X-RequestDigest"] = form_digest_second(site) unless @getting_form_digest == true
        end
        curl.verbose = @verbose
        @session.send :curl, curl unless not @session.methods.include? :curl
        block.call curl           unless block.nil?
      end

      unless skip_json || (result.body_str.nil? || result.body_str.empty?)
        begin
          data = JSON.parse result.body_str
          raise Sharepoint::SPException.new data, uri, body unless data['error'].nil?
          make_object_from_response data
        rescue JSON::ParserError => e
          raise Exception.new("Exception with body=#{body}, e=#{e.inspect}, #{e.backtrace.inspect}, response=#{result.body_str}")
        end
      else
        result.body_str
      end
    end




    def make_object_from_response data
      if data['d']['results'].nil?
        data['d'] = data['d'][data['d'].keys.first] if data['d']['__metadata'].nil?
        if not data['d'].nil?
          make_object_from_data data['d']
        else
          nil
        end
      else
        array = Array.new
        data['d']['results'].each do |result|
          array << (make_object_from_data result)
        end
        array
      end
    end

    # Uses sharepoint's __metadata field to solve which Ruby class to instantiate,
    # and return the corresponding Sharepoint::Object.
    def make_object_from_data data
      type_name  = data['__metadata']['type'].gsub(/^SP\./, '')
                                             .gsub(/^Collection\(Edm\.String\)/, 'CollectionString')
                                             .gsub(/^Collection\(Edm\.Int32\)/, 'CollectionInteger')
      type_parts = type_name.split '.'
      type_name  = type_parts.pop
      constant   = Sharepoint
      type_parts.each do |part| constant = constant.const_get part end

      klass      = constant.const_get type_name rescue nil
      if klass
        klass.new self, data
      else
        Sharepoint::GenericSharepointObject.new type_name, self, data
      end
    end
  end
end

