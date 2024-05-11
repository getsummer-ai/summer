<script lang="ts">
  import type { ProjectProductType } from './api';
  import { initApi } from './api';

  export let service: ProjectProductType;
  export let pageId: string;
  export let theme: string = 'white';

  const onLinkClick = () => initApi().clickService(pageId, service.uuid);

  const default_image =
    'UklGRu4BAABXRUJQVlA4IOIBAABQDACdASo+AC0APoU4l0elI6IhMrbeYKAQiWoAnTKvOre08kyAEAntg' +
    'H4zAZy9vkOgh4JcOf6+UHtoYnnQI0ofxVdaPK953IrCWaRh6wCYIbvBDf7BhTiZl5I6cQVoZw9UMWi++n' +
    'D968tQAAD+8LbxR2HzLRY99ySxutdJJ4IAo3dk2igB3q9wa4KAhZsvu3S5GuNEvuW1PlV1REW/srz/Qkr' +
    'hyD6NuQ3kUA/tHi3aPECBNOTArZavMnRQMEbpTkwpOv7plM7e6IPsNJmOk+DNmd+tlbDTtKeLdOOvuMxZ' +
    'rO1ShCrpbg7CbnFyqRhT4zWubzKbBP3o9zPItggP56RNhtdVh7CseZQW5639vd5D6+Jfqml4zeLfTPSRf' +
    '2Rjx+7ZRJ/Xc3OreSBYK02RZ2PeRk/pQd693nLl7zhldpz4lDSZB9tDg5pKjTN5NV4p2H98gYRI0bUoQr' +
    'uYxzpt6zA2v00ooGZDQ27bPeY8eTfw/J5sIMxfxVjCmACIdbsXpVhB0E/pxRy4j+Q3iNqCFcHUiyFIrFMa' +
    '5I6SxrUhPDnrq8FUTtqmmIKs8KQmDY22rv/kKujcH/f5Ga0uTY5g/w9tpXghjN7ex0/3PbEqr4gltm9K2f' +
    'tzmTtDwo4v78EfmOAAAA==';
</script>

<a target="_blank" class="theme-{theme}" href={service.link} on:click={onLinkClick}>
  <div class="body">
    <img alt="preview" src="data:image/webp;base64,{service.icon ? service.icon : default_image}" />
    <span class="title">
      {service.name}
    </span>
  </div>
</a>

<style lang="scss">
  a {
    font-size: 15px;
    line-height: 22px;
    font-weight: 500;
    border-radius: 16px;
    padding: 20px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    text-decoration: none;
    margin-top: 20px;
    letter-spacing: normal;
    animation: zoom 1s cubic-bezier(0.34, 1.56, 0.64, 1);

    .body {
      @apply flex justify-between items-center;
      max-height: 44px;
      overflow: hidden;

      img {
        width: auto;
        max-height: 40px;
        border-radius: 8px;
      }

      .title {
        @apply ml-4;
      }
    }

    &:not(:first-of-type) {
      margin-top: 10px;
    }

    &.theme-white {
      background: #EFF2F4;
      color: #1B1B1B;
      &:hover {
        background: #EDF0F2;
      }
    }

    &.theme-black {
      background: rgba(255, 255, 255, 0.10);
      color: white;
      &:hover {
        background: rgba(255, 255, 255, 0.12);
      }
    }
  }

  @keyframes zoom {
    from {
      opacity: 0.2;
      transform: scale(0.95);
    }
    to {
      opacity: 1;
      transform: scale(1);
    }
  }
</style>
