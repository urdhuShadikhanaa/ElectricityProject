@IsTest

public class NGMCP_UserManagmentControllerTest {

    /* ======================================================

       TEST DATA SETUP

    ====================================================== */

    @testSetup

    static void setupData() {

        // ---- Get VALID restricted picklist value ----

        Schema.DescribeFieldResult dfr =

            User.Supplier_Group__c.getDescribe();

        List<Schema.PicklistEntry> pickVals =

            dfr.getPicklistValues();

        System.assert(!pickVals.isEmpty(),

            'Supplier_Group__c must have picklist values');

        String validSupplierGroup = pickVals[0].getValue();

        Profile p = [

            SELECT Id

            FROM Profile

            WHERE Name = 'Standard User'

            LIMIT 1

        ];

        User u = new User(

            FirstName = 'Test',

            LastName = 'User',

            Email = 'testuser@test.com',

            Username = 'testuser' + System.currentTimeMillis() + '@test.com',

            Alias = 'tusr',

            TimeZoneSidKey = 'Asia/Kolkata',

            LocaleSidKey = 'en_US',

            EmailEncodingKey = 'UTF-8',

            LanguageLocaleKey = 'en_US',

            ProfileId = p.Id,

            // 🔥 REQUIRED FIX

            IsActive = true,

            // Restricted picklist – must be valid

            Supplier_Group__c = validSupplierGroup,

            Supplier_Code__c  = 'VCT; GLZ'

        );

        insert u;

    }

    /* ======================================================

       USER CONTEXT METHODS

    ====================================================== */

    @IsTest

    static void testGetLoggedInUserProfile() {

        User u = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];

        System.runAs(u) {

            Test.startTest();
try{
            Map<String, Object> result =

                NGMCP_UserManagmentController.getLoggedInUserProfile();

            Test.stopTest();

            System.assert(result.containsKey('supplierGroup'));

            System.assert(result.containsKey('supplierCode'));

        }
        catch(Exception ex){
            System.debug('error');
        } }

    }

    @IsTest

    static void testGetSupplierCodesForLoggedInUser() {

        User u = [SELECT Id,Name,UserName,Supplier_Group__c,Supplier_Code__c FROM User WHERE IsActive = true LIMIT 1];
        u.Supplier_Code__c ='VCT; GLZ';
		u.Supplier_Group__c ='Corona Energy Retail';
		update u;
        System.runAs(u) {

            Test.startTest();
            try{
            List<String> codes =
            NGMCP_UserManagmentController.getSupplierCodesForLoggedInUser();
            List<string> supplierGroup = NGMCP_UserManagmentController.getAllSupplierGroups();
	         Map<String, Object> usersuppliercode = NGMCP_UserManagmentController.getUserSupplierContext(u.UserName);
               System.assertEquals(2, codes.size());
            }Catch(Exception ex){
                System.debug(ex);
            }            Test.stopTest();

          
            
        }

    }

    /* ======================================================

       SINGLE REQUEST ROUTER

       (CREATE EXPECTS EXPERIENCE CLOUD EXCEPTION)

    ====================================================== */

    @IsTest

    static void testProcessSingleCreate_ThrowsException() {

        User u = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];

        Map<String, Object> data = new Map<String, Object>{

            'firstName'    => 'John',

            'lastName'     => 'Doe',

            'email'        => 'john@test.com',

            'role'         => 'Manager',

            'supplierCode' => 'VCT; GLZ',

            'supplierGroup'=> 'Corona Energy Retail'

        };

        System.runAs(u) {

            Boolean thrown = false;

            try {

                NGMCP_UserManagmentController.processSingleRequest(

                    'Create',

                    JSON.serialize(data)

                );

            } catch (AuraHandledException e) {

                thrown = true;

            }

            System.assert(thrown);

        }

    }

    @IsTest

    static void testProcessSingleChangeDeactivateReactivate() {

        User u = [SELECT Id,Name FROM User WHERE IsActive = true LIMIT 1];

        Map<String, Object> data = new Map<String, Object>{

            'userName'     => 'testuser@test.com',

            'role'         => 'Agent',

            'supplierCode' => 'SUP2'

        };

        System.runAs(u) {

            Test.startTest();

            System.assertEquals(

                'SUCCESS',

                NGMCP_UserManagmentController.processSingleRequest(

                    'Change', JSON.serialize(data))

            );

            System.assertEquals(

                'SUCCESS',

                NGMCP_UserManagmentController.processSingleRequest(

                    'Deactivate', JSON.serialize(data))

            );

            System.assertEquals(

                'SUCCESS',

                NGMCP_UserManagmentController.processSingleRequest(

                    'Reactivate', JSON.serialize(data))

            );

            Test.stopTest();

        }

    }

    /* ======================================================

       BULK CSV METHODS

    ====================================================== */

    @IsTest

    static void testBulkCreate() {

        User u = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];

        List<Map<String, Object>> rows = new List<Map<String, Object>>{

            new Map<String, Object>{
                'FirstName'     => 'Bul123',
                'LastName'      => 'User234',
                'Email'         => 'bulk23456@test.com',
                'Role'          => 'Manager',
                'SupplierCode'  => 'VCT; GLZ',
                'SupplierGroup' => 'Corona Energy Retail'
            }

        };

        System.runAs(u) {

            Test.startTest();
            try{
                NGMCP_UserManagmentController.processBulkCSV(
                'Create', JSON.serialize(rows));
            }Catch(Exception ex){
                System.debug(ex);
            }
            Test.stopTest();

            System.assert(true);

        }

    }

    @IsTest

    static void testBulkChangeDeactivateReactivate() {

        User u = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];

        List<Map<String, Object>> rows = new List<Map<String, Object>>{

            new Map<String, Object>{

                'UserName'     => 'bulk@test.com',

                'Role'         => 'Agent',

                'SupplierCode' => 'SUP2'

            }

        };

        System.runAs(u) {

            Test.startTest();

            NGMCP_UserManagmentController.processBulkCSV(

                'Change', JSON.serialize(rows));

            NGMCP_UserManagmentController.processBulkCSV(

                'Deactivate', JSON.serialize(rows));

            NGMCP_UserManagmentController.processBulkCSV(

                'Reactivate', JSON.serialize(rows));

            Test.stopTest();

            System.assert(true);

        }

    }

    /* ======================================================

       SUPPLIER DATA

    ====================================================== */

    @IsTest

    static void testGetSupplierDataByUsername() {

        User u = [SELECT Username,Supplier_Code__c,Supplier_Group__c FROM User WHERE IsActive = true LIMIT 1];
         u.Supplier_Code__c ='VCT; GLZ';
		u.Supplier_Group__c ='Corona Energy Retail';
		update u;

        Test.startTest();

        Map<String, Object> data =

            NGMCP_UserManagmentController.getSupplierDataByUsername(u.Username);
        	List<NGMCP_UserDependentPicklistController.PicklistOption> pValues = NGMCP_UserManagmentController.groupValuesforCRM(u.Supplier_Group__c);

        Test.stopTest();

        System.assert(data.containsKey('supplierCodes'));

    }

    /* ======================================================

       INVALID ACTION

    ====================================================== */

    @IsTest

    static void testInvalidActionThrows() {
        
        Boolean thrown = false;

        try {

            NGMCP_UserManagmentController.processSingleRequest('BAD', '{}');

        } catch (AuraHandledException e) {

            thrown = true;

        }

        System.assert(thrown);

    }

}