<script lang="ts">
  import type { ProjectServiceType } from './store';

  export let service: ProjectServiceType;
</script>

<a href={service.link}>
  <div class="flex justify-between items-center">
    <img alt="preview" src="data:image/png;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAQEBAQEBAQEBAQGBgUGBggHBwcHCAwJCQkJCQwTDA4MDA4MExEUEA8QFBEeFxUVFx4iHRsdIiolJSo0MjRERFwBBAQEBAQEBAQEBAYGBQYGCAcHBwcIDAkJCQkJDBMMDgwMDgwTERQQDxAUER4XFRUXHiIdGx0iKiUlKjQyNEREXP/CABEIAC0APgMBIgACEQEDEQH/xAAZAAEBAQEBAQAAAAAAAAAAAAAGBQcIAgn/2gAIAQEAAAAA0cxSLjzBh51gmnAstCBTfY19/wCBOD5TL3FInzyuQBwN5r2JGbRgsb6DZ57kyymB9yf/xAAYAQADAQEAAAAAAAAAAAAAAAAEBQYDB//aAAgBAhAAAADO6uWHKHVfXwZBhv8A/8QAGQEAAgMBAAAAAAAAAAAAAAAABAcBBggJ/9oACAEDEAAAALvJgefGE0j+forvbX//xAAwEAACAQMCBQMCBAcAAAAAAAABAgMABAUGERIhIjFBBzJxExQIFUKhM1FhgYKRsv/aAAgBAQABPwDVeIyOpcpdZXISPMXkJhjdi0cKfpSNewAFRaalgfmhqSxdY9ip3FZC077iru2Ub8qu4AN+VXiAb16ces+o/Tea7t47iW8xcsOyWUzF4opeIEOgJ6ax2oMHe8KreICfEgKf9AV+V21wodApB8irrAxlT0VmNOFQxVTWVxUkJbkav4mXi3FZBzxFF71LGu/W1Q3+DtFCy3Su4/TGOM/tyrF6wtrFwLM3KJvuVZQUP9t6t9cYq4RY7giOVuw7Bvji2qfP4llMV1xoPDFCR+29Zm3xd3G8lrdwyDbw43HyK1I0MJkSIh3/AKVcq7O3FUsexq0B2FWZAI3o2tvkbR7ebsRyYd1Pgin1FmtNXbY6+b60K9lfmrJ4KHxX5lj81A01o/WB1xt7lrJQDq5VfRbOTVwyR7cTAfNW0B2HKokIq1naMVmbW1yqfTu03I9jj3L8GrvC5TETC9x0hlEfPo9238ivkVlNcY+PoktLoTbc14QFB+SavNSXN6SIo1hQ/wCTf7NNIzkszEk+TXqPouy0xlRNZTs0F6zzLCy/wtzzUN5FCNaA2FXLkE0Z3BrVWBsL+ylvHiCTL3KjvU6fbztGp3ANfhs9HdN5bE3OsdQgZL7mL7aGyli2ih7OX7ks1f/EACYRAAIBBAEEAAcAAAAAAAAAAAECAwAEBREhBhITMQciMkGBgpH/2gAIAQIBAT8AwnWzXMKRM6kAa0p9VjMjFKwIbW6tR5ACp3U+Iiu7cx3UatG32asZ8Men8ZCFL3E8uuXZgv8AAoqz6RgJdLO4cOp32O3P6msPbPZv45mYsp+lxoinHkTuPNWd5FeQR3ERPY42Nil+R/Ih0w9EUmR7pIxdIG1wHXhvzWUzdtiLI3UysV2Aqr7Ymv/EACgRAAICAgEBBwUBAAAAAAAAAAECAwQAEQUGBxITISJRgSNBUmKR0f/aAAgBAwEBPwCXj4KDELVEe/10TkU0J9LrhrxONqMn45HX1KNHOa7aOrbczCvHRrw78o/CMn9LnOh+r6nVUTV7sa1+SjG2SJtJIv5IG38jKsHhkfVJX2IyyieH3yQB7nOYr2eNv2aFtQJYm0dHYP3Byheu1bUNmnZkhmhbvRyI2mU5wna71AjV6nKrBMpIUTLH3ZPnXlicu92vHZkld1YbAP8Amf/Z" />
    <span class="ml-5">
      {service.title}
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
  }
  a:hover {
    background-color: #f8f8f8;
  }
</style>
