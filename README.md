# dbt Project: Automating Validations with Pre-commit & Linters

## Project Overview

This repository demonstrates how to **automate validations** and ensure **code quality** in dbt projects. It uses data from the **World Wide Importers (WWI) dataset**, accessed via the public API (`https://demodata.grapecity.com/wwi/api/v1/`), as the basis for the dbt models.

We use a combination of `pre-commit`, `dbt-checkpoint`, `yamllint`, and `SQLFluff` to enforce coding standards, documentation rules, naming conventions, and the presence of tests *before* the code is even pushed to the remote repository.

The goal is to show how these tools can be integrated into the development workflow to:

1.  **Detect errors early:** Catch syntax, style, and logic issues during local development.
2.  **Maintain consistency:** Ensure all contributors follow the same standards.
3.  **Improve quality:** Enforce best practices like documentation, testing, and proper referencing.
4.  **Automate reviews:** Reduce time spent on manual code reviews for common issues.

## Technologies Used

* **dbt (Data Build Tool):** The primary tool for transforming data in the data warehouse. This project demonstrates how to apply validations to dbt models (`.sql`) and configuration files (`.yml`).
* **Pre-commit:** A framework for managing and maintaining Git pre-commit hooks. It automatically runs scripts/tools before each `git commit`, blocking the commit if any checks fail.
* **dbt-checkpoint:** A collection of `pre-commit` hooks specifically designed for validating dbt projects. In this project, we use hooks to:
    * Verify that `dbt deps`, `dbt parse`, and `dbt docs generate` run without errors.
    * Ensure models and their columns have descriptions.
    * Require a minimum number of tests per model (and specific tests like `not_null`, `unique`).
    * Check the correct usage of `ref` and `source` (avoiding hardcoded table names).
    * Enforce naming conventions for models (prefixes, patterns).
* **SQLFluff:** A highly configurable SQL linter and formatter. We use it to:
    * Check and correct SQL formatting (indentation, spacing, capitalization).
    * Enforce style rules (like explicit use of `AS` for aliases).
    * Ensure consistency in alias usage.
    * Configured via the `.sqlfluff` file.
* **yamllint:** A linter for YAML files. We use it to:
    * Check the syntax and style of dbt configuration files (`.yml`).
    * Ensure consistent formatting (indentation, spacing, etc.).
    * Configured via the `.yamllint` file.
* **GitHub Actions:** CI/CD platform used to automate the continuous integration workflow. The workflow (`.github/workflows/CI_job.yml`) in this project:
    * Runs linting checks (`pre-commit`) on Pull Requests.
    * Builds the dbt models (`dbt build`) in a dynamic CI schema to validate changes in PRs, using `state:modified` for efficient builds when possible.
    * After a merge to `main`, generates and commits the production `manifest.json` to the `main` branch (in the `target-defer/` directory) to enable state-based builds (`state:modified`) in CI.

## How Validation Works

1.  **Local Development:**
    * The developer makes changes to `.sql` or `.yml` files.
    * When attempting to `git commit`, the `pre-commit` framework is triggered.
    * `pre-commit` sequentially executes the hooks defined in `.pre-commit-config.yaml`:
        * `yamllint` checks the modified `.yml` files.
        * `sqlfluff` checks the modified `.sql` files.
        * `dbt-checkpoint` hooks check descriptions, tests, names, references, etc., in the relevant models and YAML files.
    * If any hook fails, the commit is aborted, and the developer needs to fix the issues before trying to commit again. Some hooks (like `sqlfluff format`) can automatically fix the issues.

2.  **Continuous Integration (GitHub Actions):**
    * **Pull Request:** When a PR is opened targeting the `main` branch:
        * The `linting` job runs `pre-commit run --from-ref origin/main --to-ref HEAD --all-files` to ensure only the changes introduced in the PR are validated against the standards.
        * If linting passes, the `build` job is executed:
            * Creates a unique CI schema for the PR in the data warehouse.
            * Attempts to use the `manifest.json` from the `main` branch (if it exists in `target-defer/`) to run a `dbt build -s state:modified ... --defer` (smart and fast build, only modified models and their dependents). If the manifest is unavailable, it runs a full `dbt build`.
            * Runs dbt tests as part of the `dbt build`.
            * Cleans up the CI schema after completion.
    * **Push to `main`:** When changes are merged into `main`:
        * The `upload_manifest` job is triggered.
        * It runs `dbt parse --target prod` to generate a `manifest.json` reflecting the production state.
        * This `manifest.json` is moved to `target-defer/` and committed back to the `main` branch. This artifact will be used by future PRs to enable more efficient `state:modified` builds in CI.

## Configuration

* **`.pre-commit-config.yaml`:** Defines which hook repositories to use (dbt-checkpoint, sqlfluff, yamllint), which specific hooks to run, and any arguments/settings for those hooks (like test counts or naming patterns).
* **`.sqlfluff`:** Contains all configuration rules for SQLFluff, including the SQL dialect, enabled/excluded rules, capitalization policies, indentation, line length, and alias rules.
* **`.yamllint`:** Contains configuration rules for yamllint, controlling aspects like indentation, spacing, line length, and boolean usage in YAML files.
* **`profiles.yml`:** (Not included in the repo for security, but required to run dbt). Defines the connections to the data warehouse for different environments (e.g., local, CI, prod). CI uses environment variables (`DBT_PROFILES_DIR` and secrets) to configure the connection.
* **`requirements.txt`:** Lists the necessary Python dependencies, including `dbt-core`, the specific dbt adapter (`dbt-postgres`), `sqlfluff`, `yamllint`, `dbt-checkpoint`, etc.

## Getting Started (Locally)

1.  Clone the repository.
2.  Ensure you have Python and `pip` installed.
3.  Install the dependencies: `pip install -r requirements.txt`
4.  Install the git hooks: `pre-commit install`
5.  Configure your local `profiles.yml` file (usually in `~/.dbt/`) with your development environment credentials.
6.  Now, whenever you try to commit (`git commit`), the hooks will run automatically! You can also run them manually at any time with `pre-commit run --all-files`.

This project demonstrates a robust pipeline for maintaining quality and consistency in a dbt project, automating critical validations early in the development cycle and in CI.
