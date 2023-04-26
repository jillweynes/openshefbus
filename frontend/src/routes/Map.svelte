<script>
    import { onMount } from "svelte";
    import Bus from "./Bus.svelte";

    let busData = [];
    let pins = [];
    let map = null;
    let arrivalIcon = null;
    let departureIcon = null;
    let locIcon = null;
    let busTick = null;
    let busQuestion = null;

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
            map.removeLayer(pins[i]);
        }
        pins = [];
        addLocationsToMap();
        loadUserLocation();
    }
    function addStopLocations() {
        for (let i = 0; i < busData.length; i++) {
            let stcoods = busData[i]["deploc"].trim().split("      ");
            L.marker([stcoods[0].trim(), stcoods[1].trim()], {
                icon: departureIcon,
            })
                .addTo(map)
                .bindPopup("Start " + busData[i]["depname"]);
            stcoods = busData[i]["arrloc"].trim().split("      ");
            L.marker([stcoods[0].trim(), stcoods[1].trim()], {
                icon: arrivalIcon,
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
            handleLocation(data, busData[i].rtname, busData[i].bound);
        }
    }
    function handleLocation(data, route, bound) {
        for (let i = 0; i < data.length - 1; i++) {
            let lat = parseFloat(data[i]["lat"]);
            let lon = parseFloat(data[i]["lon"]);
            if (bound.trim().toUpperCase() == "UNKNOWN") {    
                pins.push(
                    L.marker([lat, lon], {icon: busQuestion})
                        .addTo(map)
                        .bindPopup(
                            "A " +
                                route +
                                " bus with " +
                                data[i]["id"] +
                                " direction " +
                                data[i]["bound"] +
                                "\n. inbound or outbound could not be determined from google maps"
                        )
                );
            }
            else if ( data[i]["bound"].trim().toUpperCase() == bound.trim().toUpperCase()) {
                pins.push(
                    L.marker([lat, lon], {icon: busTick})
                        .addTo(map)
                        .bindPopup(
                            "A " +
                                route +
                                " bus with " +
                                data[i]["id"]
                        )
                );
            }
        }
    }
    function loadUserLocation() {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition((position) => {
                location = [
                    position.coords.latitude,
                    position.coords.longitude,
                ];
                addUserLocationToMap(location);
            });
        }
    }
    function addUserLocationToMap() {
        pins.push(
            L.marker([location[0], location[1]], { icon: locIcon })
                .addTo(map)
                .bindPopup("Your Location")
                .openPopup()
        );
    }

    export function load(data) {
        console.log("load map");
        host = data.host;
        busData = data.r;

        map = L.map("map").setView([51.505, -0.09], 13);

        L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
            attribution:
                '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
        }).addTo(map);

        locIcon = new L.Icon({
            iconUrl:
                "https://raw.githubusercontent.com/FortAwesome/Font-Awesome/6.x/svgs/solid/location-dot.svg",
            shadowUrl:
                "https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png",
            iconSize: [25, 41],
            iconAnchor: [12, 41],
            popupAnchor: [1, -34],
            shadowSize: [41, 41],
        });
        arrivalIcon = new L.Icon({
            iconUrl:
                "https://raw.githubusercontent.com/FortAwesome/Font-Awesome/6.x/svgs/solid/plane-arrival.svg",
            shadowUrl:
                "https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png",
            iconSize: [25, 41],
            iconAnchor: [12, 41],
            popupAnchor: [1, -34],
            shadowSize: [41, 41],
        });
        departureIcon = new L.Icon({
            iconUrl:
                "https://raw.githubusercontent.com/FortAwesome/Font-Awesome/6.x/svgs/solid/plane-departure.svg",
            shadowUrl:
                "https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png",
            iconSize: [25, 41],
            iconAnchor: [12, 41],
            popupAnchor: [1, -34],
            shadowSize: [41, 41],
        });
        busTick = new L.Icon({
            iconUrl:
                "https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/bus.svg",
            shadowUrl:
                "https://www.svgrepo.com/show/43432/tick.svg",
            iconSize: [25, 41],
            iconAnchor: [12, 41],
            popupAnchor: [1, -34],
            shadowSize: [10, 10],
        });
        busQuestion = new L.Icon({
            iconUrl:
                "https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/bus.svg",
            shadowUrl:
                "https://www.svgrepo.com/show/510152/question.svg",
            iconSize: [25, 41],
            iconAnchor: [12, 41],
            popupAnchor: [1, -34],
            shadowSize: [10, 10],
        });
        refreshBusData();
    }
</script>

<input type="button" value="Refresh" on:click={refreshLocationData} />

<div id="map" style="height: 900px; width:100%;" />

<style>
    #map {
        margin: 10px;
    }
</style>
