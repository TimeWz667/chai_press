<template>
  <div>
    <inputs v-bind:src="Data"></inputs>
  </div>
</template>

<script>
import inputs from "./model/inputs";
import data from "../public/Inputs_India.json";

export default {
  name: "india",
  components: {
    inputs
  },
  data: function() {
    return {
      Data: data
    }
  }
}
</script>

<style scoped>

</style>