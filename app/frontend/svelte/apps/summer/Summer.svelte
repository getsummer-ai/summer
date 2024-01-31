<script lang="ts">
  import { onMount } from 'svelte';
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
  let button: HTMLButtonElement;
  let modalTitle: HTMLHeadingElement;
  let loading = false;
  let showButton = false;
  let styles = {
    left: 0,
    top: 0,
    display: 'none',
    position: 'fixed',
  };

  onMount(async () => {
    document.querySelectorAll('h1, h2, h3').forEach((el) => {
      if (modalTitle === el) return;
      if (showButton || !el.innerHTML.includes(article.title)) return;
      const rect = el.getBoundingClientRect();
      styles = {
        left: rect.left + window.scrollX - (button.getBoundingClientRect().width + 10),
        top: rect.top + window.scrollY,
        display: 'inline-block',
        position: 'absolute',
      };
      console.log(styles, article.title, el.innerHTML, el, modalTitle === el);
      showButton = true;
    });
  });

  const openModal = async () => {
    if (summary) {
      showModal = true;
      return;
    }
    loading = true;
    try {
      const summaryInfo = await getSummary(project, article.id);
      summary = atob(summaryInfo.article.summary);
      console.log(settings, summary);
      showModal = true;
    } catch (error) {
      console.log(error);
    } finally {
      loading = false;
    }
  };
</script>
<button
  bind:this={button}
  class="getsummer-btn"
  style="left: {styles.left}px; top: {styles.top}px; display: {styles.display}; position: {styles.position}"
  on:click={openModal}
>
  {loading ? 'Summorizing...' : 'Summorize'}
</button>

{#if showButton}
  <Modal bind:showModal>
    <h2 slot="header" bind:this={modalTitle}>{article.title}</h2>
    {@html summary}
    <Counter />
  </Modal>
{/if}
<style lang="scss">
  .getsummer-btn {
    @apply btn btn-ghost animate-bounce btn-sm;
  }
</style>
