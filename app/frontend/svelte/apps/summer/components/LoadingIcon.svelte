<script lang="ts">
  export let strokeColor: string;
  export let width: number = 24;
  console.log($$restProps.class)
</script>

<svg
  class={ 'animate ' + ($$restProps.class ?? '') }
  xmlns="http://www.w3.org/2000/svg"
  width={width}
  height={width}
  viewBox="0 0 24 24"
  fill="none"
>
  <circle cx="12" cy="12" r="8.5" stroke={strokeColor} stroke-opacity="0.2" />
  <path
    d="M12 3.5C13.3044 3.5 14.5912 3.80019 15.761 4.37732C16.9307 4.95446 17.9519 5.79305 18.7455 6.82818C19.5392 7.86332 20.0839 9.06721 20.3377 10.3467C20.5914 11.6261 20.5472 12.9468 20.2086 14.2064C19.87 15.4661 19.2461 16.6309 18.3851 17.6107C17.5241 18.5906 16.4492 19.3591 15.2435 19.8568C14.0379 20.3545 12.7338 20.5681 11.4324 20.481C10.1309 20.3939 8.86699 20.0085 7.73841 19.3545"
    stroke={strokeColor}
  />
</svg>

<style lang="scss">
  .animate {
    @apply animate-spin;
  }
</style>
