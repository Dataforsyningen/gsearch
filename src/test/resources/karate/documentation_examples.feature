Feature:
    Background:
        * url url

    Scenario: Example 1 
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/navngivenvej?q=Lærke
        Given path 'navngivenvej'
        Then param q = 'Lærke'

        When method GET
        Then status 200
        And match response == '#[10]'

    Scenario: Example 2 
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/navngivenvej?q=vinkel&limit=90
        Given path 'navngivenvej'
        Then param q = 'vinkel'

        And param limit = '90'
        When method GET
        Then status 200
        And match response == '#[90]'

    Scenario: Example 3
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/husnummer?q=lærke&filter=kommunekode like '%250461%25'
        Given path 'husnummer'
        Then param q = 'Lærke'

        And param filter = "kommunekode like '%0461%'"
        And retry until responseStatus == 200
        When method GET
        And match response == '#[10]'


    Scenario: Example 4
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/stednavn?q=ben&filter=INTERSECTS(geometri,SRID=25832;POLYGON((515000.1 6074200.2, 515000.3 6104200.4, 555000.5 6104200.6, 555000.7 6074200.8, 515000.1 6074200.2)))
        Given path 'stednavn'
        Then param q = 'ben'

        And param filter = 'INTERSECTS(geometri,SRID=25832;POLYGON((515000.1 6074200.2, 515000.3 6104200.4, 555000.5 6104200.6, 555000.7 6074200.8, 515000.1 6074200.2)))'
        And retry until responseStatus == 200
        When method GET
        And match response == '#[3]'

    Scenario: Example 5
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/adresse?q=flens
        Given path 'adresse'
        Then param q = 'flens'

        When method GET
        Then status 200
        And match response == '#[10]'

    Scenario: Example 6
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/adresse?limit=30&q=fle&filter=kommunekode like '%250360%25'
        Given path 'adresse'
        Then param q = 'fle'

        And param filter = "kommunekode like '%0360%'"
        When method GET
        Then status 200
        And match response == '#[10]'

    Scenario: Example 7
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/adresse?limit=100&q=skanse&filter=INTERSECTS(vejpunkt_geometri,SRID=25832;POLYGON((515000.1 6074200.2, 515000.3 6104200.4, 555000.5 6104200.6, 555000.7 6074200.8, 515000.1 6074200.2)))
        Given path 'adresse'
        Then param q = 'skanse'

        And param limit = '100'
        And param filter = 'INTERSECTS(vejpunkt_geometri,SRID=25832;POLYGON((515000.1 6074200.2, 515000.3 6104200.4, 555000.5 6104200.6, 555000.7 6074200.8, 515000.1 6074200.2)))'
        And retry until responseStatus == 200
        When method GET
        And match response == '#[24]'


    Scenario: Example 8
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/husnummer?q=genvej
        Given path 'husnummer'
        Then param q = 'genvej'

        When method GET
        Then status 200
        And match response == '#[10]'

    Scenario: Example 9
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/husnummer?limit=30&q=fl&filter=kommunekode like '%250376%25'
        Given path 'husnummer'
        Then param q = 'fl'

        And param limit = '30'
        And param filter = "kommunekode like '%0376%'"
        When method GET
        Then status 200
        And match response == '#[30]'

    Scenario: Example 10
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/husnummer?limit=100&q=fjordbak&filter=INTERSECTS(geometri,SRID=25832;POLYGON((615000.1 6049000.2, 615000.3 6111000.4, 735000.5 6111000.6, 735000.7 6049000.8, 615000.1 6049000.2)))
        Given path 'husnummer'
        Then param q = 'fjordbak'

        And param limit = '100'
        And param filter = 'INTERSECTS(geometri,SRID=25832;POLYGON((615000.1 6049000.2, 615000.3 6111000.4, 735000.5 6111000.6, 735000.7 6049000.8, 615000.1 6049000.2)))'
        And retry until responseStatus == 200
        When method GET
        And match response == '#[45]'


    Scenario: Example 11
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/kommune?q=a
        Given path 'kommune'
        Then param q = 'a'

        When method GET
        Then status 200
        And match response == '#[7]'

    Scenario: Example 12
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/kommune?q=a&filter=kommunekode like '%250851%25'
        Given path 'kommune'
        Then param q = 'a'

        And param filter = "kommunekode like '%0851%'"
        When method GET
        Then status 200
        And match response == '#[1]'

    Scenario: Example 13
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/kommune?q=l&filter=INTERSECTS(geometri,SRID=25832;POLYGON((615000.1 6049000.2, 615000.3 6111000.4, 735000.5 6111000.6, 735000.7 6049000.8, 615000.1 6049000.2)))
        Given path 'kommune'
        Then param q = 'l'

        And param filter = 'INTERSECTS(geometri,SRID=25832;POLYGON((615000.1 6049000.2, 615000.3 6111000.4, 735000.5 6111000.6, 735000.7 6049000.8, 615000.1 6049000.2)))'
        #And param filter = 'INTERSECTS(geometri,SRID=25832;POLYGON((530000.1 6085450.2, 530000.3 6092950.4, 540000.5 6092950.6, 540000.7 6085450.8, 530000.1 6085450.2)))'
        And retry until responseStatus == 200
        When method GET
        And match response == '#[2]'


    Scenario: Example 14
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/matrikel?q=123ab
        Given path 'matrikel'
        Then param q = '123ab'

        When method GET
        Then status 200
        And match response == '#[6]'

    Scenario: Example 15
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/matrikel?q=123ab&filter=ejerlavskode='130653'
        Given path 'matrikel'
        Then param q = '123ab'

        And param filter = "ejerlavskode='130653'"
        When method GET
        Then status 200
        And match response == '#[1]'

    Scenario: Example 16
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/matrikel?q=a&filter=bfenummer='100032397'
        Given path 'matrikel'
        Then param q = 'a'

        And param filter = "bfenummer='100032397'"
        When method GET
        Then status 200
        And match response == '#[10]'

    Scenario: Example 17
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/matrikel?q=2&filter=INTERSECTS(geometri,SRID=25832;POLYGON((530000.1 6085450.2, 530000.3 6092950.4, 540000.5 6092950.6, 540000.7 6085450.8, 530000.1 6085450.2)))
        Given path 'matrikel'
        Then param q = '2'

        And param filter = 'INTERSECTS(geometri,SRID=25832;POLYGON((530000.1 6085450.2, 530000.3 6092950.4, 540000.5 6092950.6, 540000.7 6085450.8, 530000.1 6085450.2)))'
        And retry until responseStatus == 200
        When method GET
        And match response == '#[10]'


    Scenario: Example 18
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/matrikel_udgaaet?q=11a
        Given path 'matrikel_udgaaet'
        Then param q = '11a'

        When method GET
        Then status 200
        And match response == '#[10]'

    Scenario: Example 19
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/matrikel_udgaaet?q=11a&filter=ejerlavskode='70854'
        Given path 'matrikel_udgaaet'
        Then param q = '11a'

        And param filter = "ejerlavskode='70854'"
        When method GET
        Then status 200
        And match response == '#[3]'

    Scenario: Example 20
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/matrikel_udgaaet?q=e&filter=bfenummer='5290287'
        Given path 'matrikel_udgaaet'
        Then param q = 'e'

        And param filter = "bfenummer='5290287'"
        When method GET
        Then status 200
        And match response == '#[1]'

    Scenario: Example 21
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/matrikel_udgaaet?q=10&filter=INTERSECTS(geometri,SRID=25832;POLYGON((530000.1 6085450.2, 530000.3 6092950.4, 540000.5 6092950.6, 540000.7 6085450.8, 530000.1 6085450.2)))
        Given path 'matrikel_udgaaet'
        Then param q = '1'

        And param filter = 'INTERSECTS(geometri,SRID=25832;POLYGON((530000.1 6085450.2, 530000.3 6092950.4, 540000.5 6092950.6, 540000.7 6085450.8, 530000.1 6085450.2)))'
        And retry until responseStatus == 200
        When method GET
        And match response == '#[10]'


    Scenario: Example 22
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/navngivenvej?q=birk&filter=INTERSECTS(geometri,SRID=25832;POLYGON((515000.1 6074200.2, 515000.3 6104200.4, 555000.5 6104200.6, 555000.7 6074200.8, 515000.1 6074200.2)))
        Given path 'navngivenvej'
        Then param q = 'birk'

        And param filter = 'INTERSECTS(geometri,SRID=25832;POLYGON((515000.1 6074200.2, 515000.3 6104200.4, 555000.5 6104200.6, 555000.7 6074200.8, 515000.1 6074200.2)))'
        And retry until responseStatus == 200
        When method GET
        And match response == '#[9]'


    Scenario: Example 23
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/opstillingskreds?q=vest
        Given path 'opstillingskreds'
        Then param q = 'vest'

        When method GET
        Then status 200
        And match response == '#[5]'

    Scenario: Example 24
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/opstillingskreds?q=vest&filter=storkredsnummer='6'
        Given path 'opstillingskreds'
        Then param q = 'vest'

        And param filter = "storkredsnummer='6'"
        When method GET
        Then status 200
        And match response == '#[1]'


    Scenario: Example 25
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/politikreds?q=vest
        Given path 'politikreds'
        Then param q = 'vest'

        When method GET
        Then status 200
        And match response == '#[3]'

    Scenario: Example 26
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/politikreds?q=ø&filter=INTERSECTS(geometri,SRID=25832;POLYGON((440000.1 6190000.2, 440000.3 6410000.4, 620000.5 6410000.6, 620000.7 6190000.8, 440000.1 6190000.2)))
        Given path 'politikreds'
        Then param q = 'ø'

        And param filter = 'INTERSECTS(geometri,SRID=25832;POLYGON((440000.1 6190000.2, 440000.3 6410000.4, 620000.5 6410000.6, 620000.7 6190000.8, 440000.1 6190000.2)))'
        And retry until responseStatus == 200
        When method GET
        And match response == '#[1]'


    Scenario: Example 27
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/postnummer?limit=60&q=b
        Given path 'postnummer'
        Then param q = 'b'

        And param limit = '60'
        When method GET
        Then status 200
        And match response == '#[54]'

    Scenario: Example 28
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/postnummer?q=mari
        Given path 'postnummer'
        Then param q = 'mari'

        When method GET
        Then status 200
        And match response == '#[2]'

    Scenario: Example 29
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/postnummer?q=mari&filter=INTERSECTS(geometri,SRID=25832;POLYGON((615000.1 6049000.2, 615000.3 6111000.4, 735000.5 6111000.6, 735000.7 6049000.8, 615000.1 6049000.2)))
        Given path 'postnummer'
        Then param q = 'mari'

        And param filter = 'INTERSECTS(geometri,SRID=25832;POLYGON((615000.1 6049000.2, 615000.3 6111000.4, 735000.5 6111000.6, 735000.7 6049000.8, 615000.1 6049000.2)))'
        And retry until responseStatus == 200
        When method GET
        And match response == '#[1]'


    Scenario: Example 30
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/region?q=mid
        Given path 'region'
        Then param q = 'mid'

        When method GET
        Then status 200
        And match response == '#[1]'

    Scenario: Example 31
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/region?q=regi
        Given path 'region'
        Then param q = 'regi'

        When method GET
        Then status 200
        And match response == '#[5]'


    Scenario: Example 32
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/retskreds?q=ros
        Given path 'retskreds'
        Then param q = 'ros'

        When method GET
        Then status 200
        And match response == '#[1]'

    Scenario: Example 33
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/retskreds?q=a
        Given path 'retskreds'
        Then param q = 'a'

        When method GET
        Then status 200
        And match response == '#[2]'


    Scenario: Example 34
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/sogn?q=bis
        Given path 'sogn'
        Then param q = 'bis'

        When method GET
        Then status 200
        And match response == '#[10]'

    Scenario: Example 35
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/sogn?q=skal
        Given path 'sogn'
        Then param q = 'skal'

        When method GET
        Then status 200
        And match response == '#[4]'

    Scenario: Example 36
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/sogn?q=r&filter=INTERSECTS(geometri,SRID=25832;POLYGON((625000.1 6165000.2, 625000.3 6215000.4, 677000.5 6215000.6, 677000.7 6165000.8, 625000.1 6165000.2)))
        Given path 'sogn'
        Then param q = 'r'

        And param filter = 'INTERSECTS(geometri,SRID=25832;POLYGON((625000.1 6165000.2, 625000.3 6215000.4, 677000.5 6215000.6, 677000.7 6165000.8, 625000.1 6165000.2)))'
        And retry until responseStatus == 200
        When method GET
        And match response == '#[5]'


    Scenario: Example 37
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/stednavn?q=kattebj
        Given path 'stednavn'
        Then param q = 'kattebj'

        When method GET
        Then status 200
        And match response == '#[3]'

    Scenario: Example 38
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/stednavn?limit=40&q=kratg
        Given path 'stednavn'
        Then param q = 'kratg'

        And param limit = '40'
        When method GET
        Then status 200
        And match response == '#[17]'

    Scenario: Example 39
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/stednavn?q=katte&filter=stednavn_type='bebyggelse'
        Given path 'stednavn'
        Then param q = 'katte'

        And param filter = "stednavn_type='bebyggelse'"
        When method GET
        Then status 200
        And match response == '#[5]'

    Scenario: Example 40
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/stednavn?q=katte&filter=stednavn_subtype='moseSump'
        Given path 'stednavn'
        Then param q = 'katte'

        And param filter = "stednavn_subtype='moseSump'"
        When method GET
        Then status 200
        And match response == '#[2]'

    Scenario: Example 41
        # https://api.dataforsyningen.dk/rest/gsearch/v1.0/stednavn?q=steng&filter=INTERSECTS(geometri,SRID=25832;POLYGON((625000.1 6165000.2, 625000.3 6215000.4, 677000.5 6215000.6, 677000.7 6165000.8, 625000.1 6165000.2)))
        Given path 'stednavn'
        Then param q = 'steng'

        And param filter = 'INTERSECTS(geometri,SRID=25832;POLYGON((625000.1 6165000.2, 625000.3 6215000.4, 677000.5 6215000.6, 677000.7 6165000.8, 625000.1 6165000.2)))'
        And retry until responseStatus == 200
        When method GET
        And match response == '#[4]'

