<script>
    import { onMount } from "svelte";
    import Bus from "./Bus.svelte";


    let busData = [];
    let pins = [];
    let map = null;
    let greenIcon = null;
    let goldIcon = null;

    let host = null;
    let location = [];


    export async function refreshBusData() {
        console.log("refreshBusData");
        
        
        refreshRouteMaps();
        console.log("RM");
        addLocationsToMap();
        console.log("Loc");
        addStopLocations();
        console.log("LocS");

        loadUserLocation();
        console.log("User Loc");
        
    }
    export async function refreshLocationData() {
        for (let i = 0; i < pins.length; i++) {
            map.removeLayer(pins[i])
        }
        pins = [];
        addLocationsToMap();
        loadUserLocation();
    }
    function addStopLocations() {
        for (let i = 0; i < busData.length; i++) {
            let stcoods = busData[i]["deploc"].trim().split("      ");
            L.marker([stcoods[0].trim(), stcoods[1].trim()], {
                icon: greenIcon,
            })
                .addTo(map)
                .bindPopup("Start " + busData[i]["depname"]);
            stcoods = busData[i]["arrloc"].trim().split("      ");
            L.marker([stcoods[0].trim(), stcoods[1].trim()], {
                icon: greenIcon,
            })
                .addTo(map)
                .bindPopup("End " + busData[i]["arrname"]);
        }
    }
    async function refreshRouteMaps() {
        for (let i = 0; i < busData.length; i++) {
            let response = await fetch(host + "/route/" + busData[i].rtname);
            let { data } = await response.json();
            addRouteToMap(data);
        }
    }
    function addRouteToMap(lines) {
        for (let i = 0; i < lines.length; i++) {
            var colos = new Array("blue", "black");
            var colo = colos[0];
            L.polyline(lines[i]).addTo(map).setStyle({ color: colo });
        }
    }
    async function addLocationsToMap() {
        for (let i = 0; i < busData.length; i++) {
            let response = await fetch(host + "/data/" + busData[i].rtname);
            let { data } = await response.json();
            handleLocation(data, busData[i].rtname);
        }
    }
    function handleLocation(data, route) {
        for (let i = 0; i < data.length - 1; i++) {
            let lat = parseFloat(data[i]["lat"]);
            let lon = parseFloat(data[i]["lon"]);
            pins.push(
                L.marker([lat, lon])
                    .addTo(map)
                    .bindPopup(
                        "A " +
                            route +
                            " bus with " +
                            data[i]["id"] +
                            " direction " +
                            data[i]["bound"]
                    )
            );
        }
    }
    function loadUserLocation() {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition((position) => {
                location = [
                    position.coords.latitude,
                    position.coords.longitude
                ];
                addUserLocationToMap(location);

            });
        }
    }
    function addUserLocationToMap() {
        pins.push(L.marker([location[0], location[1]], { icon: goldIcon })
            .addTo(map)
            .bindPopup("Your Location")
            .openPopup());
    }

    export function load(data)  {
        console.log("load map");
        host = data.host;
        busData = data.r

        map = L.map("map").setView([51.505, -0.09], 13);

        L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
            attribution:
                '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
        }).addTo(map);

        greenIcon = new L.Icon({
            iconUrl:
                "https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-green.png",
            shadowUrl:
                "https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png",
            iconSize: [25, 41],
            iconAnchor: [12, 41],
            popupAnchor: [1, -34],
            shadowSize: [41, 41],
        });
        goldIcon = new L.Icon({
            iconUrl:
                "https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-gold.png",
            shadowUrl:
                "https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png",
            iconSize: [25, 41],
            iconAnchor: [12, 41],
            popupAnchor: [1, -34],
            shadowSize: [41, 41],
        });
        refreshBusData();
    }
</script>

<input type="button" value="Refresh" on:click={refreshLocationData} />

<div id="map" style="height: 900px; width:100%;" />

