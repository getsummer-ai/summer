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
  <div class="gtsm-dialog" on:click|stopPropagation>
    <button class="gtsm-close" on:click={() => dialog.close()} tabindex="0"><span class="gtsm-close__x"></span></button>
    <div class="gtsm-body">
      <slot />
    </div>
    <div class="gtsm-footer">
      <slot name="footer" />
      <input placeholder="Your Email..." type="text" />
      <button>Subscribe</button>
    </div>
  </div>
</dialog>
<style lang="scss">
  dialog {
    width: 100%;
    max-width: 560px;
    border: none;
    border-radius: 16px;
    background: #FFF;
    font-size: 16px;
    line-height: 20px;
    font-style: normal;
    font-weight: 400;

    .gtsm-dialog {
      position: relative;
      padding: 60px 0 0;
    }

    .gtsm-body {
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

    .gtsm-footer {
      @apply flex justify-between relative z-10;
      box-shadow: 0px -25px 14px -11px #fff;
      -webkit-box-shadow: 0px -25px 14px -11px #fff;
      -moz-box-shadow: 0px -25px 14px -11px #fff;
      border-top: 1px solid #EFEFEF;
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

  .gtsm-close {
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
  .gtsm-close:hover {
    background: #e1e1e1;
  }
  .gtsm-close__x {
    position: relative;
    top: -1px;
    left: -0.5px;
    display: inline-block;
    width: 10px;
    height: 10px;
  }
  .gtsm-close__x::before, .gtsm-close__x::after {
    position: absolute;
    width: 1px;
    height: 10px;
    content: " ";
    background-color: black;
  }
  .gtsm-close__x::before {
    transform: rotate(-45deg);
  }
  .gtsm-close__x::after {
    transform: rotate(45deg);
  }
  .gtsm-close:active .gtsm-close__x {
    top: -1px;
    left: -0.5px;
  }
  .gtsm-close:active {
    top: 11px;
    right: 11px;
    width: 26px;
    height: 26px;
    background: #e1e1e1;
  }
</style>
