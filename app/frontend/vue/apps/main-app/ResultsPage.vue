<script lang="ts" setup>
import { ref } from 'vue';
import TestVue from '@/vue/apps/main-app/components/TestVue.vue';

const A = ref(1);
</script>
<template>
  <div>
    <h1 class="text-xl">Results page 123 {{ A }}</h1>
  </div>
  <TestVue url="hello url" />
</template>
