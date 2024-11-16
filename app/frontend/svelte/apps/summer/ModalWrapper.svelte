<script lang="ts">
  import markdown from './markdown.js';
  import Modal from './Modal.svelte';
  import LoadingIcon from './components/LoadingIcon.svelte';
  import ProjectProduct from './components/ProjectProduct.svelte';
  import SubscriptionBlock from './components/SubscriptionBlock.svelte';
  import ErrorBlock from './components/ErrorBlock.svelte';
  import { createEventDispatcher } from 'svelte';
  import type { ArticleInitInfo, ProjectProductType, SettingsInfo } from '@/svelte/apps/summer/types';
  import { useI18n } from '@/svelte/apps/helpers/use-i18n';
  /* eslint svelte/no-at-html-tags: 0 */

  const dispatch = createEventDispatcher();

  export let showModal = false;
  export let settings: SettingsInfo;
  export let article: ArticleInitInfo;
  export let summary: string = '';
  export let services: ProjectProductType[] = [];

  const messages = {
    en: {
      something_went_wrong: 'Whooops, something went wrong.',
      cant_be_displayed: "The summary can't be displayed now.",
      try_again_later: 'Try again or check the full article.',
      powered_by: 'Powered by',
    },
    es: {
      something_went_wrong: 'Ups, algo salió mal.',
      cant_be_displayed: 'El resumen no se puede mostrar ahora',
      try_again_later: 'Inténtalo de nuevo o revisa el artículo completo.',
      powered_by: 'Desarrollado por',
    },
  };

  $: t = useI18n(messages, settings.lang);
  $: isError = summary.includes('--ERROR--');
</script>

<Modal
  bind:showModal
  poweredByText={t('powered_by')}
  on:close={() => dispatch('close')}
  title={article.title}
  theme={settings.appearance.frame_theme}
  style={`z-index: ${settings.appearance.z_index}`}
>
  {#if isError}
    <ErrorBlock>
      {t('something_went_wrong')} <br />
      {t('cant_be_displayed')} <br />
      {t('try_again_later')}
    </ErrorBlock>
  {:else}
    {#if summary.length === 0}
      <div class="loading-block">
        <LoadingIcon
          width={40}
          strokeColor={settings.appearance.frame_theme === 'white' ? 'black' : 'white'}
        />
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
      <SubscriptionBlock bind:article {settings} />
    {/if}
  </svelte:fragment>
</Modal>

<style lang="scss">
  .loading-block {
    @apply text-center;
    padding-top: 100px;
    opacity: 0.4;

    @media (max-width: 640px) {
      padding-top: 120px;
    }
  }
</style>
