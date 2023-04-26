<script>
    import { onMount } from "svelte";

    import Route from "./Route.svelte";
    import Destination from "./Destination.svelte";

    let mode = 0;
    let host =
        "https://deploy.thankfulsmoke-89b0f183.northeurope.azurecontainerapps.io";
    let locations = [];

    //let host = "http://localhost:4567";

    let location = [];
    let destination = "";

    let query = "";

    function loadRoute() {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition((position) => {
                location = [
                    position.coords.latitude,
                    position.coords.longitude,
                ];
                //destination = "ChIJ3-vI8cF4eUgRytmt5y4g5JQ";

                var routes = new Route({
                    target: document.querySelector("#Rts"),
                });
                routes.load({
                    host: host,
                    location: location,
                    destination: destination,
                });

                mode = 1;
            });
        } else {
            alert("Geolocation is not supported by this browser.");
        }
    }
    function setLocation(loc) {
        destination = loc.id;
        console.log(loc.id);

        locations = [loc];
        loadRoute();
    }
    async function loadSearch() {
        let response = await fetch(host + "/search/" + "?dest=" + query);
        let { data } = await response.json();
        locations = data;
    }
    function goBackToRoutes() {
        document.querySelector("#Rts").innerHTML = "";
        console.log("cleared");
        loadRoute();
        document.querySelector("#Map").innerHTML = "";
    }
    function refreshPage() {
        document.location.reload();
    }
    const onEnterPress = (e) => {
        if (e.charCode === 13) loadSearch();
    };
</script>

<main>
    <h1>Open Shef Bus</h1>
    {#if mode == 0}
        <input type="text" bind:value={query} on:keypress={onEnterPress} />
        <input type="button" value="Search" on:click={loadSearch} />
    {/if}
    {#each locations as destination}
        <div on:click={setLocation(destination)} on:keypress={{}}>
            <Destination {destination} />
        </div>
    {/each}
    {#if mode == 1}
        <input type="button" value="Change Location" on:click={refreshPage} />
        <input type="button" value="Reload Routes" on:click={goBackToRoutes} />
    {/if}
    <div id="Rts" />
    <div id="Map" />
</main>
