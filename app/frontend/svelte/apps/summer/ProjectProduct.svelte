<script lang="ts">
  import type { ProjectProductType } from './api';
  import { initApi } from '@/svelte/apps/summer/api';

  export let service: ProjectProductType;
  export let pageId: string;

  const onLinkClick = () => initApi().clickService(pageId, service.uuid)

  const default_image =
    'UklGRu4BAABXRUJQVlA4IOIBAABQDACdASo+AC0APoU4l0elI6IhMrbeYKAQiWoAnTKvOre08kyAEAntg' +
    'H4zAZy9vkOgh4JcOf6+UHtoYnnQI0ofxVdaPK953IrCWaRh6wCYIbvBDf7BhTiZl5I6cQVoZw9UMWi++n' +
    'D968tQAAD+8LbxR2HzLRY99ySxutdJJ4IAo3dk2igB3q9wa4KAhZsvu3S5GuNEvuW1PlV1REW/srz/Qkr' +
    'hyD6NuQ3kUA/tHi3aPECBNOTArZavMnRQMEbpTkwpOv7plM7e6IPsNJmOk+DNmd+tlbDTtKeLdOOvuMxZ' +
    'rO1ShCrpbg7CbnFyqRhT4zWubzKbBP3o9zPItggP56RNhtdVh7CseZQW5639vd5D6+Jfqml4zeLfTPSRf' +
    '2Rjx+7ZRJ/Xc3OreSBYK02RZ2PeRk/pQd693nLl7zhldpz4lDSZB9tDg5pKjTN5NV4p2H98gYRI0bUoQr' +
    'uYxzpt6zA2v00ooGZDQ27bPeY8eTfw/J5sIMxfxVjCmACIdbsXpVhB0E/pxRy4j+Q3iNqCFcHUiyFIrFMa' +
    '5I6SxrUhPDnrq8FUTtqmmIKs8KQmDY22rv/kKujcH/f5Ga0uTY5g/w9tpXghjN7ex0/3PbEqr4gltm9K2f' +
    'tzmTtDwo4v78EfmOAAAA=='
</script>

<a target="_blank" href={service.link} on:click={onLinkClick}>
  <div class="flex justify-between items-center">
    <img alt="preview" src="data:image/webp;base64,{service.icon ? service.icon : default_image}" />
    <span class="ml-5">
      {service.name}
    </span>
  </div>

  <div>
    <svg width="18" height="11" viewBox="0 0 18 11" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path
        d="M17.208 5.32L12.232 10.296H10.456L14.792 5.944H-0.00799996V4.696H14.824L10.472 0.344H12.248L17.208 5.32Z"
        fill="black"
      />
    </svg>
  </div>
</a>

<style lang="scss">
  a {
    font-size: 16px;
    border-radius: 12px;
    border: 1px solid #e6e6e9;
    background: #fff;
    box-shadow: 0 2px 4px 0 #e6e6e9;
    padding: 9px 12px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    text-decoration: none;
    color: black;
    margin-top: 20px;
    animation: zoom 1s cubic-bezier(0.34, 1.56, 0.64, 1);
    img {
      width: auto;
      max-height: 45px;
      border-radius: 4px;
    }

    &:not(:first-of-type) {
      margin-top: 10px;
    }
  }

  a:hover {
    background-color: #f8f8f8;
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
