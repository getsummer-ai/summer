<script lang="ts">
  import { createEventDispatcher } from 'svelte';

  const dispatch = createEventDispatcher();

  function closeModal() {
    dispatch('close');
  }
  export let showModal = false;
  export let theme = 'light';
  export let title = '';

  let dialog: HTMLDialogElement;

  $: if (dialog && showModal) dialog.showModal();
</script>
<div class="dialog-container">
  <div
    aria-hidden="true"
    hidden={!showModal}
    ref="overlay"
    class="dialog-overlay"
    on:click|self={() => closeModal()}
  />
  <div class="dialog theme-{theme} {showModal ? 'shown' : 'hidden'}">
    <h1> {title} </h1>
    <div class="body">
      <slot />
    </div>
    <div class="footer">
      <slot name="footer" />
    </div>
  </div>
</div>

<style lang="scss">
  .dialog-container {
    width: 100%;
    @keyframes fade {
      from {
        opacity: 0;
      }
      to {
        opacity: 1;
      }
    }
    .dialog-overlay {
      background: rgba(0, 0, 0, 0.3);
      backdrop-filter: blur(10px);
      position: fixed;
      top: 0;
      left: 0;
      width: 100vw;
      height: 100vh;
      animation: fade 0.2s ease-in-out;
    }
  }

  .dialog {
    width: 100%;
    border-radius: 16px;
    font-size: 20px;
    line-height: 30px;
    font-style: normal;
    font-weight: 500;
    position: fixed;
    max-height: 80vh;
    top: 10vh;
    left: calc(50vw - 240px);
    overflow-y: auto;
    max-width: 480px;
    height: 480px;
    padding: 0 32px;
    animation: zoom 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);

    &.hidden {
      display: none;
      animation: modal-out 0.2s;
      @media (max-width: 480px) {
        animation: slide-down 0.3s ease-in-out;
      }
    }

    @media (max-width: 480px) {
      top: 20vh;
      left: 0;
      height: 80vh;
      width: 100%;
      max-width: 100%;
      border-radius: 16px 16px 0 0;
      animation: slide-top 0.3s ease-in-out;
    }

    h1 {
      padding: 32px 0 16px;
      margin: 0;
      font-size: 12px;
      font-style: normal;
      font-weight: 500;
      line-height: 16px;
    }

    .body {
      padding: 0 0 32px;
      letter-spacing: -0.2px;

      :global(ul) {
        margin: 0;
        padding: 0 0 0 15px;
        list-style-type: disc;
        list-style-position: outside;
      }
      :global(li) {
        margin: 0 0 8px 0;
        padding: 0;
      }

      :global(p) {
        margin: 0 0 8px 0;
        padding: 0;
        &:first-child {
          margin-bottom: 12px;
        }
      }
    }

    .footer {
      @apply relative z-10 min-h-12;
    }

    &.theme-white {
      @apply text-black;
      background: #fff;

      h1 {
        color: rgba(27, 27, 27, 0.60);
      }

      .footer {
        box-shadow: 0px -25px 14px -11px #fff;
        -webkit-box-shadow: 0px -25px 14px -11px #fff;
        -moz-box-shadow: 0px -25px 14px -11px #fff;
        border-top: 1px solid #efefef;
      }
    }

    &.theme-black {
      color: rgba(255, 255, 255, 0.80);
      background: #242424;

      h1 {
        color: rgba(255, 255, 255, 0.40);
      }

      .footer {
        box-shadow: 0px -25px 14px -11px #000;
        -webkit-box-shadow: 0px -25px 14px -11px #000;
        -moz-box-shadow: 0px -25px 14px -11px #000;
        border-top: 1px solid #444;
      }
    }
  }

  @keyframes zoom {
    from {
      opacity: 0;
      transform: scale(0.95);
    }
    to {
      opacity: 1;
      transform: scale(1);
    }
  }

  @keyframes modal-out {
    from {
      display: block;
      opacity: 1;
    }
    to {
      display: none;
      opacity: 0;
    }
  }

  @keyframes slide-top {
    from {
      opacity: 0;
      top: 50vh;
      height: 50vh;
    }
    to {
      opacity: 1;
      top: 20vh;
      height: 80vh;
    }
  }

  @keyframes slide-down {
    from {
      display: block;
      opacity: 1;
      top: 20vh;
      height: 80vh;
    }
    to {
      opacity: 0;
      display: none;
      top: 40vh;
      height: 60vh;
    }
  }

</style>
