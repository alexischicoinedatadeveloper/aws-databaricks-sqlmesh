# aws-databaricks-sqlmesh
A portfolio data pipeline project using Databricks in AWS with sqlmesh.

## Overview
This project is there to explore various aspects of data engineering,
particularly the ingestion and transformation of data along with the surrounding concerns of infrastructure,
security, deployment, monitoring, testing, documentation, etc.
As it's a portfolio project, it's not meant to be a production-ready system but rather a demonstration of the various
skills and knowledge I have acquired.

## Technology Choice
For this project, I chose to work with Databricks in AWS and sqlmesh. I will explain each choice below.

### Cloud Provider - AWS
When looking at cloud providers,
I'm choosing between AWS and Azure as the two big players I've seen mostly used in the job market.
While Azure seems popular with big enterprises, I've noticed AWS to be a more popular choice with tech companies and startups.
Another interesting aspect is that job dbus are cheaper in AWS (maybe that can be negotiated).
The organization I work at is on AWS so that's another reason to choose it to deepen my knowledge of the platform.
That being said,
Databricks is very well integrated with Azure with integrations with the Azure Key Vault and easy integration with Data Factory
that it's a really good choice as long as your data isn't all in another platform (moving data between clouds is expensive).

### Data Platform - Databricks
From my perspective, there are two big players in the data platform space: Databricks and Snowflake. I've worked with both
and I find Databricks to be more versatile and powerful while Snowflake is more user-friendly and easier to set up.
If you have a simpler use case,
a low spend, or a huge budget and little technical talent or time, Snowflake is a great choice.
However, if you have a need for controlling what's going on and want the ability to tune things to your need,
Databricks is the way to go.

A few examples:
- Databricks has many options for compute from All-purpose compute that you can set how you want to job compute, classic sql warehouse, and serverless warehouses while Snowflake is mostly limited to their virtual warehouses (similar to Databricks serverless warehouses).
- Databricks lets you organize your data how you want with options like partitioning, z-ordering, and liquid clustering while Snowflake limits you to auto clustering.
- Databricks explains the technical aspects of things while Snowflake only focuses on how to use and not how it works.
- Functions in the Databricks are a lot more configurable such as creating hyperloglog sketches with a configurable size vs Snowflake's fixed size.

As a career choice,
I would recommend Snowflake if you mostly want to work with the data
and are not too concerned about optimization or tuning.
On the other hand,
if you enjoy
understanding the technical aspects so that you can optimize your system to process a lot data cost-efficiently,
Databricks is a lot more appealing.
It's a bit like the choice of programming in C++ or python.
Sure python is easier and quite productive,
but for some complex needs you need C++ and companies will pay you well to use it.
With Databricks and Snowflake it's the same,
and personally I prefer a skillset where the technology is cheap
and the talent is expensive than the other way around as that's where I can bring more value.

As a business,
you have
to decide
if the extra complexity and talent costs bring you capabilities that are worth that extra overhead.
That will mostly come down to the amount of complex use cases
you need to support and the amount of data you need to process.

Note that Databricks has changed so much in the last few years that your perception of it might be outdated.
Things like Unity Catalog with lineage, Delta Lake, Databricks SQL with serverless warehouses, the photon engine, and 
a lot of other recent improvements have made it a lot better than the managed spark it began as.

### Orchestration - Databricks Workflows
There are many options for orchestrating pipelines like Data Factory, Airflow, Prefect, etc. In Azure,
I might have gone for Data Factory as it's a power and cheap option, but with AWS that doesn't make sense (again, transferring data between clouds is expensive).
I've recently been learning more about AirFlow and it's great and powerful,
but there are two things going against it right now.
First, I would need to set it up with something like the AWS managed version which would come with a cost.
The other reason is that I'll be using sqlmesh for this project and it doesn't support SQL warehouses yet.
I could use an all-purpose cluster, but I'd rather use a job cluster where the dbus are less expensive.
By using Databricks as our workflow orchestrator, we have a free and powerful option that we can manage with terraform.
We'll be able to keep our orchestration relatively simple to build and understand which is always a big plus in my book.

### Data Transformation - sqlmesh
To transform your data, you can roll out your own code or use a tool like dbt or sqlmesh.
I have extensive experience with dbt
and its main advantage over sqlmesh is that it's more mature
and is almost 100% customizable as you can override built-in macros and create your own materializations.
The problem with dbt is that the fancy features are only in dbt cloud
and dbt-core just doesn't help you enough with complex projects.
Sqlmesh is bringing in a lot of great features like incremental by time that tracks the processed interval for you
(in dbt you have to write that code and the custom materialization to go with it yourself),
the ability to run the same code in multiple engines with transpilation, being able to run unit tests fast with duckdb, virtual environments, and more.
Sqlmesh is shaping out to be quite a capable tool for complex projects that need quality while controlling the costs
(for example by automatically targeting which tables to backfill based on the impact of a code change).
I'm excited to see it grow and I think it's a great choice for this project.

### CI/CD - Github Actions
For CI/CD, I've chosen Github Actions as it's free and easy to set up.
There's also an interesting CI/CD bot for sqlmesh that we'll set up.

## Project Content
Ok the technology is chosen, but what are we going to do with it?
My interest and specialty is in batch processing so we'll be focusing on that, but there could be some streaming in the future.
We'll be building a data pipeline that ingests data from a database,
transforms it, and makes it available for analysis and dashboards.

### Infrastructure
The project will begin
by setting up a CI/CD pipeline with Github Actions and Terraform
to deploy the AWS infrastructure and automate the Databricks workspace.
We'll be setting up VPCs, S3 buckets, IAM roles,
a postgres database for sqlmesh state and our source data, Databricks Unity Catalog, a job, etc.

### Data Source
Before doing ingestion, we need some data to ingest. As this is a portfolio project, we don't have real data so we'll be generating some fake data.
We'll keep things simple and generate the data with a python script that will write to postgres.
We'll run that script in a Databricks notebook at the start of the job.

### Ingestion
We'll leverage Databricks Lakehouse Federation to ingest the postgres data from our sqlmesh project.
This will avoid the need
to have a separate ingestion tool and the networking to connect Databricks to the database
can be managed in the terraform code.

### Transformation
We'll give ourselves a challenge by having our project run on two schedules with long runs that could overlap.
As we're not using the sqlmesh Airflow integration,
we'll have to split the project in two to avoid having concurrent runs.
We'll explore how
and if we can have a second version of the project
that's complete
by using the multi-repo support to get sqlmesh to analyse the complete plan and use the backfill information to identify which models need to be restated.
For this project, the first project that is upstream will run every 5 minutes and the downstream project every hour.
This setup will allow us
to explore some challenges such as using a pool for faster cluster start
or keeping an all-purpose cluster running
and figuring out
how we can make sure the downstream project only runs for intervals of data that were processed correctly upstream.

### Monitoring
We'll set up a lambda to do our monitoring and alerting.
It will be low-cost, and if we were to have problems in Databricks it will keep working.

### Testing
We'll test our data transformations with sqlmesh unit tests
and will put data audits in place to make sure our source data quality is good.
We'll rely on our monitoring to validate that everything else is working as expected.
We won't go much further with the testing for this portfolio project, but there are many more techniques we could use.

### Documentation
Documentation will be made in markdown files throughout the repository and through comments and docstrings in the code.
The approach to documentation will be to explain the big ideas,
the unusual aspects, and the reasons for the choices made.
When it comes to the technical details, the code is the right reference as it's the only one that will be exact.

### End Product
Throughout the years, I've found my interest to be in data engineering and the optimization of data pipelines more than in visualization,
analysis or data modeling and this is what the project will focus on.
Our goal is
to build a fully automated pipeline that will reliably update the data without requiring manual intervention.
We will build in resiliency mechanisms, test it, and monitor it to make sure it's working as expected.
I will create a simple dashboard to showcase results, but it won't be sophisticated.
The data model will be a simple medallion architecture
resulting in a star schema with a fact table and a few dimension tables.
We'll the different model kinds in sqlmesh,
but we'll keep the transformation logic simple while showcasing a few techniques here and there.

#### Modeling and serving considerations
- Depending on the technology used, producing a one big table could also speed things up
(works well in Tableau and not so much in Power BI where a star schema is better).
- For the end data behind specific use cases,
I believe that creating custom tables is the way to go for optimal performance as you can adjust the partitioning,
z-ordering, or clustering based on the report filters and you can pre-compute complex calculations.
- To reduce latency further,
specialized storage like Azure Premium block blob storage accounts or AWS S3 Express One Zone can be used for lower latency reads and cheaper writes that would be useful if we rewrite complete tables often (just be careful to vacuum the tables to keep the storage cost down as you can always recompute them if needed).
- In some cases it's beneficial to model child items in arrays
and in others it's better to have them in separate tables to reduce the amount of data that needs to be read.
- While we'll use job compute clusters for data engineering, serving data works really well with serverless warehouses as you can scale up and down as needed and only pay for what you use.

### Developer setup
There's no developer setup for this project as it's a portfolio project and not meant to be run by others. If you need help setting up a similar project, feel free to reach out to me.