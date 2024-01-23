{% docs __overview__ %}



### Welcome to the EAX Enterprise insights objects!

This DBT documentation site is a project that contains all models, analyses and documentation that implement the EAX Semantic Layer.   The EAX Semantic Layer hosts all analytics objects (data tables, views, functions) that can be used for executing specific customer analytics use cases.   The layer is built upon many existing and emerging foundational datasets hosted in the Enterprise Data Hub (EDH), and whilst EDH is being built out, the layer continues to leverage data from within CEDs (Curated Enterprise Datasets) and other managed datasets within Snowflake.

This project is a *super project* that includes and references individual DBT projects as packages.   This documentation environment is one of several inter-related documentation assets that are available. These are:

EAX [Wiki Onboarding Pages](https://wiki.autodesk.com/display/EAX/Onboarding+Documentation)

ADP [Data Catalog](https://autodesk.atlan.com/assets/73c2d9bb-3a17-455d-bd13-23fa6bb68696/related)


### What is included ?

The EAX Semantic layer comprises the following **types** of object:

    - Models - SQL models that describe and implement data base objects. They can be Views, Tables or Ephemeral
    - Analyses - SQL models that preform some form of data analysis
    - Tests - SQL models that test a specific assertion against the data
    - Documentation - this page and much of the content that is described on this site

{% enddocs %}
