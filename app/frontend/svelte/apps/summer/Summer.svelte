<script lang="ts">
  import { onMount } from 'svelte';
  import { getSummary } from './store';
  import type { ArticleInitInfo, SettingsInfo } from './store';
  import Counter from '../lib/Counter.svelte';
  import Modal from './Modal.svelte';
  import markdown from './markdown.js';

  /* eslint svelte/no-at-html-tags: 0 */
  let showModal = false;
  export let project: string;
  export let settings: SettingsInfo;
  export let article: ArticleInitInfo;
  let summary: string = '';
  let button: HTMLButtonElement;
  let modalTitle: HTMLHeadingElement;
  let loading = false;
  let showButton = false;
  let buttonStyles = hideButton();
  onMount(async () => {
    document.querySelectorAll('h1, h2, h3').forEach((el) => {
      if (modalTitle === el) return;
      if (showButton || !el.innerHTML.includes(article.title)) return;
      const rect = el.getBoundingClientRect();
      buttonStyles = {
        left: rect.left + window.scrollX - (button.offsetWidth + 10),
        top: rect.top + window.scrollY,
        opacity: 1,
      };
      // console.log(buttonStyles, article.title, button.offsetWidth);
      showButton = true;
    });
  });

  function hideButton(): { left: number; top: number; opacity: number } {
    return {
      left: -200,
      top: 9999,
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

<button
  bind:this={button}
  class="getsummer-btn animate"
  style="left: {buttonStyles.left}px; top: {buttonStyles.top}px; opacity: {buttonStyles.opacity};"
  on:click={onButtonClick}
>
  {#if loading}
    <span class="loading loading-spinner loading-xs" />
    Summorizing
  {:else}
    Summorize
  {/if}
</button>

{#if showButton}
  <Modal bind:showModal on:close={closeModal}>
    <h2 slot="header" bind:this={modalTitle}>{article.title}</h2>
    {@html markdown(summary)}
    <Counter />
  </Modal>
{/if}

<style lang="scss">
  .getsummer-btn {
    @apply btn btn-sm btn-accent absolute transition-opacity duration-500 ease-in-out;
    &.animate {
      @apply animate-bounce;
      -webkit-animation-iteration-count: 2.5;
      animation-iteration-count: 2.5;
    }
  }
</style>
