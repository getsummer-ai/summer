<script lang="ts">
  export let strokeColor: string;
</script>

<svg
  class={$$restProps.class ?? ''}
  width="24"
  height="24"
  viewBox="0 0 24 24"
  fill="none"
  xmlns="http://www.w3.org/2000/svg"
>
  <path d="M8 8L12 12M12 12L8 16M12 12L16 16M12 12L16 8" stroke={strokeColor} />
  <circle cx="12" cy="12" r="10.5" stroke={strokeColor} stroke-opacity="0.2" />
</svg>
