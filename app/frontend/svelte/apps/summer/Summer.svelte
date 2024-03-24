<script lang="ts">
  import { onMount } from 'svelte';
  import { getSummary } from './store';
  import type { ArticleInitInfo, SettingsInfo } from './store';
  import Modal from './Modal.svelte';
  import markdown from './markdown.js';

  /* eslint svelte/no-at-html-tags: 0 */
  let showModal = false;
  export let project: string;
  export let settings: SettingsInfo;
  export let article: ArticleInitInfo;
  let summary: string = '';
  // let button: HTMLButtonElement;
  let loading = false;
  let showButton = false;
  let buttonStyles = hideButton();
  onMount(async () => {
    if (showButton) return;
    buttonStyles = {
      opacity: 1,
    };
    showButton = true;
  });

  function hideButton(): { opacity: number } {
    return {
      opacity: 0,
    };
  }

  const openModal = (delay = 100) => {
    setTimeout(() => {
      console.log(settings, summary);
      showModal = true;
      buttonStyles.opacity = 0;
    }, delay);
  };

  const onButtonClick = () => {
    if (loading) return;
    if (summary) return openModal();
    loading = true;
    try {
      const summaryStore = getSummary(project, article.id);
      summaryStore.subscribe((value) => {
        summary += value;
      });
      // summary = atob(summaryInfo.article.summary);
      openModal(100);
    } catch (error) {
      console.log(error);
      loading = false;
    }
  };

  const closeModal = () => {
    loading = false;
    showModal = false;
    setTimeout(() => (buttonStyles.opacity = 1), 500);
  };
</script>

<button class="getsummer-btn" style="opacity: {buttonStyles.opacity};" on:click={onButtonClick}>
  {#if loading}
    <span class="loading loading-spinner loading-xs" />
    Summorizing
  {:else}
    Summorize
  {/if}
</button>

{#if showButton}
  <Modal bind:showModal on:close={closeModal}>
    {@html markdown(summary)}
  </Modal>
{/if}

<style lang="scss">
  .getsummer-btn {
    @apply rounded-3xl text-base text-white select-none;
    padding: 4px 12px;
    position: fixed;
    transition: opacity 0.3s;
    left: calc(50% - 50px);
    bottom: 20px;
    border: 1px solid rgba(255, 255, 255, 0.2);
    background: rgba(0, 0, 0, 0.85);
    box-shadow: 0 36px 60px 0 rgba(0, 0, 0, 0.18), 0 13.902px 18.888px 0 rgba(0, 0, 0, 0.12),
      0 6.929px 11.218px 0 rgba(0, 0, 0, 0.1), 0 3.621px 7.444px 0 rgba(0, 0, 0, 0.08),
      0 1.769px 4.735px 0 rgba(0, 0, 0, 0.06), 0 0.664px 2.345px 0 rgba(0, 0, 0, 0.03);
    backdrop-filter: blur(4px);
  }
</style>
