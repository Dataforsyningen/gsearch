Feature: Gsearch politikreds test

    Background:
        * url url + '/politikreds'

    Scenario: politikreds
        Then param q = 'Nordjylland'

        When method GET
        Then status 200
        And match response == '#[1]'
        And def bboxSchema = {type: 'Polygon', coordinates: '#array'}
        And def geometriSchema = {type: 'MultiPolygon', coordinates: '#array'}
        And match response contains deep
        """
        {
        "visningstekst": '#string',
        "bbox": '#(bboxSchema)',
        "politikredsnummer": '#string',
        "geometri": '#(geometriSchema)',
        "politikredsnummer": '#string',
        "myndighedskode": '#string'
        }
        """

    Scenario: Partial string
        Then param q = 'nord'

        When method GET
        Then status 200
        And match response == '#[2]'
        And match response.[*].visningstekst contains deep ['Nordjyllands Politikreds', 'Nordsjællands Politikreds']

    Scenario: Search is case insensitive
        Then param q = 'Nordjylland'

        When method GET
        Then status 200
        And def firstresponse = response
        And match firstresponse == '#[1]'

        Then param q = 'nordjylland'

        When method GET
        Then status 200
        And def secondresponse = response
        And match secondresponse == '#[1]'

        Then match firstresponse == secondresponse

        Then param q = 'NORDJYLLAND'

        When method GET
        Then status 200
        And def thirdresponse = response
        And match thirdresponse == '#[1]'

        Then match thirdresponse == secondresponse

    Scenario: Do not have a match on '.'
        Then param q = '.'

        When method GET
        Then status 200
        And match response == '#[0]'
