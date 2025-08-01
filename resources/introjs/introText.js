
      function startIntroHome(){
        var intro = introJs();
          intro.setOptions(
            {
            steps: [

              {
                element: "#showitem",
                intro: "Here is where you will see your page data: it can be a page, describing what and how to do things, an element or attribute page, reproducing the basic information about \
                that single node. Please use the various links provided, and highlighted with arrows, so that you can find out more as you browse.\
                Pages will also show you a block at the bottom, with all other pages which have a link to the one you are seeing.",
                position: 'bottom'
              },
              {
                element: '#tocs',
                intro: 'The content of these guidelines cannot be organized under just one criterion, you might take different paths in the content and \
                here are several preselected for you, click on the one you are interested in to begin with. How to, will guide you to the pages for setup first, \
               but if you are all set, then you might want to pick an element from the element list or just use the Main Table of Contents.',
                position: 'bottom'
              },
              {
                element: '#schemaviewbutton',
                intro: "The data visualized here is strictly connected with the schema, clicking this button you will get a readable version of the Beta maṣāḥǝft schema ODD (One Document Does it All)",
                position: 'bottom'
              },
              {
                element: '#ontoviewbutton',
                intro: 'Clicking here you can get a visualization of the ontologies used by Beta maṣāḥǝft',
                position: 'bottom'
              },
              {
                element: '#searchForm',
                intro: 'You can find here a simple search form, enter the topic you are looking for and it will search the text of the guidelines.',
                position: 'bottom'
              },
              {
                element: '#results',
                intro: 'Results from the above search will be shown here, with some KWIC context',
                position: 'bottom '
              }
            ]
          }).setOption('showProgress', true)
    ;

          intro.start();
      };
      
      