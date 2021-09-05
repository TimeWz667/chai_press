<template>
  <div>
    <channel name="India India" v-bind:algs="Algorithms"></channel>
  </div>
</template>

<script>
import channel from "./model/channel";
import inputs from "../public/Inputs_India.json";

export default {
  name: "india",
  components: {
    channel
  },
  data: function() {
    return inputs;
  }
}
</script>

<style scoped>

</style>