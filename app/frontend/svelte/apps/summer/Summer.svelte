<script lang="ts">
  import { onMount } from "svelte";
  import { getSummary } from './store';
  import type { ArticleInitInfo, SettingsInfo } from './store';
  import Counter from '../lib/Counter.svelte';
  import Modal from './Modal.svelte';

  /* eslint svelte/no-at-html-tags: 0 */
  let showModal = false;
  export let project: string;
  export let settings: SettingsInfo;
  export let article: ArticleInitInfo;
  let summary: string;

  onMount(async () => {
    try {
      console.log(settings)
      const summaryInfo = await getSummary(project, article.id);
      summary = atob(summaryInfo.article.summary);
      console.log(summary);
    } catch (error) {
      console.log(error);
    }
  });
</script>
<div class="bg-black text-white">
  <h1 class="button-text-xl">Hello!</h1>
  <div class="card">
    <Counter />
  </div>
  {#if summary}

    <button on:click={() => (showModal = true)}> show modal </button>

    <Modal bind:showModal>
      <h2 slot="header">
        modal
        <small><em>adjective</em> mod·al \ˈmō-dəl\</small>
      </h2>
      {@html summary}

      <a href="https://www.merriam-webster.com/dictionary/modal">merriam-webster.com</a>
    </Modal>
  {/if}
  <p class="read-the-docs">Click on the Vite and Svelte logos to learn more</p>
</div>
<style lang="postcss">
  .button-text-xl {
    @apply text-xl;
  }
  .read-the-docs {
    color: #888;
  }
</style>
