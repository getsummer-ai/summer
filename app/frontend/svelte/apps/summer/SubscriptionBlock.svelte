<script lang="ts">
  import type { ArticleInitInfo } from './api';
  import { initApi } from './api';

  export let article: ArticleInitInfo;
  export let theme: string = 'white';
  let email = '';
  let loading = false;
  let subscribeState = false;

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

<div class="subscription theme-{theme}">
  <div>
    Subscribe on weekly summaries:
  </div>
  <div class="wrapper">
    <input placeholder="Your Email..." type="text" bind:value={email} />
    {#if subscribeState}
      <button class="subscribed-state">Subscribed!</button>
    {:else}
      <button on:click={subscribeUser}>Subscribe</button>
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
        background: #0FA36E !important;
        color: #fff !important;
      }
    }

    &.theme-white {
      color: rgba(27, 27, 27, 0.50);
      .wrapper {
        background: #EFF2F4;
      }

      input {
        color: rgba(27, 27, 27, 0.60);
      }

      button {
        color: #FFF;
        background: rgba(27, 27, 27, 0.90);
      }
    }

    &.theme-black {
      color: rgba(255, 255, 255, 0.40);
      .wrapper {
        background: #323232;
      }

      input {
        color: rgba(255, 255, 255, 0.40);
      }

      button {
        color: #242424;
        background: rgba(255, 255, 255, 0.90);
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
