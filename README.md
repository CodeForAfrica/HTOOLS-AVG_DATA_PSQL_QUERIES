## A collection of PSQL scripts to query sensors.AFRICA's database 
### Requirements
1. A URL connection string/parameters to access PostgreSQL <b>htools</b> database; Request from sensors' tech admins
2. `JDBC Driver` or <b>postgres client</b> in instances where the scripts are run locally.
   
### Tips
1. Tools to use: [DBeaver](https://dbeaver.io) ( comments are formated properly when using editors like DBeaver SQL editor and Visual Studio Code )
2. PostgreSQL clients:
   1. [node-postgres](https://node-postgres.com)
   2. [psycopg](https://www.psycopg.org)

### Troubleshooting

Working with PostgreSQL on a MAC can be problematic especially when trying to restore backup data. To resolve some of these issues, you could:
1. Open <b>Terminal</b> and run the command below. 
    ```sh
    sudo mkdir -p /etc/paths.d && echo /Applications/Postgres.app/Contents/Versions/latest/bin | sudo tee /etc/paths.d/postgresapp 
    ```
2. Download and install PostgreSQL which sets a lot of configurations for you.
