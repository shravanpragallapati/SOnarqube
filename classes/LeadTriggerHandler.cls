/**=====================================================================
* Appirio, Inc
* Name: LeadTriggerHandler
* Description: T-194935, On Lead conversion if billing address is not blank 
then create address record and associate that address with 
the converted account by creating the AccountAddress record
and associate converted contact by creating the ContactAddress record.
* Created Date: Nov 01st, 2013
* Created By: Manish Soni ( Appirio )
* 
* Date Modified        Modified By                  Description of the update
* Nov 19th, 2012       Pankaj Mehra(Appirio)        T-213204, Populate Marketing Activity contact lookup on conversion of lead
* Nov 21st, 2012       Shane Khublall(Appirio)      T-214619, Description : Populate Marketing Activity Account lookup on conversion of lead 
* Jan 31th, 2014       Naresh Kr Ojha(Appirio)      T-232755: Homogenize triggers 
* Jan 30th, 2014       Jinesh Goyal(Appirio)        T-232760: Homogenize the comments
* Mar 03rd, 2014       Arpita Bose (Appirio)        T-243282: Added Constants in place of String
* Mar 27th, 2014       Nathalie Le Guay             T-266743: Remove references to Primary_Billing__c & Primary_Shipping__c (unused)
* May 01st, 2014       Arpita Bose                  Updated catch(Exception) to catch(DMLException) to use getDMLException Line#63
* July 29th, 2014       Sadar Yacob                  Split the Lead Address based on commas or field length over 50 chars to addr1,addr2, addr3 etc
* Aug 25th, 2014        Sadar Yacob                  Use PostCode__c on Address instead of Zip__c on Lead conversion  
* Aug 27th, 2014        Sadar Yacob                  case 1441 : Split lead Address by Comma 
* Jun 29th, 2015        Arpita Bose                  Added Custom Label- Generic_message_for_system_error in catch block
* July 21th,2015        Noopur                       Added Method createIntegrationEventLog() - to create Integration Event Log in event of Deletion of Leads
* July 29th,2015        Arpita Bose                  Removed method createIntegrationEventLog() as Story is cancelled
* Sept 1st, 2015        Venkat Akula                 Added method to validate CNPJ and CPF Numbers validateCNPJandCPFNumbers()
* Oct 6th, 2015         Paul Kissick                 Fix for missing address id on converted leads, and for duplicated registered addresses on accounts
* Jul 18th, 2016        Manoj Gopu(QA)               CRM2:W-005436 Added new method populateOpportunityContactRole() to update the contact role to decider when creating new Opp on lead conversion
* Aug 12th, 2016        Paul Kissick                 CRM2:W-005663: Added support for IsDataAdmin==true on conversions - Also optimised class code
* Dec 11th, 2017        Malcolm Russell              DP Migration:W-009612: Prevent Duplicate Lead/Contact and instead add a task
* July 25th, 2019       Malcolm Russell              LEX - Change to lead conversion for Lex
* May 25th, 2021        Navya                        Case 22182953: Created new method updateOppApacAcv to update APAC ACV field in opportunity when a lead is converted
*July 7th, 2021         Navya                        W-033732: When a lead is converted to an opportunity the contact that's created should become the decision maker against the opportunity 
=====================================================================*/

public without sharing class LeadTriggerHandler {
    
    // Adding variables to hold converted leads before/after trigger
    private static Map<Id,Lead> convertedOldMap = new Map<Id,Lead>();
    private static Map<Id,Lead> convertedNewMap = new Map<Id,Lead>();
    
    public static Boolean isDataAdmin = false;  // New variable set from Trigger to know if current user isDataAdmin
    
    public static void beforeInsert(List<Lead> newList) {
        if (isDataAdmin == false) {
            //Check for CNPJ and CPF Numbers validity before insert
            LeadTriggerHandler.validateCNPJandCPFNumbers(newList);
            //MR DP Migration:W-009612: Prevent Duplicate Lead/Contact and instead add a task
            leadTriggerHandler.DPLeadcheck(newList);
        }
    }
    
    public static void afterInsert(List<Lead> newList) {
        if (isDataAdmin == false) {
            
            //MR DP Migration:W-009612: Prevent Duplicate Lead/Contact and instead add a task
            leadTriggerHandler.DPRemoveDuplicate(newList);
            
        }
    }
    
    public static void beforeUpdate(List<Lead> newList, Map<Id,Lead> oldMap) {
        if (isDataAdmin == false) {
            //Check for CNPJ and CPF Numbers validity before update
            LeadTriggerHandler.validateCNPJandCPFNumbers(newList);
            leadTriggerHandler.leadCampaignCount(newList);
        }
    }
    
    //After Update call from trigger.
    public static void afterUpdate(Map<Id, Lead> newMap, Map<Id, Lead> oldMap) {
        
        // Don't check for isDataAdmin, so always run.
        
        populateConvertedLeadMaps(newMap, oldMap);
        
        // After this point, convertedOldMap and convertedNewMap will contain the conversions, so we can use this in the next methods
        
        // Conversion methods
        if (!convertedNewMap.isEmpty()) {
            
            // Creating address for converted lead
            LeadTriggerHandler.createAddress(convertedNewMap, convertedOldMap);
            
            // Populate Maketing Activity contact lookup on conversion of lead
            LeadTriggerHandler.populateMarketingActivityOnContact(convertedNewMap, convertedOldMap);
            
            // Populate Marketing Activity address lookup on conversion of lead
            LeadTriggerHandler.populateMarketingActivityOnAccount(convertedNewMap, convertedOldMap);
            
            //Added by Manoj
            LeadTriggerHandler.populateOpportunityContactRole(convertedNewMap, convertedOldMap);
            
            LeadTriggerHandler.existingOpportunityCheck(convertedNewMap, convertedOldMap);
            //LeadTriggerHandler.updateOppApacAcv(convertedNewMap);//Case 22182953
            LeadTriggerHandler.updateContactDecisionMaker(convertedNewMap);//W-033732
        }
    }
    
    //===========================================================================
    // CRM2:W-005436 - Added by Manoj
    // Improved by PK - Added checks for opportunity and also null role
    //=========================================================================== 
    public static void populateOpportunityContactRole(Map<Id, Lead> newMap, Map<Id, Lead> oldMap) {
        
        for (Lead newLead : newMap.values()) {
            
            if (/*newLead.Decision_Maker__c == true &&*/
                newLead.ConvertedOpportunityId != null) {
                    List<OpportunityContactRole> oppContactRoleList = [
                        SELECT Id, Role, OpportunityId, ContactId
                        FROM OpportunityContactRole
                        WHERE OpportunityId = :newLead.ConvertedOpportunityId 
                        AND ContactId = :newLead.ConvertedContactId
                        AND Role = null
                    ];
                    for (OpportunityContactRole ocr : oppContactRoleList) {
                        ocr.Role = Constants.DECIDER;
                    }
                    Database.update(oppContactRoleList);       
                }
        }
        
    }
    //===========================================================================
    // W-033732 - Added by Sai Navya
    // When a lead is converted to an opportunity the contact that's created should become the decision maker against the opportunity
    //=========================================================================== 
    public static void updateContactDecisionMaker(Map<Id, Lead> newMap) {
        
        for (Lead newLead : newMap.values()) {
            
            if (newLead.ConvertedOpportunityId != null) {
                    List<Contact> contactList = [SELECT Id,Decision_Maker__c from Contact Where Id = :newLead.ConvertedContactId];
                    for (Contact con : contactList) {
                        con.Decision_Maker__c = True;
                    }
                    Database.update(contactList);       
                }
        }
        
    }
    
    public static void populateConvertedLeadMaps(Map<Id, Lead> newMap, Map<Id, Lead> oldMap) {
        
        convertedOldMap = new Map<Id,Lead>();
        convertedNewMap = new Map<Id,Lead>();
        for (Lead newLead : newMap.values()) {
            Lead oldLead = oldMap.get(newLead.id);
            system.debug('*** NEW LEAD CONVERTED : '+newLead.Id+' - '+newLead.IsConverted);
            system.debug('*** OLD LEAD CONVERTED : '+oldLead.Id+' - '+oldLead.IsConverted); 
            
            // If lead is converted and have billing address then process further
            if (newLead.IsConverted != oldLead.IsConverted && newLead.IsConverted == true) {
                convertedOldMap.put(oldLead.Id, oldLead);
                convertedNewMap.put(newLead.Id, newLead);
            }
        }
    }
    
    public static void createAddress(Map<Id, Lead> newMap, Map<Id, Lead> oldMap) {
        
        // Uses the populated convertedOldMap and convertedNewMap fields
        Map<Id, Address__c> addressToBeInsert = new Map<Id,Address__c>();
        
        for (Lead newLead : newMap.values()) {
            if (String.isNotBlank(newLead.Street) || 
                String.isNotBlank(newLead.State) || 
                String.isNotBlank(newLead.PostalCode) || 
                String.isNotBlank(newLead.Country) || 
                String.isNotBlank(newLead.City)) {
                    // new address to add...
                    addressToBeInsert.put(newLead.Id, getAddress(newLead));
                }
        }
        if (!addressToBeInsert.isEmpty()) {
            Map<Id,Address__c> origAddress = new Map<Id,Address__c>();
            Map<Id,Address__c> newAddress = new Map<Id,Address__c>();
            for (Id leadId : addressToBeInsert.keySet()) {
                if (addressToBeInsert.get(leadId).Id != null) {
                    origAddress.put(leadId,addressToBeInsert.get(leadId));
                }
                else {
                    newAddress.put(leadId,addressToBeInsert.get(leadId));
                }
            }
            try {
                insert newAddress.values();
            }
            catch (DMLException ex) {
                ApexLogHandler.createLogAndSave('LeadTriggerHandler','createAddress', ex.getStackTraceString(), ex);
                for (Integer i = 0; i < ex.getNumDml(); i++) {
                    Trigger.newMap.values().get(0).addError(Label.Generic_message_for_system_error + ex.getDmlMessage(i)); 
                }
            }
            
            for (Id leadId : addressToBeInsert.keySet()) {
                if (newAddress.containsKey(leadId)) {
                    addressToBeInsert.put(leadId,newAddress.get(leadId));
                }
            }
            createAccountAndContactAddress(addressToBeInsert, newMap);
        }
    }
    
    // Method for create Address object instance with the account fields values
    private static Address__c getAddress(Lead lead) {
        List<String> leadAddr = new List<String>();
        String addr1 = '';
        String addr2 = '';
        String addr3 = '';
        String addr4 = '';
        Integer addrlen;
        String leadAddress = lead.Street;
        addrlen = leadAddress.length();
        leadAddr = leadAddress.split(','); //if we had , after each street1
        Integer leadAddrLen = leadAddr.size(); // mod 08.27 
        if (addrlen > 50 || leadAddrLen > 0 ) { //mod 08.27
            //leadAddr = leadAddress.split(','); //if we had , after each street1
            if (leadAddr.size() > 0) {
                addr1 = leadAddr[0];
                if (addr1.length() > 50) {
                    addr1 = addr1.substring(0,50);
                    if (leadAddress.length()-50 > 0) {
                        addr2 = leadAddress.substring(51,leadAddress.length()); //potential issue here, splitting at 50 chars
                    }
                    if (leadAddress.length() -100 > 0 ) {
                        addr3 = leadAddress.substring(101,leadAddress.length() ); //potential issue here, splitting at 100 chars
                    }
                }
            }
            if (leadAddr.size() > 1) { //if we had comma, after each street1
                addr2 = leadAddr[1];
            }
            if (leadAddr.size() > 2) { //if we had comma, after each street2
                addr3 = leadAddr[2];
            }
            if (leadAddr.size() > 3) { //if we had comma, after each street3
                addr4 = leadAddr[3];
            }
        }
        else {
            addr1 = leadAddress;
        }
        
        Address__c address = new Address__c(
            Address_1__c = addr1,
            Address_2__c = addr2,
            Address_3__c = addr3,
            Address_4__c = addr4,
            City__c = lead.City,
            State__c = lead.State,  // What about county?
            //Zip__c = lead.PostalCode, 
            PostCode__c = lead.PostalCode,
            Country__c = lead.Country, 
            Authenticated_Address__c = false
        );
        address = AddressUtility.checkDuplicateAddress(address);
        return address;
    }
    
    private static void createAccountAndContactAddress(Map<Id, Address__c> mapAddressWithLeadId, Map<Id, Lead> newMap){
        
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> addressIdSet = new Set<Id>();
        
        Map<Id,Set<Id>> accountIdToAddressIds = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> contactIdToAddressIds = new Map<Id,Set<Id>>();
        
        for (Lead l : newMap.values()) {
            // each lead with have an address, check there is not already a registered address before inserting a new one
            accountIdSet.add(l.ConvertedAccountId);
            contactIdSet.add(l.ConvertedContactId);
            addressIdSet.add(mapAddressWithLeadId.get(l.Id).Id);
        }
        
        List<Address__c> checkAddresses = [
            SELECT Id,
            (SELECT Id, Account__c, Address_Type__c, Address__c FROM Account_Address__r WHERE Address_Type__c = :Constants.ADDRESS_TYPE_REGISTERED AND Account__c IN :accountIdSet),
            (SELECT Id, Contact__c, Address_Type__c, Address__c FROM Contact_Addresses__r WHERE Address_Type__c = :Constants.ADDRESS_TYPE_REGISTERED AND Contact__c IN :contactIdSet)
            FROM Address__c
            WHERE Id IN :addressIdSet
        ];
        
        for (Address__c addr : checkAddresses) {
            // now, for each address, and if there is a match for the accounts, or contact, don't add a new 'Registered' address
            for (Account_Address__c accAddr : addr.Account_Address__r) {
                accountIdSet.remove(accAddr.Account__c);
                if (!accountIdToAddressIds.containsKey(accAddr.Account__c)) {
                    accountIdToAddressIds.put(accAddr.Account__c, new Set<Id>{});
                }
                accountIdToAddressIds.get(accAddr.Account__c).add(accAddr.Address__c);
            }
            for (Contact_Address__c conAddr : addr.Contact_Addresses__r) {
                contactIdSet.remove(conAddr.Contact__c);
                if (!contactIdToAddressIds.containsKey(conAddr.Contact__c)) {
                    contactIdToAddressIds.put(conAddr.Contact__c, new Set<Id>{});
                }
                contactIdToAddressIds.get(conAddr.Contact__c).add(conAddr.Address__c);
            }
        }
        
        List<Account_Address__c> accountAddressToBeInsert = new List<Account_Address__c>();
        List<Contact_Address__c> contactAddressToBeInsert = new List<Contact_Address__c>();
        
        for (Id leadId : mapAddressWithLeadId.keySet()){
            // Geting address for the assoicated lead
            Address__c address = mapAddressWithLeadId.get(leadId);
            // Geting lead
            Lead nLead = newMap.get(leadId);
            
            if (accountIdToAddressIds.containsKey(nLead.ConvertedAccountId) && 
                accountIdToAddressIds.get(nLead.ConvertedAccountId).contains(address.Id)) {
                    // do nothing as it already exists
                }
            else {
                // Creating AccountAddress instance
                Account_Address__c accountAddress = new Account_Address__c(
                    Account__c = nLead.ConvertedAccountId,
                    Address__c = address.id,
                    Address_Type__c = Constants.ADDRESS_TYPE_REGISTERED
                );
                // Depending on if the accountIdSet still has the id for this account, set as registered, otherwise secondary
                if (!accountIdSet.contains(nLead.ConvertedAccountId)) {
                    accountAddress.Address_Type__c = Constants.ADDRESS_TYPE_SECONDARY;
                }
                accountAddressToBeInsert.add(accountAddress);
            }
            if (contactIdToAddressIds.containsKey(nLead.ConvertedContactId) && 
                contactIdToAddressIds.get(nLead.ConvertedContactId).contains(address.Id)) {
                    // nothing
                }
            else {
                // Creating ContactAddress instance
                Contact_Address__c contactAddress = new Contact_Address__c(
                    Contact__c = nLead.ConvertedContactId,
                    Address__c = address.id,
                    Address_Type__c = Constants.ADDRESS_TYPE_REGISTERED
                );
                // Depending on if the contactIdSet still has the id for this contact, set as registered, otherwise secondary
                if (!contactIdSet.contains(nLead.ConvertedContactId)) {
                    contactAddress.Address_Type__c = Constants.ADDRESS_TYPE_SECONDARY;
                }
                contactAddressToBeInsert.add(contactAddress);
            }
        }
        
        // Inserting list of AccountAddress
        insert accountAddressToBeInsert;
        // Inserting list of ContactAddress
        insert contactAddressToBeInsert;
    }
    
    //Populate Maketing Activity contact lookup on conversion of lead
    public static void populateMarketingActivityOnContact(Map<Id, Lead> newMap, Map<Id, Lead> oldMap){
        
        // Populate Contact field on Marketing activity on Contact
        List<ELQA_Marketing_Activity__c> lstMarketingActivity = new List<ELQA_Marketing_Activity__c>();
        
        for (Lead nLead : [SELECT ConvertedContactId,
                           (SELECT Id FROM R00N30000001wa2CEAQ__r) 
                           FROM Lead 
                           WHERE Id IN :newMap.keySet()]) {
                               for (ELQA_Marketing_Activity__c marketingActivity : nLead.R00N30000001wa2CEAQ__r) {
                                   lstMarketingActivity.add(
                                       new ELQA_Marketing_Activity__c(
                                           Id = marketingActivity.Id , 
                                           Contact__c = nLead.ConvertedContactId
                                       )
                                   );
                               }
                           }
        update lstMarketingActivity;
    }
    
    //Populate Maketing Activity account lookup on conversion of lead
    public static void populateMarketingActivityOnAccount(Map<Id, Lead> newMap, Map<Id, Lead> oldMap) {
        
        // Populate Account field on Marketing activity on Account
        List<ELQA_Marketing_Activity__c> lstMarketingActivity = new List<ELQA_Marketing_Activity__c>();
        
        for (Lead nLead : [SELECT ConvertedAccountId,
                           (SELECT Id FROM R00N30000001wa2CEAQ__r)
                           FROM Lead
                           WHERE Id IN :newMap.keySet()]) {
                               for (ELQA_Marketing_Activity__c marketingActivity : nLead.R00N30000001wa2CEAQ__r) {
                                   lstMarketingActivity.add(
                                       new ELQA_Marketing_Activity__c(
                                           Id = marketingActivity.Id, 
                                           Account__c = nLead.ConvertedAccountId
                                       )
                                   );
                               }
                           }
        update lstMarketingActivity;
    }
    
    public static void validateCNPJandCPFNumbers(List<Lead> newList) {
        for (Lead ld : newList) {
            if (String.isNotBlank(ld.CNPJ_Number__c)) {
                if ((!ld.CNPJ_Number__c.isNumeric() || ld.CNPJ_Number__c.length() != 14)) {
                    ld.addError(Label.Invalid_CNPJ_Number_Format);
                }
                else if (!SerasaUtilities.validateCNPJNumber(ld.CNPJ_Number__c)) {
                    ld.addError(Label.Invalid_CNPJ_Checksum_Error_Message);
                }
            }
            if (String.isNotBlank(ld.CPF__c)) {
                if ((!ld.CPF__c.isNumeric() || ld.CPF__c.length()!= 11)) {
                    ld.addError(Label.Invalid_CPF_Number);
                }
                else if (!SerasaUtilities.validateCPFNumber(ld.CPF__c)) {
                    ld.addError(Label.Invalid_CPF_Checksum_Error_Message);
                }
            }
        }
    }
    //MR DP Migration:W-009612: Prevent Duplicate Lead/Contact and instead add a task
    public static void DPLeadcheck(List<Lead> newList) {
        Set<String> fname = new set<string>();
        set<string> lname = new set<string>();
        set<string> email = new set<string>();
        list<task> newTasks = new List<task>();
        
        system.debug('In DPLeadcheck:::'); 
        
        for (Lead ld : newList) {
            if(ld.LeadSource=='Web Site' && (String.isNotBlank(ld.Description) && (ld.Description.containsIgnoreCase('https://www.questnet.sg') || ld.Description.containsIgnoreCase('https://www.experian-ibr360.com') ))){
                fname.add(ld.firstname);
                lname.add(ld.lastname);
                email.add(ld.email);
                system.debug('In DPLeadcheck2::::'); 
            }
        }
        
        if(fname.size() > 0 || lname.size() > 0 || email.size() > 0){
            
            List<contact> contactLst = [select id,ownerid,firstname,lastname,email from contact where firstname in : fname and Lastname in:lname and email in :email];
            list<lead> leadLst= [select id,ownerid,firstname,lastname,email from lead where firstname in : fname and Lastname in:lname and email in :email];
            
            ID MarkActRTId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(Constants.RECORDTYPE_MARKETING_TASK).getRecordTypeId();
            
            system.debug('contactLst::::'+contactLst); 
            system.debug('leadLst::::'+leadLst); 
            
            if(contactLst.size() > 0 || leadLst.size() > 0){
                
                for(lead l : newList){
                    if(contactLst.size() > 0){         
                        for(contact c : contactLst){
                            if(c.firstname==l.firstname && c.lastname==l.lastname && c.email==l.email){
                                Task newTask = new Task(
                                    OwnerID = c.OwnerID,
                                    WhoID = c.id,
                                    Status = 'Not Started',
                                    Priority = 'Normal',
                                    IsReminderSet = TRUE
                                    
                                );
                                newTask.ReminderDateTime = system.now().adddays(1);
                                newTask.Subject = 'Website Enquiry';
                                newTask.Source__c = 'Web Site';
                                newTask.ActivityDate = system.today().adddays(1);
                                newTask.Description = l.description;
                                newTask.RecordTypeID=MarkActRTId;
                                newTasks.add(newTask);
                                
                                l.description='DP Duplicate Lead - Remove';
                            }            
                        }         
                    }
                    if(leadLst.size() > 0){         
                        for(lead dl : leadLst){
                            if(dl.firstname==l.firstname && dl.lastname==l.lastname && dl.email==l.email){
                                
                                Task newTask = new Task(
                                    OwnerID = dl.OwnerID,
                                    WhoID = dl.id,
                                    Status = 'Not Started',
                                    Priority = 'Normal',
                                    IsReminderSet = TRUE
                                    
                                );
                                newTask.ReminderDateTime = system.now().adddays(1);
                                newTask.Subject = 'Website Enquiry';
                                newTask.Source__c = 'Web Site';
                                newTask.ActivityDate = system.today().adddays(1);
                                newTask.Description = l.description;
                                newTask.RecordTypeID=MarkActRTId;
                                newTasks.add(newTask);
                                
                                
                                l.description='DP Duplicate Lead - Remove';
                            }            
                        }         
                    }
                    
                }
                
                
                
                insert newTasks;    
                
            }
        } 
    }
    
    
    public static void DPRemoveDuplicate(List<Lead> newList) {
        
        set<id> dupset = new set<id>();
        
        for(lead l : newlist){
            if(l.description=='DP Duplicate Lead - Remove'){
                dupset.add(l.id);
            }
        }
        
        if(dupset.size() > 0){
            DPRemoveDuplicateFuture(dupset);
        }
    }
    
    @future
    public static void DPRemoveDuplicateFuture(set<id> dupset) {
        
        List<lead> duplst = [select id from lead where id in : dupset];
        
        delete duplst;
        
    }
    
    private static void leadCampaignCount(List<Lead> newList){
        
        set<id> leadIds = new set<id>();
        Map<Id,Integer> leadCampCount = new Map<Id,Integer>();
        
        
        for (Lead nl: newList) {
            
            leadIds.add(nl.Id);
            
        }
        
        for(lead l : [select id, campaign_count__c, (select id from campaignMembers) from lead where id in : leadIds]){
            Integer campCount=0;
            if(l.campaignMembers !=null){
                campCount = l.campaignMembers.size();
                
            }
            leadCampCount.put(l.id,campCount);
            
        }
        
        for (Lead l: newList) {
            if(leadCampCount.containskey(l.id)){
                if(l.campaign_count__c != leadCampCount.get(l.id) ){
                    l.campaign_count__c = leadCampCount.get(l.id); 
                }                       
            } 
            
        }    
        
    }
    
    public static void existingOpportunityCheck (Map<Id, Lead> newMap, Map<Id, Lead> oldMap) { 
        for (Lead newLead : newMap.values()) { 
            if (newLead.ConvertedOpportunityId != null) { 
                for( opportunity opp : [select id, createddate from Opportunity where id = :newLead.ConvertedOpportunityId]){
                    Long current = DateTime.now().getTime();
                    Long oppCreate = opp.createddate.getTime();
                    Long milliseconds = current - oppCreate;
                    
                    if(milliseconds > 20000){
                        newlead.addError('Please create a new Opportunity or select Dont Create an Opportunity');
                    }
                    
                }
                
            }
        }
        
    }
    //Case 22182953: Created new method updateOppApacAcv to update APAC ACV field in opportunity when a lead is converted
    /*public static void updateOppApacAcv(Map<Id, Lead> newMap) { 
        List<Opportunity> updateAPACOppList = new List<Opportunity>();
        for (Lead newLead : newMap.values()) { 
            if (newLead.ConvertedOpportunityId != null) { 
                for( opportunity opp : [Select id,Annual_Contract_Value__c,
                                        (SELECT Id,APAC_ACV__c
                                         FROM OpportunityLineItems)  from Opportunity where Id =:newLead.ConvertedOpportunityId]){
                                             updateAPACOppList.add(opp);
                                         }
            }
        }
        List<Opportunity> updateOppList = new List<Opportunity>(); 
        for (Opportunity opp : updateAPACOppList) {
            if(opp.OpportunityLineItems.size()==0) 
                opp.APAC_ACV__c = opp.Annual_Contract_Value__c;
            updateOppList.add(opp); 
        }
        if(updateOppList.size()>0)
            update updateOppList; 
    } */ 
}