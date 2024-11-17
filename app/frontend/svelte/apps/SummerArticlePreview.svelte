<script lang="ts">
  import type { ArticleInitInfo, SettingsInfo, ProjectProductType } from './summer/types';
  import ModalWrapper from './summer/ModalWrapper.svelte';

  let showModal = false;
  export let settings: SettingsInfo;
  export let article: ArticleInitInfo;
  export let summary: string = '';
  export let services: ProjectProductType[] = [];
  let loading = false;

  const closeModal = () => {
    loading = false;
    showModal = false;
  };

  const onButtonClick = async () => {
    if (loading) return;
    loading = true;
    showModal = true;
  };
</script>

<svelte:head>
  <link
    href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600&display=swap"
    rel="stylesheet"
  />
</svelte:head>

<button class="btn btn-sm rounded-lg" on:click={onButtonClick}> Preview </button>

<ModalWrapper
  bind:showModal
  on:close={closeModal}
  testMode={true}
  {settings}
  {article}
  {summary}
  {services}
/>

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
</style>
