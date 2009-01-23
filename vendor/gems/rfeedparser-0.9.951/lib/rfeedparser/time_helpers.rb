#!/usr/bin/env ruby
require 'time'

module FeedParser

  class FeedTimeParser
    @@date_handlers = [:parse_date_rfc822,
      :parse_date_hungarian, :parse_date_greek,:parse_date_mssql,
      :parse_date_nate,:parse_date_onblog,:parse_date_w3dtf,:parse_date_iso8601
    ]
    class << self
      # ISO-8601 date parsing routines written by Fazal Majid.
      # The ISO 8601 standard is very convoluted and irregular - a full ISO 8601
      # parser is beyond the scope of feedparser and the current Time.iso8601 
      # method does not work.  
      # A single regular expression cannot parse ISO 8601 date formats into groups
      # as the standard is highly irregular (for instance is 030104 2003-01-04 or
      # 0301-04-01), so we use templates instead.
      # Please note the order in templates is significant because we need a
      # greedy match.
      def parse_date_iso8601(dateString)
        # Parse a variety of ISO-8601-compatible formats like 20040105

        # What I'm about to show you may be the ugliest code in all of 
        # rfeedparser.
        # FIXME The century regexp maybe not work ('\d\d$' says "two numbers at 
        # end of line" but we then attach more of a regexp.  
        iso8601_regexps = [ '^(\d{4})-?([01]\d)-([0123]\d)',
        '^(\d{4})-([01]\d)',
        '^(\d{4})-?([0123]\d\d)',
        '^(\d\d)-?([01]\d)-?([0123]\d)',
        '^(\d\d)-?([0123]\d\d)',
        '^(\d{4})',
        '-(\d\d)-?([01]\d)',
        '-([0123]\d\d)',
        '-(\d\d)',
        '--([01]\d)-?([0123]\d)',
        '--([01]\d)',
        '---([0123]\d)',
        '(\d\d$)',
        '' ]
        iso8601_values = { '^(\d{4})-?([01]\d)-([0123]\d)' => ['year', 'month', 'day'],
        '^(\d{4})-([01]\d)' => ['year','month'], 
        '^(\d{4})-?([0123]\d\d)' => ['year', 'ordinal'],
        '^(\d\d)-?([01]\d)-?([0123]\d)' => ['year','month','day'], 
        '^(\d\d)-?([0123]\d\d)' => ['year','ordinal'],
        '^(\d{4})' => ['year'],
        '-(\d\d)-?([01]\d)' => ['year','month'], 
        '-([0123]\d\d)' => ['ordinal'], 
        '-(\d\d)' => ['year'],
        '--([01]\d)-?([0123]\d)' => ['month','day'],
        '--([01]\d)' => ['month'],
        '---([0123]\d)' => ['day'],
        '(\d\d$)' => ['century'], 
        '' => [] }
        add_to_all = '(T?(\d\d):(\d\d)(?::(\d\d))?([+-](\d\d)(?::(\d\d))?|Z)?)?'
        add_to_all_fields = ['hour', 'minute', 'second', 'tz', 'tzhour', 'tzmin'] 
        # NOTE We use '(?:' to prevent grouping of optional matches (ones trailed
        # by '?'). The second ':' *are* matched.
        m = nil
        param_keys = []
        iso8601_regexps.each do |s|
          $stderr << "Trying iso8601 regexp: #{s+add_to_all}\n" if $debug
          param_keys = iso8601_values[s] + add_to_all_fields
          m = dateString.match(Regexp.new(s+add_to_all))
          break if m
        end
        return if m.nil? or (m.begin(0).zero? and m.end(0).zero?) 

        param_values = m.to_a
        param_values = param_values[1..-1] 
        params = {}
        param_keys.each_with_index do |key,i|
          params[key] = param_values[i]
        end

        ordinal = params['ordinal'].to_i unless params['ordinal'].nil?
        year = params['year'] || '--'
        if year.nil? or year.empty? or year == '--' # FIXME When could the regexp ever return a year equal to '--'?
          year = Time.now.utc.year
        elsif year.length == 2
          # ISO 8601 assumes current century, i.e. 93 -> 2093, NOT 1993
          year = 100 * (Time.now.utc.year / 100) + year.to_i
        else
          year = year.to_i
        end

        month = params['month'] || '-'
        if month.nil? or month.empty? or month == '-'
          # ordinals are NOT normalized by mktime, we simulate them
          # by setting month=1, day=ordinal
          if ordinal
            month = DateTime.ordinal(year,ordinal).month
          else
            month = Time.now.utc.month
          end
        end
        month = month.to_i unless month.nil?
        day = params['day']
        if day.nil? or day.empty?
          # see above
          if ordinal
            day = DateTime.ordinal(year,ordinal).day
          elsif params['century'] or params['year'] or params['month']
            day = 1
          else
            day = Time.now.utc.day
          end
        else
          day = day.to_i
        end
        # special case of the century - is the first year of the 21st century
        # 2000 or 2001 ? The debate goes on...
        if params.has_key? 'century'
          year = (params['century'].to_i - 1) * 100 + 1
        end
        # in ISO 8601 most fields are optional
        hour = params['hour'].to_i 
        minute = params['minute'].to_i 
        second = params['second'].to_i 
        weekday = nil
        # daylight savings is complex, but not needed for feedparser's purposes
        # as time zones, if specified, include mention of whether it is active
        # (e.g. PST vs. PDT, CET). Using -1 is implementation-dependent and
        # and most implementations have DST bugs
        tm = [second, minute, hour, day, month, year, nil, ordinal, false, nil]
        tz = params['tz']
        if tz and not tz.empty? and tz != 'Z'
          # FIXME does this cross over days?
          if tz[0] == '-'
            tm[3] += params['tzhour'].to_i
            tm[4] += params['tzmin'].to_i
          elsif tz[0] == '+'
            tm[3] -= params['tzhour'].to_i
            tm[4] -= params['tzmin'].to_i
          else
            return nil
          end
        end
        return Time.utc(*tm) # Magic!

      end

      def parse_date_onblog(dateString)
        # Parse a string according to the OnBlog 8-bit date format
        # 8-bit date handling routes written by ytrewq1
        korean_year  = u("년") # b3e2 in euc-kr
        korean_month = u("월") # bff9 in euc-kr
        korean_day   = u("일") # c0cf in euc-kr


        korean_onblog_date_re = /(\d{4})#{korean_year}\s+(\d{2})#{korean_month}\s+(\d{2})#{korean_day}\s+(\d{2}):(\d{2}):(\d{2})/


        m = korean_onblog_date_re.match(dateString)
        
        w3dtfdate = "#{m[1]}-#{m[2]}-#{m[3]}T#{m[4]}:#{m[5]}:#{m[6]}+09:00"

        $stderr << "OnBlog date parsed as: %s\n" % w3dtfdate if $debug
        return parse_date_w3dtf(w3dtfdate)
      end

      def parse_date_nate(dateString)
        # Parse a string according to the Nate 8-bit date format
        # 8-bit date handling routes written by ytrewq1
        korean_am    = u("오전") # bfc0 c0fc in euc-kr
        korean_pm    = u("오후") # bfc0 c8c4 in euc-kr

        korean_nate_date_re = /(\d{4})-(\d{2})-(\d{2})\s+(#{korean_am}|#{korean_pm})\s+(\d{0,2}):(\d{0,2}):(\d{0,2})/
        m = korean_nate_date_re.match(dateString)
        
        hour = m[5].to_i
        ampm = m[4]
        if ampm == korean_pm
          hour += 12
        end
        hour = hour.to_s.rjust(2,'0') 
        w3dtfdate = "#{m[1]}-#{m[2]}-#{m[3]}T#{hour}:#{m[6]}:#{m[7]}+09:00"
        $stderr << "Nate date parsed as: %s\n" % w3dtfdate if $debug
        return parse_date_w3dtf(w3dtfdate)
      end

      def parse_date_mssql(dateString)
        mssql_date_re = /(\d{4})-(\d{2})-(\d{2})\s+(\d{2}):(\d{2}):(\d{2})(\.\d+)?/

        m = mssql_date_re.match(dateString)
        
        w3dtfdate =  "#{m[1]}-#{m[2]}-#{m[3]}T#{m[4]}:#{m[5]}:#{m[6]}+09:00"
        $stderr << "MS SQL date parsed as: %s\n" % w3dtfdate if $debug
        return parse_date_w3dtf(w3dtfdate)
      end

      def parse_date_greek(dateString)
        # Parse a string according to a Greek 8-bit date format
        # Unicode strings for Greek date strings
        greek_months = { 
          u("Ιαν") => u("Jan"),       # c9e1ed in iso-8859-7
          u("Φεβ") => u("Feb"),       # d6e5e2 in iso-8859-7
          u("Μάώ") => u("Mar"),       # ccdcfe in iso-8859-7
          u("Μαώ") => u("Mar"),       # cce1fe in iso-8859-7
          u("Απρ") => u("Apr"),       # c1f0f1 in iso-8859-7
          u("Μάι") => u("May"),       # ccdce9 in iso-8859-7
          u("Μαϊ") => u("May"),       # cce1fa in iso-8859-7
          u("Μαι") => u("May"),       # cce1e9 in iso-8859-7
          u("Ιούν") => u("Jun"), # c9effded in iso-8859-7
          u("Ιον") => u("Jun"),       # c9efed in iso-8859-7
          u("Ιούλ") => u("Jul"), # c9effdeb in iso-8859-7
          u("Ιολ") => u("Jul"),       # c9f9eb in iso-8859-7
          u("Αύγ") => u("Aug"),       # c1fde3 in iso-8859-7
          u("Αυγ") => u("Aug"),       # c1f5e3 in iso-8859-7
          u("Σεπ") => u("Sep"),       # d3e5f0 in iso-8859-7
          u("Οκτ") => u("Oct"),       # cfeaf4 in iso-8859-7
          u("Νοέ") => u("Nov"),       # cdefdd in iso-8859-7
          u("Νοε") => u("Nov"),       # cdefe5 in iso-8859-7
          u("Δεκ") => u("Dec"),       # c4e5ea in iso-8859-7
        }

        greek_wdays =   { 
          u("Κυρ") => u("Sun"), # caf5f1 in iso-8859-7
          u("Δευ") => u("Mon"), # c4e5f5 in iso-8859-7
          u("Τρι") => u("Tue"), # d4f1e9 in iso-8859-7
          u("Τετ") => u("Wed"), # d4e5f4 in iso-8859-7
          u("Πεμ") => u("Thu"), # d0e5ec in iso-8859-7
          u("Παρ") => u("Fri"), # d0e1f1 in iso-8859-7
          u("Σαβ") => u("Sat"), # d3e1e2 in iso-8859-7   
        }

        greek_date_format = /([^,]+),\s+(\d{2})\s+([^\s]+)\s+(\d{4})\s+(\d{2}):(\d{2}):(\d{2})\s+([^\s]+)/

        m = greek_date_format.match(dateString)
        
        wday = greek_wdays[m[1]]
        month = greek_months[m[3]]
       
        rfc822date = "#{wday}, #{m[2]} #{month} #{m[4]} #{m[5]}:#{m[6]}:#{m[7]} #{m[8]}" 
        $stderr << "Greek date parsed as: #{rfc822date}\n" if $debug
        return parse_date_rfc822(rfc822date) 
      end

      def parse_date_hungarian(dateString)
        # Parse a string according to a Hungarian 8-bit date format.
        hungarian_date_format_re = /(\d{4})-([^-]+)-(\d{0,2})T(\d{0,2}):(\d{2})((\+|-)(\d{0,2}:\d{2}))/
        m = hungarian_date_format_re.match(dateString)

        # Unicode strings for Hungarian date strings
        hungarian_months = { 
          u("január") =>   u("01"),  # e1 in iso-8859-2
          u("februári") => u("02"),  # e1 in iso-8859-2
          u("március") =>  u("03"),  # e1 in iso-8859-2
          u("április") =>  u("04"),  # e1 in iso-8859-2
          u("máujus") =>   u("05"),  # e1 in iso-8859-2
          u("június") =>   u("06"),  # fa in iso-8859-2
          u("július") =>   u("07"),  # fa in iso-8859-2
          u("augusztus") =>     u("08"),
          u("szeptember") =>    u("09"),
          u("október") =>  u("10"),  # f3 in iso-8859-2
          u("november") =>      u("11"),
          u("december") =>      u("12"),
        }
        month = hungarian_months[m[2]]
        day = m[3].rjust(2,'0')
        hour = m[4].rjust(2,'0')

        w3dtfdate = "#{m[1]}-#{month}-#{day}T#{hour}:#{m[5]}:00#{m[6]}"
        $stderr << "Hungarian date parsed as: #{w3dtfdate}\n" if $debug
        return parse_date_w3dtf(w3dtfdate)
      end

      def rollover(num, modulus)
        return num % modulus, num / modulus
      end

      def set_self(num, modulus)
        r = num / modulus
        if r == 0
          return num
        end
        return r
      end
      
      # W3DTF-style date parsing
      def parse_date_w3dtf(dateString)
        # Ruby's Time docs claim w3cdtf is an alias for iso8601 which is an alias for xmlschema
        # Whatever it is, it doesn't work.  This has been fixed in Ruby 1.9 and 
        # in Ruby on Rails, but not really. They don't fix the 25 hour or 61 minute or 61 second rollover and fail in other ways.

        m = dateString.match(/^(\d{4})-?(?:(?:([01]\d)-?(?:([0123]\d)(?:T(\d\d):(\d\d):(\d\d)(?:\.\d+)?([+-]\d\d:\d\d|Z))?)?)?)?/)

        w3 = m[1..3].map{|s| s=s.to_i; s += 1 if s == 0;s}  # Map the year, month and day to integers and, if they were nil, set them to 1
        w3 += m[4..6].map{|s| s.to_i}			  # Map the hour, minute and second to integers
        w3 << m[-1]					  # Leave the timezone as a String

        # FIXME this next bit needs some serious refactoring
        # Rollover times. 0 minutes and 61 seconds -> 1 minute and 1 second
        w3[5],r = rollover(w3[5], 60)     # rollover seconds
        w3[4] += r
        w3[4],r = rollover(w3[4], 60)      # rollover minutes
        w3[3] += r
        w3[3],r = rollover(w3[3], 24)      # rollover hours

        w3[2] = w3[2] + r
        if w3[1] > 12
          w3[1],r = rollover(w3[1],12)
          w3[1] = 12 if w3[1] == 0
          w3[0] += r
        end

        num_days = Time.days_in_month(w3[1], w3[0])
        while w3[2] > num_days
          w3[2] -= num_days
          w3[1] += 1
          if w3[1] > 12
            w3[0] += 1
            w3[1] = set_self(w3[1], 12)
          end
          num_days = Time.days_in_month(w3[1], w3[0])
        end


        unless w3[6].class != String
          if /^-/ =~ w3[6] # Zone offset goes backwards
            w3[6][0] = '+'
          elsif /^\+/ =~ w3[6]
            w3[6][0] = '-'
          end
        end
        return Time.utc(w3[0], w3[1], w3[2] , w3[3], w3[4], w3[5])+Time.zone_offset(w3[6] || "UTC")
      end

      def parse_date_rfc822(dateString)
        # Parse an RFC822, RFC1123, RFC2822 or asctime-style date 
        # These first few lines are to fix up the stupid proprietary format from Disney
        unknown_timezones = { 'AT' => 'EDT', 'ET' => 'EST', 
          'CT' => 'CST', 'MT' => 'MST', 
          'PT' => 'PST' 
        }

        mon = dateString.split[2]
        if mon.length > 3 and Time::RFC2822_MONTH_NAME.include?mon[0..2]
          dateString.sub!(mon,mon[0..2])
        end
        if dateString[-3..-1] != "GMT" and unknown_timezones[dateString[-2..-1]]
          dateString[-2..-1] = unknown_timezones[dateString[-2..-1]]
        end

        # Okay, the Disney date format should be fixed up now.
        rfc_tz = '([A-Za-z]{3}|[\+\-]?\d\d\d\d)'
        rfc = dateString.match(/([A-Za-z]{3}), ([0123]\d) ([A-Za-z]{3}) (\d{4})( (\d\d):(\d\d)(?::(\d\d))? #{rfc_tz})?/)

        if rfc.to_a.length > 1 and rfc.to_a.include? nil
          dow, day, mon, year, hour, min, sec, tz = rfc[1..-1]
          hour,min,sec = [hour,min,sec].map{|e| e.to_s.rjust(2,'0') }
          tz ||= "GMT"
        end

        asctime_match = dateString.match(/([A-Za-z]{3}) ([A-Za-z]{3})  (\d?\d) (\d\d):(\d\d):(\d\d) ([A-Za-z]{3}) (\d\d\d\d)/).to_a
        if asctime_match.to_a.length > 1
          # Month-abbr dayofmonth hour:minute:second year
          dow, mon, day, hour, min, sec, tz, year = asctime_match[1..-1]
          day.to_s.rjust(2,'0')
        end

        if (rfc.to_a.length > 1 and rfc.to_a.include? nil) or asctime_match.to_a.length > 1
          ds = "#{dow}, #{day} #{mon} #{year} #{hour}:#{min}:#{sec} #{tz}"
        else
          ds = dateString
        end
        t = Time.rfc2822(ds).utc
        return t
      end

      def parse_date_perforce(aDateString) # FIXME not in 4.1?
        # Parse a date in yyyy/mm/dd hh:mm:ss TTT format
        # Note that there is a day of the week at the beginning 
        # Ex. Fri, 2006/09/15 08:19:53 EDT
        return Time.parse(aDateString).utc
      end

      def extract_tuple(atime)
        return unless atime
        # NOTE leave the error handling to parse_date
        t = [atime.year, atime.month, atime.mday, atime.hour,
          atime.min, atime.sec, (atime.wday-1) % 7, atime.yday,
          atime.isdst
        ]
        # yay for modulus! yaaaaaay!  its 530 am and i should be sleeping! yaay!
        t[0..-2].map!{|s| s.to_i}
        t[-1] = t[-1] ? 1 : 0
        return t
      end

      def parse_date(dateString)
        @@date_handlers.each do |handler|
          begin 
            $stderr << "Trying date_handler #{handler}\n" if $debug
            datething = send(handler,dateString)
            return datething
          rescue => e
            $stderr << "#{handler} raised #{e}\n" if $debug
          end
        end
        return nil
      end
    end
  end
end