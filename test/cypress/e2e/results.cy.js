describe('Look up calendar attribute', () => {

    // This test fails without reindexing
    it('should show crossreferencing documents for attribute usage', () => {
      cy.visit('/?id=@calendar')
      cy.get('.container-fluid > ul')
        .find('li')
        .should('have.length.gte', 2)
    })

    it('should show transliteration-principles', () => {
      cy.visit('/?id=transliteration-principles')
      cy.get('h2')
        .contains('Transliteration Principles')      
    })
})