<script lang="ts">
  import { createEventDispatcher } from 'svelte';

  const dispatch = createEventDispatcher();

  function closeModal() {
    // () => (showModal = false)
    dispatch('close');
  }
  export let showModal = false; // boolean

  let dialog: HTMLDialogElement; // HTMLDialogElement

  $: if (dialog && showModal) dialog.showModal();
</script>

<!-- svelte-ignore a11y-click-events-have-key-events a11y-no-noninteractive-element-interactions -->
<dialog
  bind:this={dialog}
  on:close={closeModal}
  on:click|self={() => dialog.close()}
>
  <!-- svelte-ignore a11y-no-static-element-interactions -->
  <div class="dialog" on:click|stopPropagation>
    <button class="close" on:click={() => dialog.close()} tabindex="0"><span class="close__x"></span></button>
    <div class="body">
      <slot />
    </div>
    <div class="footer">
      <slot name="footer" />
    </div>
  </div>
</dialog>
<style lang="scss">
  dialog {
    width: 100%;
    max-width: 560px;
    padding: 0;
    border: none;
    border-radius: 16px;
    background: #FFF;
    font-size: 16px;
    line-height: 22px;
    font-style: normal;
    font-weight: 400;

    .dialog {
      position: relative;
      padding: 60px 0 0;
    }

    .body {
      position: relative;
      max-height: 70vh;
      overflow-y: auto;
      padding: 0 30px 30px 30px;
      transition: max-height 0.5s, height 0.5s;

      @media (max-height: 40px) {
        max-height: 20vh;
      }

      @media (max-height: 500px) {
        max-height: 40vh;
      }

      @media (max-height: 650px) {
        max-height: 50vh;
      }

      :global(ul) {
        margin: 0;
        padding: 0 0 0 15px;
        list-style-type: disc;
        list-style-position: outside;
      }
      :global(li)  {
        margin: 0 0 8px 0;
        padding: 0;
      }

      :global(p)  {
        margin: 0 0 8px 0;
        padding: 0;
        &:first-child {
          margin-bottom: 12px;
        }
      }
    }

    .footer {
      @apply relative z-10 min-h-12;
      box-shadow: 0px -25px 14px -11px #fff;
      -webkit-box-shadow: 0px -25px 14px -11px #fff;
      -moz-box-shadow: 0px -25px 14px -11px #fff;
      border-top: 1px solid #EFEFEF;
    }
  }
  dialog::backdrop {
    background: rgba(0, 0, 0, 0.3);
  }
  dialog[open] {
    animation: zoom 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
  }
  @keyframes zoom {
    from {
      transform: scale(0.95);
    }
    to {
      transform: scale(1);
    }
  }
  dialog[open]::backdrop {
    animation: fade 0.2s ease-out;
  }
  @keyframes fade {
    from {
      opacity: 0;
    }
    to {
      opacity: 1;
    }
  }

  .close {
    position: absolute;
    top: 12px;
    right: 12px;
    display: inline-block;
    width: 24px;
    height: 24px;
    text-align: center;
    cursor: pointer;
    background: rgba(0, 0, 0, 0.05);
    border-radius: 50%;
    transition: background-color 0.1s;
  }
  .close:hover {
    background: #e1e1e1;
  }
  .close__x {
    position: relative;
    top: 0;
    left: -0.5px;
    display: inline-block;
    width: 10px;
    height: 10px;
  }
  .close__x::before, .close__x::after {
    position: absolute;
    width: 1px;
    height: 10px;
    content: " ";
    background-color: black;
  }
  .close__x::before {
    transform: rotate(-45deg);
  }
  .close__x::after {
    transform: rotate(45deg);
  }
  .close:active {
    top: 11px;
    right: 11px;
    width: 26px;
    height: 26px;
    background: #e1e1e1;
  }
</style>
