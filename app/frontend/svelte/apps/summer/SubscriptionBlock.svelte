<script lang="ts">
  import type { ArticleInitInfo } from './api';
  import { initApi } from './api';

  export let article: ArticleInitInfo;
  export let theme: string = 'white';
  let email = '';
  let loading = false;

  const subscribeUser = async () => {
    if (!email || loading) return;
    loading = true;
    try {
      const res = await initApi().subscribe(article.page_id, email);
      if (res.status == 200) email = '';
    } catch (error) {
      // console.log('error', error);
    } finally {
      loading = false;
    }
  };
</script>

<div class="theme-{theme}">
  <div>
    Subscribe on weekly summaries:
  </div>
  <div class="wrapper">
    <input placeholder="Your Email..." type="text" bind:value={email} />
    <button on:click={subscribeUser}>Subscribe</button>
  </div>
</div>

<style lang="scss">
  div {
    font-size: 15px;
    font-weight: 500;
    line-height: 22px;

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
</style>
