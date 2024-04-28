To facilitate local development using duckdb, a project is created to run locally only.
This project contains csv files extracted from the postgres database and can be used to create
a local duckdb file to load as a catalog in the upstream project.
To keep the data, and the state separated so that the upstream project state is kept separate from the local project state,
a state connection is defined explicitly in the gateway.