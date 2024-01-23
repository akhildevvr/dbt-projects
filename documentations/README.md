# EIO dbt models documentations in secure multi-tenant platform

This project is to deploy DBT documentations from a single node. Project will include all dbt projects as packages.

Then DBT dependency resolution process will compile the codebase from pachages.yml with "dbt deps" command. 

A script has been placed in the utils folder of the documentation 'super project' that ensures that each project that has been
included as a package is included with the documentation with a package description.   In a project __overview__ block has been 
included in a docs/overview.md file, then the contents of this block is read and transformed into a __<package_name>__ block 
and included within the super project.   If no overview has been specificed, then a placeholder block is created.

Then "generate docs" command can be used to generate target/catalog.json , target/index.html, target/manifest.json. Once these files are created this can be hosted.

Commands -

1) documentations/dbt deps <add --profiles-dir if running locally>
2) python documentations/utils/generate_overview_md.py
3) documentations/dbt docs generate <add --profiles-dir if running locally>

