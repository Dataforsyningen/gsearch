Feature: Gsearch matrikel test

    Background:
        * url url + '/matrikel_udgaaet'

    Scenario: Response matches columns database
        Then param q = '1450152'
        Then param limit = '1'

        When method GET
        Then status 200
        And match response == '#[1]'
        And def geometriSchema = {type: 'MultiPolygon', coordinates: '#array'}
        And match response contains only
        """
        {
            "ejerlavskode": '#number',
            "ejerlavsnavn": '#string',
            "visningstekst": '#string',
            "geometri": '#(geometriSchema)',
            "centroid_x": '#number',
            "centroid_y": '#number',
            "matrikelnummer": '#string',
            "kommunenavn": "#string",
            "kommunekode": "#string",
            "bfenummer": "#number",
            "jordstykke_id": "#number"
        }
        """

    Scenario: Partial string
        Then param q = 'Løgst'

        When method GET
        Then status 200
        And match response == '#[10]'

    Scenario: Search is case insensitive
        Then param q = 'Løgstør Markjorder'

        When method GET
        Then status 200
        And def firstresponse = response
        And match firstresponse == '#[9]'

        Then param q = 'løgstør markjorder'

        When method GET
        Then status 200
        And def secondresponse = response
        And match secondresponse == '#[9]'

        Then match firstresponse == secondresponse

        Then param q = 'LØGSTØR MARKJORDER'

        When method GET
        Then status 200
        And def thirdresponse = response
        And match thirdresponse == '#[9]'

        Then match thirdresponse == secondresponse

    Scenario: Combine search using ejerlavsnavn og matrikelnummer
        Then param q = '1430851 1000g'

        When method GET
        Then status 200
        And match response == '#[1]'
        And match response.[*].matrikelnummer contains deep ['1000g']
        And match response.[*].ejerlavsnavn contains deep ['Skrydstrup Ejerlav, Skrydstrup']

    Scenario: Combine search using ejerlavskode and ejerlavsnavn
        Then param q = 'utterslev'

        When method GET
        Then status 200
        And match response == '#[10]'
        And match response.[*].ejerlavsnavn contains deep ['Utterslev By, Utterslev']

    Scenario: Do not have a match on '.'
        Then param q = '.'

        When method GET
        Then status 200
        And match response == '#[0]'

    Scenario: Search is interchangeable order of ejerlavsnavn and matrikelnummer
        Then param q = '104, Ellum, Løgumkloster 1470453'

        When method GET
        Then status 200
        And def firstresponse = response
        And match firstresponse == '#[1]'

        Then param q = 'Ellum, Løgumkloster 1470453 104'

        When method GET
        Then status 200
        And def secondresponse = response
        And match secondresponse == '#[1]'

        Then match firstresponse == secondresponse

        Then param q = '1470453 104 Ellum, Løgumkloster'

        When method GET
        Then status 200
        And def thirdresponse = response
        And match thirdresponse == '#[1]'

        Then match thirdresponse == secondresponse

    Scenario: Filter bfe-nummer in like
        Then param q = 'v'

        And param filter = "bfenummer = '5753971'"
        When method GET
        Then status 200
        And match response == '#[1]'

    Scenario: Filter jordstykke_id in like
        Then param q = 'f'

        And param filter = "jordstykke_id = '1697026'"
        When method GET
        Then status 200
        And match response == '#[1]'

    Scenario: Test maximum limit and one character search
        Then param q = 's'

        And param limit = '100'
        When method GET
        Then status 200
        And match response == '#[100]'

    Scenario: Test string to double typecast of centroids
        Then param q = '401954 1bk'

        And param limit = '1'
        When method GET
        Then status 200
        And match response.[*].centroid_x contains deep [549053.048]
        And match response.[*].centroid_y contains deep [6150995.375]

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
        And match header Content-Crs == '<https://www.opengis.net/def/crs/EPSG/0/4396>'
        And match response == '#[100]'
  
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
