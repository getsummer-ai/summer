<script lang="ts">
  import type { ArticleInitInfo } from './api';
  import { initApi } from './api';

  export let article: ArticleInitInfo;
  export let theme: string = 'white';
  let email = '';

  const subscribeUser = async () => {
    try {
      const res = await initApi().subscribe(article.page_id, email);

      if (res.status == 200) {
        email = '';
        // return console.log('success');
        return;
      }
      // return console.log('error');
    } catch (error) {
      // console.log('error', error);
      return;
    }
  };
</script>

<div class="theme-{theme}">
  <input placeholder="Your Email..." type="text" bind:value={email} />
  <button on:click={subscribeUser}>Subscribe</button>
</div>

<style lang="scss">
  div {
    @apply flex justify-between;

    input {
      flex-grow: 1;
      height: 50px;
      font-size: 14px;
      padding: 10px 20px;
      background: none;
      border: none;
      outline: none;
      box-shadow: none;
    }
    button {
      height: 50px;
      padding: 0 20px;
      font-size: 14px;
      font-weight: 600;
      color: #000;
      background: transparent;
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
      input,
      button {
        color: #000;
      }
    }

    &.theme-black {
      input,
      button {
        color: #dedede;
      }
    }
  }
</style>
