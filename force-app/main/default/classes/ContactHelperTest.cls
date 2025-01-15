@isTest
public class ContactHelperTest {

    @isTest
    static void testValidEmailDomains() {
        Account testAccount = new Account(Name = 'Edge Communications');
        insert testAccount;

        Contact existingContact1 = new Contact(FirstName = 'John', LastName = 'Doe', 
                                               Email = 'john@edgecomm.org', AccountId = testAccount.Id);
        Contact existingContact2 = new Contact(FirstName = 'Jane', LastName = 'Smith', 
                                               Email = 'jane@edgecomm.org', AccountId = testAccount.Id);
        insert new List<Contact>{existingContact1, existingContact2};

        Contact newContact = new Contact(FirstName = 'Mike', LastName = 'Johnson', 
                                         Email = 'mike@edgecomm.org', AccountId = testAccount.Id);
        Test.startTest();
        insert newContact;
        Test.stopTest();

        System.assertNotEquals(null, newContact.Id, 'Contact with matching domain should be inserted successfully.');
    }

    @isTest
    static void testInvalidEmailDomains() {
        Account testAccount = new Account(Name = 'Edge Communications');
        insert testAccount;

        Contact existingContact = new Contact(FirstName = 'John', LastName = 'Doe', 
                                              Email = 'john@edgecomm.org', AccountId = testAccount.Id);
        insert existingContact;

        Contact invalidContact = new Contact(FirstName = 'Anna', LastName = 'Williams', 
                                             Email = 'anna@otherdomain.com', AccountId = testAccount.Id);

        Test.startTest();
        try {
            insert invalidContact;
            System.assert(false, 'Expected an exception for mismatched email domain.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Email domain must match existing contacts within the account.'),
                          'Expected error message about email domain mismatch.');
        }
        Test.stopTest();
    }
}