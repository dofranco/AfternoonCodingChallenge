@isTest
public class DeliveryHandlerTest {

    // Test class setup
    @testSetup
    static void setup() {
        // Create test data
        Class_Delivery__c delivery = new Class_Delivery__c(Name = 'className');
        insert delivery;
    }

    // Test createClassDelivery method
    @isTest
    static void testCreateClassDelivery() {
        Test.startTest();
        DeliveryHandler.createClassDelivery('Python');
        Test.stopTest();

        // Verify the record is created
        Class_Delivery__c newDelivery = [SELECT Id, Name FROM Class_Delivery__c WHERE Name = 'Python'];

        System.assertEquals('Python', newDelivery.Name);
    }

    // Test deleteClassDelivery method
    @isTest
    static void testDeleteClassDelivery() {
        // Get an existing delivery record
        List<Class_Delivery__c> deliveries = [SELECT Id, Name FROM Class_Delivery__c LIMIT 1];
        System.assert(!deliveries.isEmpty(), 'Expected at least one Class_Delivery__c record.');
        Class_Delivery__c delivery = deliveries[0];

        Test.startTest();
        DeliveryHandler.deleteClassDelivery(delivery.Id);
        Test.stopTest();

        // Verify the record is deleted
        Integer count = [SELECT COUNT() FROM Class_Delivery__c WHERE Id = :delivery.Id];
        System.assertEquals(0, count);
    }

    // Test changeCourseToDotNet method
    @isTest
    static void testChangeCourseToDotNet() {
        // Get an existing delivery record
        List<Class_Delivery__c> deliveries = [SELECT Id, Name FROM Class_Delivery__c LIMIT 1];
        System.assert(!deliveries.isEmpty(), 'Expected at least one Class_Delivery__c record.');
        Class_Delivery__c delivery = deliveries[0];

        Test.startTest();
        DeliveryHandler.changeCourseToDotNet(delivery.Id);
        Test.stopTest();

        // Verify the course was updated to "DotNet"
        Class_Delivery__c updatedDelivery = [SELECT Id, Name FROM Class_Delivery__c WHERE Id = :delivery.Id];
        System.assertEquals('DotNet', updatedDelivery.Name);
    }

    // Test full CRED permissions
    @isTest
    static void testFullPermissions() {
        User salesManager = [SELECT Id, Email FROM User WHERE Username = 'salesman@mail.com' LIMIT 1];

        List<Class_Delivery__c> deliveries = [SELECT Id, Name FROM Class_Delivery__c LIMIT 1];
        System.assert(!deliveries.isEmpty(), 'Expected at least one Class_Delivery__c record.');
        Class_Delivery__c delivery = deliveries[0];

        salesManager.IsActive = true;
        update salesManager;

        System.runAs(salesManager) {
            // SUCCEED: Creating a Class Delivery record
            DeliveryHandler.createClassDelivery('Java');
    
            // Verify the record is created
            Class_Delivery__c newDelivery = [SELECT Id, Name FROM Class_Delivery__c WHERE Name = 'Java'];
    
            System.assertEquals('Java', newDelivery.Name);

            // Succeed: Updating a Class Delivery record
            DeliveryHandler.changeCourseToDotNet(newDelivery.Id);
    
            // Verify the course was updated to "DotNet"
            Class_Delivery__c updatedDelivery = [SELECT Id, Name FROM Class_Delivery__c WHERE Id = :newDelivery.Id];
            System.assertEquals('DotNet', updatedDelivery.Name);

            //SUCCEED: Deleting a record
            DeliveryHandler.deleteClassDelivery(updatedDelivery.Id);

            // Verify the record is deleted
            Integer count = [SELECT COUNT() FROM Class_Delivery__c WHERE Id = :updatedDelivery.Id];
            System.assertEquals(0, count);
        }

        salesManager.IsActive = false;
        update salesManager;
    }

    // Test some permissions
    @isTest
    static void testSomePermissions() {
        User salesPerson = [SELECT Id, Email FROM User WHERE Username = 'validsales1@mail.com' LIMIT 1];

        List<Class_Delivery__c> deliveries = [SELECT Id, Name FROM Class_Delivery__c LIMIT 1];
        System.assert(!deliveries.isEmpty(), 'Expected at least one Class_Delivery__c record.');
        Class_Delivery__c delivery = deliveries[0];

        salesPerson.IsActive = true;

        update salesPerson;

        System.runAs(salesPerson) {
            //FAIL: Deleting a record
            try {
                Test.startTest();
                DeliveryHandler.deleteClassDelivery(delivery.Id);
                Test.stopTest();
                System.assert(false, 'Expected SecurityException for insufficient delete permissions.');
            } catch (SecurityException e) {
                System.assert(e.getMessage().contains('You do not have permission to delete Class Delivery records.'));
            }

            // SUCCEED: Creating a Class Delivery record
            DeliveryHandler.createClassDelivery('Java');
    
            // Verify the record is created
            Class_Delivery__c newDelivery = [SELECT Id, Name FROM Class_Delivery__c WHERE Name = 'Java'];
    
            System.assertEquals('Java', newDelivery.Name);

            // Succeed: Updating a Class Delivery record
            DeliveryHandler.changeCourseToDotNet(newDelivery.Id);
    
            // Verify the course was updated to "DotNet"
            Class_Delivery__c updatedDelivery = [SELECT Id, Name FROM Class_Delivery__c WHERE Id = :newDelivery.Id];
            System.assertEquals('DotNet', updatedDelivery.Name);
        }

        salesPerson.IsActive = false;
        update salesPerson;
    }

    // Test insufficient permissions
    @isTest
    static void testInsufficientPermissions() {
        User invalidUser = [SELECT Id, Email FROM User WHERE Username = 'invaliduser@mail.com' LIMIT 1];

        List<Class_Delivery__c> deliveries = [SELECT Id, Name FROM Class_Delivery__c LIMIT 1];
        System.assert(!deliveries.isEmpty(), 'Expected at least one Class_Delivery__c record.');
        Class_Delivery__c delivery = deliveries[0];

        invalidUser.IsActive = true;
        update invalidUser;

        System.runAs(invalidUser) {
            //FAIL: Deleting a record
            try {
                Test.startTest();
                DeliveryHandler.deleteClassDelivery(delivery.Id);
                Test.stopTest();
                System.assert(false, 'Expected SecurityException for insufficient delete permissions.');
            } catch (SecurityException e) {
                System.assert(e.getMessage().contains('You do not have permission to delete Class Delivery records.'));
            }

            // FAIL: Creating a Class Delivery record
            try {
                DeliveryHandler.createClassDelivery('Ruby');
                System.assert(false, 'Expected SecurityException for insufficient create permissions.');
            } catch (SecurityException e) {
                System.assert(e.getMessage().contains('You do not have permission to create Class Delivery records.'));
            }

            // FAIL: Updating a Class Delivery record
            try {
                DeliveryHandler.changeCourseToDotNet(delivery.Id);
                System.assert(false, 'Expected SecurityException for insufficient update permissions.');
            } catch (SecurityException e) {
                System.assert(e.getMessage().contains('You do not have permission to update Class Delivery records.'));
            }
        }

        invalidUser.IsActive = false;
        update invalidUser;
    }
}
