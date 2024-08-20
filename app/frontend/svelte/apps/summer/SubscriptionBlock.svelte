<script lang="ts">
  import type { ArticleInitInfo, SettingsInfo } from './api';
  import { initApi } from './api';
  import { defineMessages, useI18n } from '@/svelte/apps/helpers/use-i18n';

  export let article: ArticleInitInfo;
  export let settings: SettingsInfo;
  let email = '';
  let loading = false;
  let subscribeState = false;

  const messages = defineMessages({
    en: {
      subscribe_on_weekly: 'Subscribe on weekly summaries:',
      your_email: 'Your Email...',
      subscribed: 'Subscribed!',
      subscribe: 'Subscribe',
    },
    es: {
      subscribe_on_weekly: 'Suscríbete a resúmenes semanales:',
      your_email: 'Tu Email...',
      subscribed: 'Subscrito!',
      subscribe: 'Suscribirse',
    },
  });

  export const t = useI18n(messages, settings.lang);

  const subscribeUser = async () => {
    if (!email || loading) return;
    loading = true;
    try {
      const res = await initApi().subscribe(article.page_id, email);
      if (res.status == 204) {
        email = '';
        subscribeState = true;
        setTimeout(() => {
          subscribeState = false;
        }, 1000);
      }
    } catch (error) {
      // console.log('error', error);
    } finally {
      loading = false;
    }
  };
</script>

<div class="subscription theme-{settings.appearance.frame_theme}">
  <div>
    {t('subscribe_on_weekly')}
  </div>
  <div class="wrapper">
    <input placeholder={t('your_email')} type="text" bind:value={email} />
    {#if subscribeState}
      <button class="subscribed-state"> {t('subscribed')} </button>
    {:else}
      <button on:click={subscribeUser}>{t('subscribe')}</button>
    {/if}
  </div>
</div>

<style lang="scss">
  .subscription {
    font-size: 15px;
    font-weight: 500;
    line-height: 22px;
    margin-top: 48px;
    animation: opacity-appear 0.2s ease-in-out;

    .wrapper {
      @apply flex justify-between;
      margin-top: 12px;
      border-radius: 74px;
      padding: 8px 8px 8px 20px;
    }

    input {
      flex-grow: 1;
      min-width: 30px;
      padding: 8px 16px 8px 0;
      font-size: 15px;
      font-weight: 500;
      line-height: 22px;
      background: none;
      border: none;
      outline: none;
      box-shadow: none;
    }
    button {
      border-radius: 100px;
      padding: 8px 16px;
      font-size: 15px;
      font-weight: 500;
      line-height: 22px;
      border: none;
      outline: none;
      cursor: pointer;
      &:hover {
        color: #555;
      }
      &:focus {
        color: #0b0bde;
      }

      &.subscribed-state {
        background: #0fa36e !important;
        color: #fff !important;
      }
    }

    &.theme-white {
      color: rgba(27, 27, 27, 0.5);
      .wrapper {
        background: #eff2f4;
      }

      input {
        color: rgba(27, 27, 27, 0.6);
      }

      button {
        color: #fff;
        background: rgba(27, 27, 27, 0.9);
      }
    }

    &.theme-black {
      color: rgba(255, 255, 255, 0.4);
      .wrapper {
        background: #323232;
      }

      input {
        color: rgba(255, 255, 255, 0.4);
      }

      button {
        color: #242424;
        background: rgba(255, 255, 255, 0.9);
      }
    }
  }

  @keyframes opacity-appear {
    from {
      opacity: 0;
    }
    to {
      opacity: 1;
    }
  }
</style>
