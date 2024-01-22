<script lang="ts">
  import Counter from '@/svelte/apps/lib/Counter.svelte';
  let a = 123;
</script>
<div>
  <h1 class="text-xl">THIS IS BUTTON + {window.location.href} {a}</h1>

  <div class="card">
    <Counter />
  </div>

  <p class="read-the-docs">Click on the Vite and Svelte logos to learn more</p>
</div>
<style>
  .read-the-docs {
    color: #888;
  }
</style>
