<template>
<div>
  {{screen}}
  {{triage}}
</div>
</template>

<script>
export default {
  name: "pr-checker",
  data: function() {
    return {
      pr_drop_ini: 0.2,
      screen: {
        Sens: 0.9,
        Spec: 0.8
      },
      triage: {
        Sens: 0.9,
        Spec: 0.8
      }
    };
  }
}
</script>

<style scoped>

</style>