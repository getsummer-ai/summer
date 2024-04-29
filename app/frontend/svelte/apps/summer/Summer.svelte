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
  let loading = false;
  let showButton = false;
  let buttonStyles = getButtonStyles();

  const api = initApi(projectId);

  onMount(async () => {
    if (showButton) return;
    showButton = true;
  });

  function getButtonStyles(width = 109): { width: string, left: number } {
    return {
      width: width === 0 ? 'auto' : `${width}px`,
      left: (width === 0 ? 146.3 : width) / 2,
    };
  }

  const openModal = async (delay = 100) => new Promise((resolve) => {
    setTimeout(() => {
      showModal = true;
      resolve();
      buttonStyles = getButtonStyles(87.5)
    }, delay);
  });

  const onButtonClick = async () => {
    if (loading) return;
    if (showModal) return closeModal();
    if (summary) return openModal();
    buttonStyles = getButtonStyles(0);

    loading = true;

    setTimeout(async () => {
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
        buttonStyles = getButtonStyles(146.3);
        await openModal(500);
      } catch (error) {
        // console.log(error);
      } finally {
        loading = false;
      }
    }, 300)
  };

  const retrieveProducts = async () => {
    if (!isSummaryCompleted) return;
    if (!settings.features.suggestion) return;
    try {
      const res = await api.getServices(article.page_id);
      if (res.body?.hasOwnProperty('services')) services = res.body.services;
    } catch (error) {
      console.log(error);
    }
  };

  const closeModal = () => {
    buttonStyles = getButtonStyles();
    loading = false;
    showModal = false;
  };
</script>

<svelte:head>
  <link
    href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600&display=swap"
    rel="stylesheet"
  />
</svelte:head>

<button
  class="getsummer-btn theme-{settings.appearance.button_theme} {showModal ? 'active' : ''}"
  on:click={onButtonClick} style="--summer-button-width: {buttonStyles.left + 'px'}; width: {buttonStyles.width}"
>
  {#if showModal}
    <svg class="icon" width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M8 8L12 12M12 12L8 16M12 12L16 16M12 12L16 8" stroke={settings.appearance.button_theme === 'white' ? 'black' : 'white'}/>
      <circle cx="12" cy="12" r="10.5" stroke={settings.appearance.button_theme === 'white' ? 'black' : 'white'} stroke-opacity="0.2"/>
    </svg>
    <span>Close</span>
  {:else if loading === true}
    <span class="loading-icon" />
    <span>Summarizing</span>
  {:else}
    Summarize
  {/if}
</button>

{#if showButton}
  <Modal bind:showModal on:close={closeModal} bind:title={article.title} theme={settings.appearance.frame_theme}>
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
  }

  @keyframes smooth-appear {
    0%, 50% {
      bottom: 10px;
      opacity: 0;
    }

    100% {
      bottom: 20px;
      opacity:1;
    }
  }

  .getsummer-btn {
    @apply text-white select-none cursor-pointer rounded-3xl;
    position: fixed;
    display: flex;
    align-items: center;
    justify-content: flex-start;
    padding: 4px 12px;
    font-size: 16px;
    line-height: 22px;
    text-align: left;
    height: 32px;
    left: calc(50% - var(--summer-button-width));
    bottom: 20px;
    box-shadow: 0 36px 60px 0 rgba(0, 0, 0, 0.18), 0 13.902px 18.888px 0 rgba(0, 0, 0, 0.12),
      0 6.929px 11.218px 0 rgba(0, 0, 0, 0.1), 0 3.621px 7.444px 0 rgba(0, 0, 0, 0.08),
      0 1.769px 4.735px 0 rgba(0, 0, 0, 0.06), 0 0.664px 2.345px 0 rgba(0, 0, 0, 0.03);
    backdrop-filter: blur(4px);
    transition: width 0.3s;
    animation: smooth-appear 400ms ease-in-out;
    z-index: 999;

    &.active {
      @media (max-width: 640px) {
        display: none;
      }
    }

    .icon {
      @apply ml-[-9px] mr-1;
    }

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

    .loading-icon {
      @apply loading loading-spinner loading-sm align-text-bottom mr-1;
    }

  }
</style>
