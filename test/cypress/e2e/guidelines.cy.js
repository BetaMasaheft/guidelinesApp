describe('Look up transcription guidelines', () => {
    // see user 17
    beforeEach(() => {
        cy.visit('/')
    })

    // see 03_user 17
    it('retrieve transcription guidelines by query', () => {

        // In the search field (top right) type transcription and click Search
        cy.get('input[type="search"]')
          .type('transcription')
        cy.get('#f-btn-search')
          .click()
        // Check that you get to https://betamasaheft.eu/Guidelines/?q=transcription
          .url()
          .should('include','Guidelines/?q=transcription')
        // Scroll (and go to second page) to find the fitting title, here Transliteration Principle
        cy.get('ul.pagination')
          .first()
          .within(() => {
            cy.get('li:nth-child(4) a')
              .click()
        })
        cy.get('#results a')
          .contains('Transliteration Principles')
        // click to get to https://betamasaheft.eu/Guidelines/?q=transcription&start=6&id=transliteration-principles
        .invoke('attr', 'href')
        .should('eq', '?q=transcription&start=6&id=transliteration-principles')
        .then(href => {
              cy.request(href)
                .its('body')
                .should('include', '</html>')
         })
    }
    )
    it('retrieve transcription guidelines via “quick links”', () => {
        cy.get('a')
          .contains('Transliteration')
          .invoke('attr', 'href')
          .should('eq', '/Guidelines/?id=transliteration-principles')
          .then(href => {
              cy.request(href)
              .its('body')
              .should('include', '</html>')
              .and('include', 'Transliteration')
         })
    })
})