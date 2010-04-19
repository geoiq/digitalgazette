# GeocommonsSearch

require 'will_paginate'
require 'acts_as_solr'

module GeocommonsSearch
  class Search
    def Search.execute(query, options = {})
      results = {
        :docs => [],
        :total => 0
      }
      
      query = build_query(query, options)

      RAILS_DEFAULT_LOGGER.debug "GeocommonsSearch query: #{query}"
      
      sort = []
      sort = options[:sort] unless options[:sort].blank?
      
      # puts query
      #per_page = options[:per_page] || 30
      #start = ((options[:page] || 1) - 1) * per_page
      rows = options[:limit]
      start = options[:offset]
      r = Solr::Request::Standard.new(:query => query, :rows => rows, :start => start, :sort => sort)

      q = ActsAsSolr::Post.execute(r)
      # sometimes, we get back true during testing, instead of results; I have no idea why - APS
      return results if q == true
      
      q.docs.each { |doc|
        class_name = doc['type_s'].first
        
        h = {}
        
        doc.each { |a| 
          att_name = a.first.gsub(/\_.$/, '')
          #unless att_name == "id"
          if a.last.class.name == "Array"
            if Search.multi_value_field?(att_name)
              att_data = a.last 
            else
              att_data = a.last.first
            end 
          else
            att_data = a.last
          end
          h[att_name] = att_data
          #end
        }
        

        results[:docs] << h
      }
      
      results[:total] = q.total_hits

      return results
      
    end 

    def Search.paginate(*args, &block)
      options = args.extract_options!
      options.symbolize_keys!
      page, per_page, total_entries = GeocommonsSearch::Search.wp_parse_options(options)
      
      WillPaginate::Collection.create(page, per_page, total_entries) do |pager|
        count_options = options.except(:page, :per_page, :total_entries, :finder)
        find_options = count_options.except(:count).update(:offset => pager.offset, :limit => pager.per_page)

        args << find_options.symbolize_keys # else we may break something
        found = execute(*args, &block)
        pager.total_entries = found[:total]
        found = found[:docs]
        pager.replace found
      end
      
    end
    
    def Search.wp_parse_options(options) #:nodoc:
      raise ArgumentError, 'parameter hash expected' unless options.respond_to? :symbolize_keys
      options = options.symbolize_keys
      raise ArgumentError, ':page parameter required' unless options.key? :page
      
      if options[:count] and options[:total_entries]
        raise ArgumentError, ':count and :total_entries are mutually exclusive'
      end

      page     = options[:page].to_i || 1
      per_page = options[:per_page].to_i || 30
      total    = options[:total_entries]
      page = [page,1].max # bug if page is 0
      [page, per_page, total]
    end
    
    def Search.tags_from_results(results)
      tags = {}
      results.each {|r|
        Search.indexed_tags_to_array(r,"&quot;").each { |t|
          tags[t] ||= 0
          tags[t] += 1
        } if r["indexed_tags"]
      }
      return tags.sort { |a,b| b[1]<=>a[1] }
    end
    
    def Search.indexed_tags_to_array(result,delim)
      # if result['type'] == 'Map'
      #   result["indexed_tags"].split(/\s*#{delim}(.*?)#{delim}\s*|\s+/)
      # else
        result["indexed_tags"].split(/\,\s*/)
      # end
    end

    protected

    def self.build_query(query, options)
      options = options.merge(extract_bbox_options_from_query_string(query))
      query = parse_query(query)
      query = clean_query(query)

      if (options[:models])
        query = add_to_query(query) {
          models = options[:models].collect { |m| m = "type_s:#{m}"}
          models.join(" OR ")
        }
      end

      time = ""
      if(options.include?(:since) || options.include?(:until))
        time += "created_at_t:["
        if(options[:since])
          time += "#{options[:since]} TO "
        else
          time += "* TO "
        end
        if(options[:until])
          time += "#{options[:until]}]"
        else
          time += "NOW]"
        end
      end
      query = add_to_query(query, time) unless time.blank?

      if (options[:source])
        query = add_to_query(query, "datasource_t:\"#{options[:source]}\"")
      end
      
      if (options[:user_login])
        query = add_to_query(query, "user_login_s:\"#{options[:user_login]}\"")
      end

      if (options[:id])
        query = add_to_query(query, "id_s:\"#{options[:id]}\"")
      end
      
      if(options[:groups])
        query = add_to_query(query) do
          group_options = ""
          permission = options[:filter_restricted] ? 'download' : 'view'
          options[:groups].each do |x|
            group_options += " OR " unless group_options.blank?
            group_options += %Q[ #{permission}_group_ids_i:"#{x}" ]
          end
          group_options
        end
      end
      
      if (options[:state])
        if options[:state].kind_of? Array
          query = add_to_query(query, options[:state].map{ |state| "state_t:#{state}" }.join(' OR '), options[:not_state] || false)
        else
          query = add_to_query(query, "state_t:#{options[:state]}", options[:not_state] || false)
        end
      end

      if (options[:wherein])
        options[:wherein].each_pair do |field, values|
          next nil if values.empty?
          query = add_to_query(query) {
            values.map { |value|
              value = %Q["#{value}"] if value.kind_of? String
              "#{field}:#{value}"
            }.join(' OR ')
          }
        end
      end

      if options[:in]
        minlng, minlat, maxlng, maxlat = options[:in]
        query = add_to_query(query, "min_latitude_rf:[#{minlat} TO #{maxlat}]")
        query = add_to_query(query, "max_latitude_rf:[#{minlat} TO #{maxlat}]")
        query = add_to_query(query, "min_longitude_rf:[#{minlng} TO #{maxlng}]")
        query = add_to_query(query, "max_longitude_rf:[#{minlng} TO #{maxlng}]")
      end

      # Cull out platial for now
      unless(query[/platial/i])
        query = add_to_query(query,"platial",true)
      end
      
      #unless options[:show_copies]
      #  if (options[:user_login])
      #    query = add_to_query(query, "is_copy_b:false OR user_login_s:\"#{options[:user_login]}\"")
      #  else
      #    query = add_to_query(query, "is_copy_b:false")
      #  end
      #end
      query
    end

    def self.add_to_query(query, term = nil, negate = false)
      term = yield if block_given?

      unless term.blank?
        query += " AND " unless query.blank?
        query += "-" if negate
        query += "(#{term})"
      end
      query
    end

    def Search.parse_query(query)
      terms = query.split(" ")
      new_terms = []
      terms.each { |t|
        if t.include? ":"
          ts = t.split(":")
          if (ts.length == 2)
            field = map_field(ts[0])
            term = clean_term(ts[1])
            if (field && !term.blank?)
              new_terms << "#{field}:#{term}"
            else 
              new_terms << term
            end                          
          end
        else
          t = clean_term(t)
          new_terms << t if t.length > 0
        end
      }
      return "(#{new_terms.join(" ")})" if new_terms.length > 0
      return ""
    end
    
    # This function cleans individual words
    def Search.clean_term(term)
      t = term
      # Strip slashes
      t.gsub!(/\/|\\/, '')
      # strip beginning asterisks
      t.gsub!(/^\*/, '')
      # strip exclamations
      t.gsub!(/\!/, '')
      
      # strip other characters
      t.gsub!(/\{|\}|\?|\;/, "")
      
      # Uppercase ORs and ANDs
      t.upcase! if (t == "or" || t == "and")
      return t
    end
    
    # This is to clean the whole query
    def Search.clean_query(query)

      
      # Strip quotes if the term includes an odd number of quotes
      query.gsub!(/\"/, "") unless ((query.count("\"") % 2) == 0)
      #query.gsub(/\"|\[|\]|\{|\}|\?|\;/, "")
      # Strip parenthesis if needed
      if ((query.count("\(") - query.count("\)")) != 0)
        query.gsub!(/(?:\(|\))/, '') 
        query = "(#{query})" unless query.blank?
      end

      return query
            
    end

    BBOX_REGEX = /bbox:\[([\d\s.,-]+)\]/
    def self.extract_bbox_options_from_query_string(query)
      match = BBOX_REGEX.match(query)
      if match
        query[BBOX_REGEX] = ""
        { :in => match[1].split(',').map(&:strip).map(&:to_f) }
      else
        {}
      end
    end
    
    def Search.map_field(field_name)
      # puts "FIELD_NAME: #{field_name}\n"
      return "user_id_i" if (field_name == "user_id_i")
      return "shared_b" if (field_name == "shared_b")
      return "description_t" if field_name == "description"
      return "title_t" if field_name == "title"
      return "sortable_name_s" if field_name == "sortable_name"
      return "indexed_tags_t" if field_name.include?("tag")
      return "lineage_t" if (field_name == "lineage" || field_name == "source")
      return "overlay_name_s" if (field_name.include?("overlay") || field_name == "name")
      return "user_login_s" if (field_name == "user" || field_name.include?("creator")|| field_name.include?("uploader") || field_name.include?("login"))
      return "contact_name_t" if (field_name.include?("contact"))
      return "max_latitude_rf" if (field_name.include?("maxlat"))
      return "max_longitude_rf" if (field_name.include?("maxlng"))
      return "min_latitude_rf" if (field_name.include?("minlat"))
      return "min_longitude_rf" if (field_name.include?("minlng"))
      return nil
    end
    
    def Search.multi_value_field?(field_name)
      return case field_name
        when "view_group_ids" then true
        when "edit_group_ids" then true
        when "download_group_ids" then true
        else false
      end          
    end
  end  
end