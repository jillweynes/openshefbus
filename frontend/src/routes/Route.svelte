<script>
    import Bus from "./Bus.svelte";
    import Map from "./Map.svelte";

    let routeInfos = [];

    let location = [];
    let destination = "";
    let host = "";
    let counter = 0;

    export async function load(info) {
        console.log("Start Load");
        host = info.host;
        location = info.location;
        destination = info.destination;

        let response = await fetch(
            host +
                "/dirs/?home=" +
                location[0] +
                "," +
                location[1] +
                "&dest=" +
                destination
        );
        let { data } = await response.json();

        routeInfos = data;
    }
    async function select(rt) {
        console.log("here");
        var map = new Map({
            target: document.querySelector("#Map"),
        });

        console.log("here2");
        map.load({
            host: host,
            r: rt.r,
        });
        console.log("here3");
        routeInfos = [rt];
    }
</script>

<div>
    {#each routeInfos as rt}
        <div on:click={select(rt)} on:keypress={{}}>
            <p>Route:</p>
            {#each rt.r as bus}
                <Bus {bus} />
            {/each}
        </div>
    {/each}
</div>

<style>
    div div {
        background-color: lightgray;
        border-radius: 10px;
        padding: 10px;
        margin: 10px;
    }
    div div p {
        display: inline-block;
        line-height: 2.5;
    }
    div {
        display: flex;

        flex-direction: row;
    }

    @media (max-width: 800px) {
        div {
            flex-direction: column;
        }
    }
</style>
