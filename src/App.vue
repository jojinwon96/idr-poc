<template>
  <WebHome/>
</template>

<script>
import WebHome from './views/WebHome.vue';

export default {
  name: 'App',
  components: {
    WebHome,
  }
}
</script>

<style>
  #app{
    max-width: 100%;
    width: 1400px;
    margin: 200px auto;
  }
</style>
