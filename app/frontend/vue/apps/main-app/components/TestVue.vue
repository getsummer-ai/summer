<script lang="ts" setup>
import { ref } from 'vue';
defineProps<{ url: string | null }>();

const A = ref(1);
</script>
<template>
  <div class="d-block">
    <h1 class="text-sm">
      {{ A }}Test Vue
      <input v-model="A" />
      {{ url }}
    </h1>
  </div>
</template>
