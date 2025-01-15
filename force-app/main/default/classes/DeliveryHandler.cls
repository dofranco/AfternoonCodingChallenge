public with sharing class DeliveryHandler {
    public DeliveryHandler() {

    }

    // Method to create a Class Delivery record
    public static void createClassDelivery(String courseName) {
        // Enforce object and field-level security
        if (!Schema.sObjectType.Class_Delivery__c.isCreateable()) {
            throw new SecurityException('You do not have permission to create Class Delivery records.');
        }

        // Create a new Class Delivery record
        Class_Delivery__c delivery = new Class_Delivery__c(Name = courseName);

        insert delivery;
    }

    // Method to delete a Class Delivery record by ID
    public static void deleteClassDelivery(Id deliveryId) {
        // Query the record while enforcing record-level security
        List<Class_Delivery__c> delivery = [SELECT Id FROM Class_Delivery__c WHERE Id = :deliveryId LIMIT 1];
        // Enforce delete permissions
        if (!Schema.sObjectType.Class_Delivery__c.isDeletable()) {
            throw new SecurityException('You do not have permission to delete Class Delivery records.');
        }

        delete delivery[0];
    }

    // Method to change the course of a delivery
    public static void changeCourseToDotNet(Id deliveryId) {
        // Query the record while enforcing record-level security
        List<Class_Delivery__c> delivery = [SELECT Id, Name FROM Class_Delivery__c WHERE Id = :deliveryId LIMIT 1];
        // Enforce update permissions
        if (!Schema.sObjectType.Class_Delivery__c.isUpdateable()) {
            throw new SecurityException('You do not have permission to update Class Delivery records.');
        }

        // Change the course to "DotNet"
        delivery[0].Name = 'DotNet';
        update delivery;
    }
}