public with sharing class ContactHelper {
    public ContactHelper() {

    }

    public static void DomainValidation(List<Contact> cons){

        Set<Id> accountIds = new Set<Id>();
        Map<Id, Set<String>> accountDomains = new Map<Id, Set<String>>();
    
        // Collect Account IDs from incoming Contacts
        for (Contact con : cons) {
            if (con.AccountId != null) {
                accountIds.add(con.AccountId);
            }
        }
    
        // Query existing contacts and group domains by AccountId
        List<Contact> existingCons = [SELECT AccountId, Email FROM Contact WHERE AccountId IN :accountIds AND Email != null];
    
        for (Contact existingCon : existingCons) {
            String existingDomain = existingCon.Email.substringAfter('@').toLowerCase();
            if (!accountDomains.containsKey(existingCon.AccountId)) {
                accountDomains.put(existingCon.AccountId, new Set<String>());
            }
            accountDomains.get(existingCon.AccountId).add(existingDomain);
        }
    
        // Validate email domains for incoming Contacts
        for (Contact con : cons) {
            if (con.AccountId != null && String.isNotBlank(con.Email)) {
                String newDomain = con.Email.substringAfter('@').toLowerCase();
                Set<String> validDomains = accountDomains.get(con.AccountId);
    
                // Allow the first contact for an account to establish the domain
                if (validDomains == null) {
                    // If no existing contacts, let the first contact through and establish the domain
                    accountDomains.put(con.AccountId, new Set<String>{newDomain});
                } else if (!validDomains.contains(newDomain)) {
                    // Validate domain for accounts with existing contacts
                    con.addError('Email domain must match existing contacts within the account.');
                }
            }
        }
    }
}