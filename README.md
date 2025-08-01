# guidelinesApp

Application running the [Guidelines of the Beta maṣāḥǝft project](http://betamasaheft.eu/Guidelines/).
These guidelines are written in TEI/XML and the application is a simple eXist-db application using templating and an XSLT transformation for the views.
You can use these for your own guidelines given the same data structure and TEI encoding is used, and either install the package from .xar or clone this repository adding your data.
The schema for these guidelines (tei-betamesaheftGL.xml)  is stored with the data of the Beta maṣāḥǝft Guidelines and can be found here https://github.com/BetaMasaheft/guidelines .
Also the ontology and schema directories are empty as the data is stored elsewhere in the organization, as detailed below.

The page views and the elements and attributes view pull information from the TEI page with that id but also directly from the schema, to integrate the guidelines for encoding practice with all the rules and examples provided directly in the Beta maṣāḥǝft ODD ([tei-betamesaheft.xml](https://github.com/BetaMasaheft/Schema/blob/master/tei-betamesaheft.xml)).

The code used for generating the OWL files used by the guidelines can be found here:

* the [Beta maṣāḥǝft Ontology](https://github.com/BetaMasaheft/RDF/blob/master/betamasaheft.owl)
* the [Syntaxe du Codex Ontology](https://github.com/BetaMasaheft/SyntaxeDuCodex/blob/master/SyntaxeDuCodex.owl)

The OWL files are included in the expath packages compiled in this repo.


## Development

To deploy the latest version of the full Guidelines application on ExistDB, use the provided `docker-compose.yml` file. This will set up all required services (ExistDB, Nginx, etc.) and handle the deployment process for you.

1. Make sure you have Docker and Docker Compose installed.
2. In your project directory, run:

```sh
docker-compose up -d
```

This will start all services in the background. You can then access the application as described in your configuration.

If you need to rebuild the containers (for example, after updating the code), run:

```sh
docker-compose up -d --build
```

For more details, see the `docker-compose.yml` file in the repository.

## Testing

This project includes both smoke tests and end-to-end (E2E) tests to ensure the application works as expected.

- **Smoke tests** are located in the `test/01-smoke.bats` file and check that the containers start up and the main services are reachable.
- **Cypress E2E tests** are located in the `test/cypress/e2e/` directory and cover user interactions and application flows. The Cypress configuration is in `cypress.config.js`.

To run all tests using Docker Compose, ensure that exist-db has started and finished indexing the collections. Then:

```sh
bats --tap test/*.bats
```

Or, to run Cypress tests (from the project root):

```sh
npx cypress run
```

You can also run tests as part of the CI workflow (see `.github/workflows/`).

For more information, see the `test/` directory and the `cypress.config.js` file.