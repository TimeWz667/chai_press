<template>
<div>
  <select v-model="sel_channel">
    <option v-for="option in Object.keys(algs)" v-bind:value="option">
      {{ option }}
    </option>
  </select>
  <select v-model="sel_year">
    <option v-for="option in years" v-bind:value="option">
      {{ option }}
    </option>
  </select>
  <br>
  <span>Selected: {{ sel_channel }}</span>
  <span>Selected: {{ sel_year }}</span>
</div>
</template>

<script>


export default {
  name: "channel",
  props: {
    algs: Object
  },
  data: function() {
    return {
      years: [2022, 2023, 2024, 2025, 2026, 2027],
      sel_year: 2022,
      sel_channel: "Channel 1"
    };
  }
}
</script>
