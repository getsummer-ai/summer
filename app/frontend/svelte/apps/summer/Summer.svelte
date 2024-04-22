<script lang="ts">
  import { onMount } from 'svelte';
  import { initApi } from './api';
  import type { ArticleInitInfo, SettingsInfo, ProjectProductType } from './api';
  import Modal from './Modal.svelte';
  import ProjectProduct from './ProjectProduct.svelte';
  import SubscriptionBlock from './SubscriptionBlock.svelte';
  import markdown from './markdown.js';

  /* eslint svelte/no-at-html-tags: 0 */
  let showModal = false;
  export let projectId: string;
  export let settings: SettingsInfo;
  export let article: ArticleInitInfo;
  let summary: string = '';
  let services: ProjectProductType[] = [];
  let isSummaryCompleted: boolean = false;
  // let button: HTMLButtonElement;
  let loading = false;
  let showButton = false;
  let buttonStyles = hideButton();

  const api = initApi(projectId);

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
      // console.log(settings, summary);
      showModal = true;
      buttonStyles.opacity = 0;
    }, delay);
  };

  const onButtonClick = () => {
    if (loading) return;
    if (summary) return openModal();
    loading = true;
    isSummaryCompleted = false;
    try {
      const summaryStore = api.getSummary(article.page_id);

      summaryStore.result.subscribe((value) => {
        summary += value;
      });

      summaryStore.isCompleted.subscribe((v) => {
        if (v !== true) return;
        isSummaryCompleted = true;
        retrieveProducts();
      });
      // summary = atob(summaryInfo.article.summary);
      openModal(100);
    } catch (error) {
      // console.log(error);
      loading = false;
    }
  };

  const retrieveProducts = async () => {
    if (!isSummaryCompleted) return;
    if (!settings.features.suggestion) return;
    try {
      const res = await api.getServices(article.page_id);
      // console.log(res);
      if (res.body?.hasOwnProperty('services')) services = res.body.services;
    } catch (error) {
      console.log(error);
      // loading = false;
    }
  };

  const closeModal = () => {
    loading = false;
    showModal = false;
    setTimeout(() => (buttonStyles.opacity = 1), 500);
  };
</script>

<svelte:head>
  <link
    href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600&display=swap"
    rel="stylesheet"
  />
</svelte:head>

<button
  class="getsummer-btn radius-{settings.appearance.button_radius} theme-{settings.appearance.button_theme}"
  style="opacity: {buttonStyles.opacity};"
  on:click={onButtonClick}
>
  {#if loading}
    <span class="loading-icon" />
    Summarizing
  {:else}
    Summarize
  {/if}
</button>

{#if showButton}
  <Modal bind:showModal on:close={closeModal} theme={settings.appearance.frame_theme}>
    {@html markdown(summary)}

    {#if settings.features.suggestion && services.length > 0}
      {#each services as service}
        <ProjectProduct
          {service}
          pageId={article.page_id}
          theme={settings.appearance.frame_theme}
        />
      {/each}
    {/if}
    <svelte:fragment slot="footer">
      {#if settings.features.subscription === true}
        <SubscriptionBlock theme={settings.appearance.frame_theme} bind:article />
      {/if}
    </svelte:fragment>
  </Modal>
{/if}

<style lang="scss">
  :global(*) {
    font-family: 'Inter', ui-sans-serif, system-ui, sans-serif;
    box-sizing: border-box;
    border-width: 0;
    border-style: solid;
    letter-spacing: -0.01rem;
  }

  .getsummer-btn {
    @apply text-base text-white select-none cursor-pointer;
    padding: 4px 12px;
    position: fixed;
    z-index: 30;
    transition: opacity 0.3s;
    left: calc(50% - 50px);
    bottom: 20px;
    box-shadow: 0 36px 60px 0 rgba(0, 0, 0, 0.18), 0 13.902px 18.888px 0 rgba(0, 0, 0, 0.12),
      0 6.929px 11.218px 0 rgba(0, 0, 0, 0.1), 0 3.621px 7.444px 0 rgba(0, 0, 0, 0.08),
      0 1.769px 4.735px 0 rgba(0, 0, 0, 0.06), 0 0.664px 2.345px 0 rgba(0, 0, 0, 0.03);
    backdrop-filter: blur(4px);

    &.theme-white {
      @apply text-black;
      border: 1px solid rgba(255, 255, 255, 0.4);
      background: linear-gradient(
        123deg,
        rgba(242, 242, 242, 0.85) 26.16%,
        rgba(255, 255, 255, 0.85) 75.51%
      );
    }

    &.theme-black {
      @apply text-white;
      border: 1px solid rgba(255, 255, 255, 0.2);
      background: rgba(0, 0, 0, 0.85);
    }

    &.radius-sm {
      @apply rounded-sm;
    }

    &.radius-xl {
      @apply rounded-3xl;
    }

    &.radius-lg {
      @apply rounded-xl;
    }

    .loading-icon {
      @apply loading loading-spinner loading-xs;
    }
  }
</style>
