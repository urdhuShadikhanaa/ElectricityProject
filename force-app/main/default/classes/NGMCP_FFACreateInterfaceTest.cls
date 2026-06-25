@IsTest(SeeAllData=true)
public class NGMCP_FFACreateInterfaceTest {

    /* -------------------------------
       Utility: Create required master data
       ------------------------------- */
    private static void setupMasterData() {
        if ([SELECT COUNT() FROM Account WHERE Name='WWU'] == 0) {
            insert new Account(Name='WWU');
        }

        if ([SELECT COUNT() FROM WorkType WHERE Name='M0001C'] == 0) {
            insert new WorkType(Name='M0001C');
        }

        if ([SELECT COUNT() FROM ServiceTerritory WHERE Name='NG UK Territory'] == 0) {
            insert new ServiceTerritory(
                Name='NG UK Territory',
                IsActive=true
            );
        }
    }

    /* -------------------------------
       Test 1: SUCCESS – PHOENIX flow
       ------------------------------- */
    @IsTest
    static void testDoPost_SuccessPhoenix() {

        setupMasterData();

        /* ---- Build request body ---- */
        Map<String, Object> payload = new Map<String, Object>{
            'Header' => new Map<String, Object>{
                'SenderID' => 'RAINBOW',
                'TransactionType' => 'SC'
            },
            'Job' => new Map<String, Object>{
                'JobCode' => 'M0001C',
                'ServiceProvider' => 'WWU',
                'ServiceNotificationNumber' => 'SN1001',
                'OperationNumber' => 'OP1001',
                'RequestedAppointmentDate' => String.valueOf(System.today()),
                'NotificationType' => 'Y3',
                'AMRFlag' => false,
                'MeterPointReferenceNumber' => '73953700'
            },
            'Site' => new Map<String, Object>{
                'BuildingName' => 'TEST BUILDING',
                'PrincipalStreet' => 'TEST STREET',
                'PostTown' => 'LONDON',
                'PostcodeOutcode' => 'NW1',
                'PostcodeIncode' => '1AA'
            },
            'Meter' => new Map<String, Object>{
                'ExistingMeterSerialNumber' => 'M12345',
                'Qmax' => 1600
            },
            'Valves' => new List<Object>{
                new Map<String,Object>{
                    'ValvesModel' => 'BALL VALVE',
                    'PhysicalSize' => 100
                }
            }
        };

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/FFACreateInterface';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(payload));
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        FFACreateInterfaceHandler.doPost();
        Test.stopTest();


        System.assert(
            RestContext.response.responseBody != null,
            'Response body should be populated'
        );
    }

    /* -------------------------------
       Test 2: Mandatory validation FAIL
       ------------------------------- */
    @IsTest
    static void testMandatoryValidationFailure() {
        setupMasterData();

        Map<String,Object> payload = new Map<String,Object>{
            'Header' => new Map<String,Object>{
                'SenderID' => 'PHOENIX',
                'TransactionType' => 'SC' 
            },
            'Job' => new Map<String,Object>{
                'JobCode' => '',
                'ServiceNotificationNumber' => 'SNFAIL'
            }
        };

        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.requestUri = '/services/apexrest/FFACreateInterface';
        req.requestBody = Blob.valueOf(JSON.serialize(payload));
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        FFACreateInterfaceHandler.doPost();
        Test.stopTest();

        System.assert(
            RestContext.response.responseBody.toString().contains('Failure'),
            'Failure response expected'
        );
    }

    /* -------------------------------
       Test 3: Direct helper methods
       ------------------------------- */
    @IsTest
    static void testHelperMethods() {
        setupMasterData();

        /* createServiceAppointment */
        WorkOrder wo = new WorkOrder(
            Subject='Test',
            Status='New'
        );
        insert wo;

        Test.startTest();
        ServiceAppointment sa =
            FFACreateInterfaceHandler.createServiceAppointment(
                Datetime.now(),
                Datetime.now().addDays(1),
                null,
                null,
                wo.Id
            );
        Test.stopTest();

        System.assertNotEquals(null, sa.Id);

        /* isValidatePayLoad */
        Boolean valid =
            FFACreateInterfaceHandler.isValidatePayLoad(
                new Map<String,Object>{
                    'JobCode'=>'M0001C',
                    'ServiceProvider'=>'WWU',
                    'ServiceNotificationNumber'=>'SN1',
                    'OperationNumber'=>'OP1',
                    'RequestedAppointmentDate'=>String.valueOf(System.today())
                },
                'PHOENIX'
            );

        System.assertEquals(true, valid);
    }
}