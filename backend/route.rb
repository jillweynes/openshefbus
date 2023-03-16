$keys = File.read("keys.txt").split

get "/" do
    "Hello world"
end
get "/data/:route" do
    response['Access-Control-Allow-Origin'] = '*'
    tmp = "{\"data\": ["


    tmp += worker("7035", params[:route],"Stagecoach")
    tmp += worker("7889", params[:route], "First")
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
    response['Access-Control-Allow-Origin'] = '*'
    content_type :json
    rt = params[:route]
    rt.delete_suffix!("a")

    work = "{\"data\": ["
    work += router(JSON.parse(File.readlines("db/route.json")[0]), rt)
    work += router(JSON.parse(File.readlines("db/route2.json")[0]),rt)


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
    dest = params[:dest]
    home = params[:home]
    response['Access-Control-Allow-Origin'] = '*'
    response = RestClient.get("https://maps.googleapis.com/maps/api/directions/xml?alternatives=true&departure_time=1679904565&origin="+home+"&destination=place_id:"+dest+"&mode=transit&transit_mode=bus&key="+$keys[1])
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
                if (!node.css("transit_details line short_name").children.text.empty?)
                    name = node.css("transit_details line short_name").children.text.delete_suffix(" Sheffield")
                elsif (!node.css("transit_details line name").children.text.empty?)
                    name = node.css("transit_details line > name").children.text.delete_suffix(" Steel Link")
                end

                tmp+="\"rtname\" : \"" + name  + "\","
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

    response['Access-Control-Allow-Origin'] = '*'
    response = RestClient.get("https://maps.googleapis.com/maps/api/place/autocomplete/xml?input="+dest+"&key="+$keys[1])
    @doc = Nokogiri::XML(response)
    content_type :json
    tmp = "{\"data\": ["
  
 
        @doc.css("prediction").each do |node|

            
                tmp += "{"
                tmp+= "\"id\" : \"" + node.css("reference").text + "\","
                tmp+="\"name\" : \"" +node.css("description").text  + "\""
                tmp += "},"
            

        end


    tmp += "{}]}"
    tmp
end