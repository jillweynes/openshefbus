$keys = File.read("keys.txt").split

get "/" do
    "Hello world"
end
get "/data/:route" do
    get_response_header(request,response)
    tmp = "{\"data\": ["


    tmp += worker("7035", params[:route],"Stagecoach")
    tmp += worker("7889", params[:route], "First")
    tmp += worker("7346", params[:route], "TM Travel")
    tmp += "{}]}"
    return tmp
end
def worker(id, route, name)
    tmp = ""
    response = RestClient.get("https://data.bus-data.dft.gov.uk/api/v1/datafeed/"+id+"/?api_key=" + $keys[0])
    @doc = Nokogiri::XML(response)
    #@block = @doc.css("MonitoredVehicleJourney").map { |node| node.children.text }
    #puts @block
    content_type :json
  
  
    
    @block = @doc.css("MonitoredVehicleJourney").each do |node|
        #puts node.css("LineRef").children.text
        if (node.css("LineRef").children.text == route)
            tmp += "{"
            tmp+= "\"lat\" : \"" + node.css("VehicleLocation Latitude").children.text + "\","
            tmp += "\"lon\" : \"" + node.css("VehicleLocation Longitude").children.text  + "\","
            tmp += "\"id\" : \""+ name + "\","
            tmp += "\"bound\" : \"" + node.css("DirectionRef").children.text + "\""
            tmp += "}, \n"
        end
    end
    return tmp
end


get "/route/:route" do
    get_response_header(request,response)
    content_type :json
    rt = params[:route]
    rt.delete_suffix!("a")

    work = "{\"data\": ["
    work += router(JSON.parse(File.readlines("db/route.json")[0]), rt)
    work += router(JSON.parse(File.readlines("db/route2.json")[0]),rt)
    work += router(JSON.parse(File.readlines("db/route3.json")[0]),rt)


work.delete_suffix!(",")
work += "]}"

end
def router(tmp,rt)
    work = ""
    tmp['features'].each do |child|
        if child["properties"]["service_name"] == rt
            work+="["
            child["geometry"]["coordinates"].each do |cood|
                #puts cood[0].to_s + ", " + cood[1].to_s
                work += "[" + cood[1].to_s  + ","
                work += cood[0].to_s + "],"
            end
            #break
            work.delete_suffix!(",")
            work+="],"
        end
    end
        return work
end
get "/dirs/" do
    time = Time.now.to_i.to_s
    dest = params[:dest]
    home = params[:home]
    get_response_header(request,response)
    response = RestClient.get("https://maps.googleapis.com/maps/api/directions/xml?alternatives=true&departure_time="+time+"&origin="+home+"&destination=place_id:"+dest+"&mode=transit&transit_mode=bus&key="+$keys[1])
    @doc = Nokogiri::XML(response)
    content_type :json
    tmp = "{\"data\": ["

    
    @doc.css("route").each do |rt|

        

        tmp += "{\"r\": ["
        rt.css("leg step").each do |node|
            if (node.css("travel_mode").children.text == "TRANSIT")
            
                tmp += "{"
                tmp+= "\"typ\" : \"" + "TRANSIT" + "\","
                name = "";
                bound = "UNKNOWN"

                if (!node.css("transit_details line short_name").children.text.empty?)
                    name = node.css("transit_details line short_name").children.text.delete_suffix(" Sheffield").delete_suffix(" PE∆KLINE")

                    fullname = node.css("transit_details line > name").children.text
                    header = node.css("transit_details > headsign").children.text
                    places = fullname.split("-")
                    
                    if (places != nil && places.length == 2)
                        # puts places[0] + " " + places[1] + " " + header
                        if (places[0].strip.upcase == header.upcase)
                            bound = "OUTBOUND"
                        elsif(places[1].strip.upcase == header.upcase)
                            bound = "INBOUND"
                        elsif(name == "120" && header.upcase == "CRYSTAL PEAKS" && places[1].strip.upcase == "HALFWAY")
                            # Override for common student bus
                            bound = "INBOUND"
                        end
                    end
                elsif (!node.css("transit_details line name").children.text.empty?)
                    name = node.css("transit_details line > name").children.text.delete_suffix(" Steel Link")
                end



                tmp+="\"rtname\" : \"" + name  + "\","
                tmp+="\"bound\" : \"" +  bound + "\","
                tmp+="\"depname\" : \"" +node.css("transit_details departure_stop name").children.text  + "\","
                tmp+="\"deploc\" : \"" +node.css("transit_details departure_stop location").children.text.delete!("\n")  + "\","
                tmp+="\"arrname\" : \"" +node.css("transit_details arrival_stop name").children.text  + "\","
                tmp+="\"arrloc\" : \"" +node.css("transit_details arrival_stop location").children.text.delete!("\n")  + "\""
                tmp += "},"
            end
        end
        tmp.delete_suffix!(",")
        tmp += "]},"
    end
    tmp.delete_suffix!(",")
    tmp += "]}"
    tmp
end
get "/search/" do
    dest = params[:dest]

    get_response_header(request,response)
    response = RestClient.get("https://maps.googleapis.com/maps/api/place/autocomplete/xml?input="+dest+"&key="+$keys[1])
    @doc = Nokogiri::XML(response)
    content_type :json
    tmp = "{\"data\": ["
  
 
        @doc.css("prediction").each do |node|

            
                tmp += "{"
                tmp+= "\"id\" : \"" + node.css("reference").text + "\","
                tmp+="\"name\" : \"" +node.css("> description").text  + "\""
                tmp += "},"
            

        end

    tmp.delete_suffix!(",")
    tmp += "]}"
    tmp
end
get '/time/:start/:end' do
    get_response_header(request,response)
    time = Time.now.to_i.to_s
    start = params[:start]
    en = params[:end]
    response = RestClient.get("https://maps.googleapis.com/maps/api/directions/xml?departure_time="+time+"&origin="+start+"&destination="+en+"&mode=car&key="+$keys[1])
    @doc = Nokogiri::XML(response)
    puts @doc.text
    content_type :json
    @doc.css("duration_in_traffic text").text
end
def get_response_header(request, response)
    origin_header = request.env['HTTP_ORIGIN']
    puts origin_header
    
    
    allowed = ['https://jillweynes.github.io','http://localhost:8000']
    found = 0
    counter = 0;
    allowed.each do |val|
        if (val == origin_header)
            found = counter
        end
        counter+=1
    end

    response['Access-Control-Allow-Origin'] = allowed[found]
    
end