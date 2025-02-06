To replicate the dbt/duckdb setup, you'll need:
```
dbt-duckdb==1.9.1
```

example profiles.yml
```
fetch_dbt:
  outputs:
    dev:
      type: duckdb
      path: fetch_dev.duckdb
      threads: 1

    prod:
      type: duckdb
      path: fetch_prod.duckdb
      threads: 1

  target: dev

```