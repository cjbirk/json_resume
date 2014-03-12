#Hack to generalise call empty? on
#objects, arrays and hashes
class Object
	def empty?
		false
	end
end

module JsonResume
	class Formatter
    attr_reader :hash
    
		def initialize(hash)
      @hash = hash

      #recursively defined proc
			@hash_proc = Proc.new { |k,v| v ||= k
										case v
										when Hash, Array then v.delete_if(&@hash_proc); v.empty?
										else v.empty?
										end 
								}
		end

    def add_padding(course)
      unless @hash["bio_data"][course].nil?
        course_hash = @hash["bio_data"][course]
        course_hash << { "name"=>"", "url"=>"" } if course_hash.size % 2 == 1 
        @hash["bio_data"][course] = {
          "rows" => course_hash.each_slice(2).to_a.map{ |i| { "columns" => i } }
        }
      end
		end

    def add_last_marker_on_stars
			@hash["bio_data"]["stars"] = {
        "items" => @hash["bio_data"]["stars"].map{ |i| { "name" => i } }
      }
			@hash["bio_data"]["stars"]["items"][-1]["last"] = true
    end

		def cleanse
			@hash.delete_if &@hash_proc
      self
    end

		def format
      cleanse
     
      #make odd listed courses to even
			["grad_courses", "undergrad_courses"].each { |course| add_padding(course) }

      add_last_marker_on_stars
		end
	end
end    

