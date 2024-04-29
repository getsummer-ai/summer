<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import { lock, unlock } from 'tua-body-scroll-lock';
  import { onMount } from 'svelte';

  const dispatch = createEventDispatcher();

  function closeModal() {
    dispatch('close');
  }
  export let showModal = false;
  export let theme = 'light';
  export let title = '';

  let dialog: HTMLElement;

  $: onChange(showModal, dialog);

  const onChange = (modalShown, dialogHtml) => {
    if (modalShown && dialogHtml) return lock(dialogHtml);
    if (modalShown && !dialogHtml) return unlock(dialogHtml);
    unlock(dialogHtml);
  };

  onMount(() => {
    if (showModal) return lock(dialog);
    unlock(dialog);
  });
</script>

<div class="dialog-container">
  <div
    aria-hidden="true"
    hidden={!showModal}
    ref="overlay"
    class="dialog-overlay"
    on:click|self={() => closeModal()}
  />
  <div bind:this={dialog} class="dialog-modal theme-{theme} {showModal ? 'shown' : 'hidden'}">
    <div class="dialog-body-wrapper">
      <div class="scroll-blur up">
        <div aria-hidden="true" class="close-bar" on:touchstart|self={closeModal}><span /></div>
      </div>
      <div class="dialog-body">
        <h1>{title}</h1>
        <div class="content">
          <slot />
        </div>
        <div class="footer">
          <slot name="footer" />
          <div class="powered-by">
            <a href="https://getsummer.ai" target="_blank">
              <span>Powered by</span>
              <svg
                xmlns="http://www.w3.org/2000/svg"
                width="13"
                height="12"
                viewBox="0 0 13 12"
                fill="none"
              >
                <circle cx="6.5" cy="6" r="6" fill="#FECF29" />
              </svg>
              <span>Summer</span>
            </a>
          </div>
        </div>
      </div>
      <div class="scroll-blur down" />
    </div>
  </div>
</div>

<style lang="scss">
  .dialog-container {
    z-index: 999;
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

  .dialog-modal {
    width: 100%;
    border-radius: 16px;
    position: fixed;
    max-height: 80vh;
    top: 10vh;
    left: calc(50vw - 240px);
    max-width: 480px;
    height: 480px;
    animation: zoom 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
    overflow: hidden;

    .dialog-body-wrapper {
      position: relative;
      height: 100%;
      @media (max-width: 640px) {
        padding-top: 20px;
      }

      .dialog-body {
        font-size: 20px;
        line-height: 30px;
        font-weight: 500;
        padding: 0 32px;
        height: 100%;
        -ms-overflow-style: none;
        scrollbar-width: none;
        overflow-y: scroll;
        ::-webkit-scrollbar {
          display: none; /* for Chrome, Safari, and Opera */
        }
      }

      .scroll-blur {
        content: '';
        position: absolute;
        width: 100%;
        left: 0;
        background: transparent;
        pointer-events: none;

        &.up {
          top: 0;
          height: 40px;
          background-size: 100% 40px;
          @media (max-width: 640px) {
            height: 60px;
            background-size: 100% 60px;
          }
        }

        &.down {
          bottom: 0;
          height: 80px;
          background-size: 100% 80px;
          @media (max-width: 640px) {
            height: 60px;
            background-size: 100% 60px;
          }
        }

        .close-bar {
          display: none;
          @media (max-width: 640px) {
            padding-top:8px;
            height: 20px;
            display: block;
          }

          span {
            display: block;
            margin: 0 auto;
            width: 56px;
            height: 4px;
            border-radius: 100px;
          }
        }
      }
    }

    &.hidden {
      display: none;
      animation: modal-out 0.2s;
      @media (max-width: 640px) {
        animation: slide-down 0.3s ease-in-out;
      }
    }

    @media (max-width: 640px) {
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
      font-weight: 500;
      line-height: 16px;

      @media (max-width: 640px) {
        padding-top: 12px;
      }
    }

    .content {
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
      margin-top: 48px;
      .powered-by {
        text-align: center;
        font-size: 10px;
        line-height: 16px;
        font-weight: 600;
        padding: 48px 0 40px;
        a {
          text-decoration: none;

          svg {
            vertical-align: text-bottom;
          }
        }
      }
    }

    &.theme-white {
      color: rgba(27, 27, 27, 0.9);
      background: #fff;

      .close-bar {
        span {
          background: #eff2f4;
        }
      }

      .scroll-blur {
        background: linear-gradient(180deg, rgba(255, 255, 255, 0) 0%, #fff 100%);

        &.up {
          background: linear-gradient(180deg, #fff 20%, rgba(255, 255, 255, 0) 100%);
        }
      }

      a {
        color: #1b1b1b;
      }

      h1 {
        color: rgba(27, 27, 27, 0.6);
      }
    }

    &.theme-black {
      color: rgba(255, 255, 255, 0.8);
      background: #242424;

      .close-bar {
        span {
          background: #323232;
        }
      }

      .scroll-blur {
        background: linear-gradient(180deg, rgba(36, 36, 36, 0) 0%, #242424 100%);

        &.up {
          background: linear-gradient(180deg, #242424 0%, rgba(36, 36, 36, 0) 100%);
        }
      }

      a {
        color: #fff;
      }

      h1 {
        color: rgba(255, 255, 255, 0.4);
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
