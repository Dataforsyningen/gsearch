Feature: Gsearch stednavn test

    Background:
        * url url + '/stednavn'

    Scenario: Response matches columns database
        Then param q = 'valbyparken'

        When method GET
        Then status 200
        And match response == '#[1]'
        And def bboxSchema = {type: 'Polygon', coordinates: '#array'}
        And def geometriSchema = {type: 'MultiPolygon', coordinates: '#array'}
        And match response contains only
        """
            {
                "skrivemaade_uofficiel": '##string',
                "skrivemaade_officiel": '#string',
                "visningstekst": '#string',
                "bbox": '#(bboxSchema)',
                "skrivemaade": '#string',
                "stednavn_subtype": '#string',
                "stednavn_type": '#string',
                "kommunekode": '#string',
                "geometri": '#(geometriSchema)',
                "id": '#string'
            }
        """

    Scenario: Partial string
        Then param q = 'valby g'

        When method GET
        Then status 200
        And match response == '#[6]'
        And match response.[*].skrivemaade_officiel contains deep ['Gadekærvej Storbyhave', 'Valby Gl. Skole', 'Store Valbygård']

    Scenario: Search is case insensitive
        Then param q = 'Valbyparken'

        When method GET
        Then status 200
        And def firstresponse = response
        And match firstresponse == '#[1]'

        Then param q = 'valbyparken'

        When method GET
        Then status 200
        And def secondresponse = response
        And match secondresponse == '#[1]'

        Then match firstresponse == secondresponse

        Then param q = 'VALBYPARKEN'

        When method GET
        Then status 200
        And def thirdresponse = response
        And match thirdresponse == '#[1]'

        Then match thirdresponse == secondresponse

    Scenario: Combined search
        Then param q = 'valby park'

        When method GET
        Then status 200
        And match response == '#[1]'
        And match response.[*].skrivemaade_officiel contains deep ['Valbyparken']

    Scenario: Do not have a match on '.'
        Then param q = '.'

        When method GET
        Then status 200
        And match response == '#[0]'

    Scenario: Test maximum limit and one character search
        Then param q = 's'

        And param limit = '100'
        When method GET
        Then status 200
        And match response == '#[100]'

    Scenario: Partial string
        Then param q = 'retten i aa'

        When method GET
        Then status 200
        And match response == '#[2]'
        And match response.[*].visningstekst contains deep ['Retten i Aalborg (Bygning i Aalborg)', 'Retten i Århus (Bygning i Aarhus C)']

    Scenario: Test that upper and lower case gives the same result
        Then param q = 'Ø'

        And param limit = '10'
        When method GET
        Then status 200
        And match response == '#[10]'

        Then param q = 'ø'

        And param limit = '10'
        When method GET
        Then status 200
        And def secondResponse = response
        And match secondResponse == '#[10]'

        And match response == secondResponse

    Scenario: Find a stednavn that only has an uofficielt skrivemaade
        Then param q = 'Chokola'

        And param limit = '10'
        When method GET
        Then status 200
        And match response == '#[1]'
        And match response.[*].skrivemaade_uofficiel contains ['Chokoladekrydset']

    Scenario: Search find the same adresse regards if there is - og multiple whitespaces
        Then param q = 'Wakeup Copenhagen Bernstorffsgade'

        When method GET
        Then status 200
        And match response == '#[1]'

        Then param q = 'Wakeup Copenhagen - Bernstorffsgade'

        When method GET
        Then status 200
        And def secondresponse = response
        And match secondresponse == '#[1]'

        Then match response == secondresponse

        Then param q = 'Wakeup Copenhagen  Bernstorffsgade'

        When method GET
        Then status 200
        And def thirdresponse = response
        And match thirdresponse == '#[1]'

        Then match thirdresponse == secondresponse

    Scenario: Filter sogn in like
        Then param q = 'kokholm'

        And param filter = "kommunekode like '%0787%'"
        When method GET
        Then status 200
        And match response == '#[2]'

    Scenario: Levenshtein ordering test
        Then param q = 'lind'

        When method GET
        Then status 200
        And match response == '#[10]'
        And match response.[0].skrivemaade_officiel contains 'Lind'

    Scenario: Test 2196 crs response
        Then param q = 's'
        And param limit = '1'
        And param srid = 2196
  
        When method GET
        Then status 200
        And match header Content-Crs == '<https://www.opengis.net/def/crs/EPSG/0/2196>'
        And match response == '#[1]'
  
    Scenario: Test 2197 crs response
        Then param q = 's'
        And param limit = '1'
        And param srid = 2197
        When method get
        Then status 200
        And match header Content-Crs == '<https://www.opengis.net/def/crs/EPSG/0/2197>'
        And match response == '#[1]'
  
    Scenario: Test 2198 crs response
        Then param q = 's'
        And param limit = '1'
        And param srid = 2198
  
        When method get
        Then status 200
        And match header Content-Crs == '<https://www.opengis.net/def/crs/EPSG/0/2198>'
        And match response == '#[1]'
  
    Scenario: Test 3857 crs response
        Then param q = 's'
        And param limit = '1'
        And param srid = 3857
  
        When method get
        Then status 200
        And match header Content-Crs == '<https://www.opengis.net/def/crs/EPSG/0/3857>'
        And match response == '#[1]'
  
    Scenario: Test 4093 crs response
        Then param q = 's'
        And param limit = '1'
        And param srid = 4093
  
        When method get
        Then status 200
        And match header Content-Crs == '<https://www.opengis.net/def/crs/EPSG/0/4093>'
        And match response == '#[1]'
  
    Scenario: Test 4094 crs response
        Then param q = 's'
        And param limit = '1'
        And param srid = 4094
  
        When method get
        Then status 200
        And match header Content-Crs == '<https://www.opengis.net/def/crs/EPSG/0/4094>'
        And match response == '#[1]'
  
    Scenario: Test 4095 crs response
        Then param q = 's'
        And param limit = '1'
        And param srid = 4095
        
        When method get
        Then status 200
        And match header Content-Crs == '<https://www.opengis.net/def/crs/EPSG/0/4095>'
        And match response == '#[1]'
  
    Scenario: Test 4096 crs response
        Then param q = 's'
        And param limit = '1'
        And param srid = 4096
  
        When method get
        Then status 200
        And match header Content-Crs == '<https://www.opengis.net/def/crs/EPSG/0/4096>'
        And match response == '#[1]'
  
    Scenario: Test 4326 crs response
        Then param q = 's'
        And param limit = '1'
        And param srid = 4326
  
        When method get
        Then status 200
        And match header Content-Crs == '<https://www.opengis.net/def/crs/EPSG/0/4326>'
        And match response == '#[1]'
  
    Scenario: Test 25832 crs response
        Then param q = 's'
        And param limit = '1'
        And param srid = 25832 
  
        When method get
        Then status 200
        And match header Content-Crs == '<https://www.opengis.net/def/crs/EPSG/0/25832>'
        And match response == '#[1]'
  
    Scenario: Test 25833 crs response
        Then param q = 's'
        And param limit = '1'
        And param srid = 25833 
  
        When method get
        Then status 200
        And match header Content-Crs == '<https://www.opengis.net/def/crs/EPSG/0/25833>'
        And match response == '#[1]'
