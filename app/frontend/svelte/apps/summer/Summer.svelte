<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import { initApi } from './api';
  import type { ArticleInitInfo, SettingsInfo, ProjectProductType } from './api';
  import Modal from './Modal.svelte';
  import ProjectProduct from './ProjectProduct.svelte';
  import SubscriptionBlock from './SubscriptionBlock.svelte';
  import ErrorBlock from './components/ErrorBlock.svelte';
  import CloseIcon from './components/CloseIcon.svelte';
  import LoadingIcon from './components/LoadingIcon.svelte';
  import markdown from './markdown.js';

  /* eslint svelte/no-at-html-tags: 0 */
  let showModal = false;
  export let projectId: string;
  export let rootDivId: string;
  export let settings: SettingsInfo;
  export let article: ArticleInitInfo;
  let summary: string = '';
  let button: HTMLButtonElement;
  let services: ProjectProductType[] = [];
  let isSummaryCompleted: boolean = false;
  let loading = false;
  let showButton = false;
  const rootDiv = document.getElementById(rootDivId);
  const api = initApi(projectId);

  $: isError = summary.includes('--ERROR--');
  $: strokeColor = settings.appearance.button_theme === 'white' ? 'black' : 'white';

  const mousewheelEvent = (e: WheelEvent) => {
    const target = e.target as HTMLElement;
    // console.log('mousewheel', e);
    if (showModal && target?.id === rootDivId) {
      // console.log('stopPropagation');
      return e.stopPropagation();
    }
  };

  onMount(async () => {
    if (showButton) return;
    showButton = true;
    rootDiv.addEventListener('mousewheel', mousewheelEvent);
  });

  onDestroy(() => {
    rootDiv.removeEventListener('mousewheel', mousewheelEvent);
  });

  const openModal = async (delay = 100) =>
    new Promise((resolve) => {
      setTimeout(() => {
        showModal = true;
        resolve();
      }, delay);
    });

  const onButtonClick = async () => {
    if (loading) return;
    if (showModal) return closeModal();
    if (summary) return openModal();

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
        await openModal(700);
      } catch (error) {
        // console.log(error);
      } finally {
        loading = false;
      }
    }, 300);
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
  bind:this={button}
  class="getsummer-btn theme-{settings.appearance.button_theme} {showModal ? 'active' : ''}"
  on:click={onButtonClick}
>
  {#if showModal}
    <CloseIcon class="btn-icon" {strokeColor} />
    <span>Close</span>
  {:else if loading === true}
    <LoadingIcon class="btn-icon" {strokeColor} />
    <span>Summarizing</span>
  {:else}
    Summarize
  {/if}
</button>

{#if showButton}
  <Modal
    bind:showModal
    on:close={closeModal}
    bind:title={article.title}
    theme={settings.appearance.frame_theme}
  >
    {#if isError}
      <ErrorBlock />
    {:else}
      {#if summary.length === 0}
        <div class="loading-block">
          <LoadingIcon width={40} {strokeColor} />
        </div>
      {/if}

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
    {/if}

    <svelte:fragment slot="footer">
      {#if summary.length && settings.features.subscription === true}
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

  :global(.btn-icon) {
    @apply ml-[-9px] mr-1;
  }

  @keyframes smooth-appear {
    0%,
    50% {
      bottom: 10px;
      opacity: 0;
    }

    100% {
      bottom: 20px;
      opacity: 1;
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
    word-break: keep-all;
    left: 50%;
    transform: translateX(-50%);
    bottom: 20px;
    box-shadow: 0 36px 60px 0 rgba(0, 0, 0, 0.18), 0 13.902px 18.888px 0 rgba(0, 0, 0, 0.12),
      0 6.929px 11.218px 0 rgba(0, 0, 0, 0.1), 0 3.621px 7.444px 0 rgba(0, 0, 0, 0.08),
      0 1.769px 4.735px 0 rgba(0, 0, 0, 0.06), 0 0.664px 2.345px 0 rgba(0, 0, 0, 0.03);
    backdrop-filter: blur(4px);
    animation: smooth-appear 400ms ease-in-out;
    z-index: 10001;

    &.active {
      @media (max-width: 640px) {
        display: none;
      }
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
  }

  .loading-block {
    @apply text-center;
    padding-top: 100px;
    opacity: 0.4;

    @media (max-width: 640px) {
      padding-top: 120px;
    }
  }
</style>
