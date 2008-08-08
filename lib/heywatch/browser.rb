require "net/http"

module HeyWatch
  # This class is used to request the Hey!Watch service.
  #
  #   Browser::get '/video', session
  #   Browser::post '/download', {:url => 'http://host.com/video.avi'}, session
  #   Browser::put '/encoded_video/54000', {:title => 'new title'}, session
  #   Browser::delete '/encoded_video/54000', session
  class Browser
    class << self
      # Raise when code response != 2xx
      def raise_if_response_error(res)
        code = res.response.code.to_i
        message = res.response.message
        return if code.to_s =~ /^2/
        
        raise RequestError, HeyWatch::response(res.body).content if code == 400
        raise NotAuthorized, message if code == 401
        raise ResourceNotFound, message if code == 404
        raise ServerError, message if code == 500
      end

      def header(session=nil) #:nodoc:
        h = {}
        h.merge!({"Cookie" => "_session_id=#{session};"}) if session
        h.merge!({"User-Agent" => "Hey!Watch ruby API - #{VERSION::STRING}"})
      end
      
      # Login to Hey!Watch service. Return the session ID.
      #
      # You should not use it directly, use Auth#create instead
      #
      #  Browser::login 'login', 'password'
      def login(login, password) #:nodoc:
        res = Browser::post("/auth/login", :login => login, :password => password)
        return res["Set-cookie"].match(/_session_id=(.*);/i)[1].to_s
      end
      
      # GET on path
      def get(path, session=nil)
        path += ".#{OutFormat}" unless path.include? "."
        res = Net::HTTP.start(Host) {|http| http.get(path, header(session))}
        raise_if_response_error(res)
        res
      end

      # POST on path and pass the query(Hash)
      def post(path, query={}, session=nil)
        res = Net::HTTP.start(Host) {|http| http.post(path, query.merge(:format => OutFormat).to_a.map{|x| x.join("=")}.join("&"), self.header(session))}
        raise_if_response_error(res)
        res
      end
      
      # PUT on path and pass the query(Hash)
      def put(path, query={}, session=nil)
        req = Net::HTTP::Put.new(path, header(session))
        req.form_data = query.merge(:format => OutFormat)
        res = Net::HTTP.new(Host).start {|http| http.request(req) }
        raise_if_response_error(res)
        true
      end
      
      # DELETE on path
      def delete(path, session=nil)
        res = Net::HTTP.start(Host) {|http| http.delete(path+"."+OutFormat, header(session))}
        raise_if_response_error(res)
        true
      end
      
      def post_multipart(path, attributes={}, session=nil) #:nodoc:
        file = attributes.delete(:file)
        params = [file_to_multipart("data", File.basename(file),"application/octet-stream", File.read(file))]
        attributes.merge("format" => OutFormat).each_pair{|k,v| params << text_to_multipart(k.to_s, v.to_s)}

        boundary = '349832898984244898448024464570528145'
        query = params.collect {|p| '--' + boundary + "\r\n" + p}.join('') + "--" + boundary + "--\r\n"
        res = Net::HTTP.start(Host) {|http| http.post(path, query, header(session).merge("Content-Type" => "multipart/form-data; boundary=" + boundary))}
        raise_if_response_error(res)
        res
      end

      def text_to_multipart(key,value) #:nodoc:
        return "Content-Disposition: form-data; name=\"#{CGI::escape(key.to_s)}\"\r\n" + 
               "\r\n" + 
               "#{value}\r\n"
      end

      def file_to_multipart(key,filename,mime_type,content) #:nodoc:
        return "Content-Disposition: form-data; name=\"#{CGI::escape(key.to_s)}\"; filename=\"#{filename}\"\r\n" +
               "Content-Transfer-Encoding: binary\r\n" +
               "Content-Type: #{mime_type}\r\n" + 
               "\r\n" + 
               "#{content}\r\n"
      end
    end
  end
end
