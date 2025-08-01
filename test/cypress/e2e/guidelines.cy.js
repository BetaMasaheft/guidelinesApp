describe('Look up transcription guidelines', () => {
    // see user 17
    beforeEach(() => {
        cy.visit('/')
    })

    // see 03_user 17
    // don't hardcode the order of results into the test
    it('retrieve transcription guidelines by query', () => {

        // In the search field (top right) type transcription and click Search
        cy.get('input[type="search"]')
          .type('transcription')
        cy.get('#f-btn-search')
          .click()
        // Check that you get to https://betamasaheft.eu/Guidelines/?q=transcription
          .url()
          .should('include','Guidelines/?q=transcription')
        cy.get('h3')
          .contains('You found "transcription"')
        cy.get('ul.pagination')
          .should('be.visible')
        cy.get('#results')
          .contains('transcription')
        cy.get('#results a')
          .should('have.length.gte', 4)
          .invoke('attr', 'href')
          .should('contain', 'transcription')
          .then(href => {
              cy.request(href)
                .its('body')
                .should('include', '</html>')
          })
    })

    it('retrieve transcription guidelines via Table of Contents”', () => {
        cy.get('#tocs')
          .should('be.visible')
        cy.contains("Wiki")
          .click()
        cy.get('#toctable-of-contents > ul > li > a')
          .should('be.visible')
          .contains('Transliteration Principles')
          .invoke('attr', 'href')
          .should('contain', '?id=transliteration-principles')
    })
})