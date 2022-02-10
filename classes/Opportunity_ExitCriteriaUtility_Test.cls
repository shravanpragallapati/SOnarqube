/**=====================================================================
* Appirio, Inc
* Test Class Name: Opportunity_ExitCriteriaUtility_Test
* Class Name: [Class name for which test class created]
* Description: [Task # with multi-line description here]
* Created Date: [MM/DD/YYYY]
* Created By: [FirstName LastName] (Appirio)
*
* Date Modified                Modified By                  Description of the update
* Apr 30, 2014                 Nathalie Le Guay             Use of Constants
* Aug 01st, 2014               Arpita Bose                  T-286015: Phase 2 Sprint 0 refactoring: Fix test class requiring a specific user currency
* Aug 18th, 2014               Arpita Bose                  T-312319: Updated method testOpportunitiesExitCriteriaNotMet()to fix the failure
* Nov 12th, 2014               Arpita Bose                  Added Type in test data of Opportunity and OLI
* Sept 09, 2015                Naresh kr Ojha               Added test methods to test functionality. testOpportunitiesExitCriteriaNotMet2(), getOpptyDetails()
* Apr 5, 2016                  Paul Kissick                 Case 01028611: Adding checks to stage 4
* Jul 21st 2016(QA)            Manoj Gopu                   Added a new method testOpportunitiesReqTask();
* Aug 5th, 2016                Manoj Gopu                   CRM2:W-005438 Updated method to testOpportunitiesExitCriteriaNotMet2() to fix the failure
* Aug 9th, 2016                Paul Kissick                 CRM2:W-005495: Removing fields no longer used & fixed test
* Sep 2nd, 2016                Paul Kissick                 CRM2:W-005653: Test fix
* Oct 20th, 2016               James Wills                  Case #02088090 - Resolved issue with test following validation rule change
* Nov 16th, 2016               Diego Olarte                 Case 02144295: Added CPQ_User_Type__c = 'BIS Manager' and 'CSDA AE Manager' for Exit Criteria 6 and CPQ_User_to_Validate2__c and CPQ_User_to_Validate3__c for the fields to validate
* Dec 05th, 2016               Manoj Gopu                   Case 02215771: calling uncovered methods to Improve the Test coverage.
* Apr 25th, 2017               Sanket Vaidya                Case 02150014: CRM 2.0- Opportunity Competitor Information [Added Is_competitor__c flag to true for account]
* Oct 27th, 2017               Diego Olarte                 Case 13543302: Disabled Stage 3 Approver for UK&I opps over 500000 as no longer needed
* Feb 20th, 2018               Malcolm Russell              Added testTechSuppFieldRequired to take test coverage to 75%
* Feb 21st, 2018               Malcolm Russell              DP Migration : extended code coverage
* Jan  7th, 2020               Mauricio Murillo             Case 19457481: Removed COMMIT stage from logic
* Mar 11th, 2021               Sai Navya Yerrabelli         W-030686 Added method to check the Customer profile is NA Customer
* Mar 16th, 2021                Rohit Aryan                  W-031814 : Deal Category for NA Auto user, added testOpportunities_DealManditory2 code coverage
=====================================================================*/
@isTest
private class Opportunity_ExitCriteriaUtility_Test {
    
    
    //private static Opportunity opp;
    //private static List<OpportunityLineItem> olis;
    //private static PricebookEntry stdPricebookEntryObj;
    
    static testMethod void test1ExitCriteriaNotMetStage3(){
        //Creating admin user
        User testUser = Test_Utils.createUser(Constants.PROFILE_SYS_ADMIN);
        insert testUser;
        system.runAs(testUser) {
            // Create test data
            Test.startTest();
            // Create Account
            Account testAccount = Test_Utils.insertAccount();
            testAccount.Is_Competitor__c = true;
            update testAccount;
            
            // Create an opportunity
            Opportunity sObjOpp = Test_utils.createOpportunity(testAccount.Id);
            insert sObjOpp;
            
            sObjOpp.StageName = Constants.OPPTY_STAGE_6;
            try {
                update sObjOpp;
            }
            catch (Exception ex) {
                system.assert(ex.getMessage().contains(System.Label.OECS_MSG_SKIPSTAGE));
            }
            
            User opptyOwner = Test_Utils.createUser(Constants.PROFILE_SYS_ADMIN);
            opptyOwner.Region__c = Constants.REGION_UKI;
            insert opptyOwner;
            
            //Test_Utils.createOpptyTasks(sObjOpp.Id, true);
            Contact newcontact  = new Contact (
                FirstName = 'Larry',
                LastName = 'Ellison',
                AccountId = testAccount.Id,
                Email = 'larrye@email.com'
            );
            insert newcontact;
            //       Task newTask = new Task(WhatId = sObjOpp.Id,whoId = newcontact.Id,Outcomes__c=Constants.ACTIVITY_TYPE_SELECTION_CONFIRMED, Status = Constants.STATUS_COMPLETED);
            //  insert newTask;
            
            OpportunityContactRole oppContactRole = new OpportunityContactRole(
                ContactId = newcontact.Id,
                OpportunityId = sObjOpp.Id,
                IsPrimary = true,
                Role = Constants.DECIDER
            );
            
            insert oppContactRole;
            
            Competitor__c comp = Test_Utils.createCompetitor(sObjOpp.Id);
            insert comp;
            
            sObjOpp.Budget__c = 'Client will not disclose';
            sObjOpp.OwnerId = opptyOwner.ID;
            sObjOpp.Amount = 600000;
            sObjOpp.StageName = Constants.OPPTY_STAGE_4;
            
            try {
                update sObjOpp;
            }
            catch (Exception ex) {
                system.assert(ex.getMessage().contains(System.Label.OECS_MSG_POPULATE_STAGE_3_APPROVER));
            }
            
            sObjOpp.Stage_3_Approver__c = UserInfo.getUserId();
            try {
                update sObjOpp;
            }
            catch (Exception ex) {
                system.assert(ex.getMessage().contains(System.Label.OECS_MSG_STAGE_3_TO_4_AMOUNTORTAA_OVER_APPROVAL));
            }
            
            sObjOpp.Has_Stage_3_Approval__c = true;
            sObjOpp.StageName = Constants.OPPTY_STAGE_4;
            update sObjOpp;
            
            system.assertEquals(Constants.OPPTY_STAGE_4, [SELECT ID, StageName FROM Opportunity WHERE ID = :sObjOpp.ID].StageName);
        }
    }
    
    static testMethod void testExitCriteriaNotMetStage4(){
        Decimal adjustedRate = 0.00;
        //Creating admin user
        User testUser = Test_Utils.createUser(Constants.PROFILE_SYS_ADMIN);
        insert testUser;
        system.runAs(testUser) {
            
            // Create test data
            Test.startTest();
            
            MAP<String,Id> oppRecTypeMap = new MAP<String,Id>();
            for (RecordType rt : [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Opportunity']) {
            oppRecTypeMap.put(rt.Name, rt.Id); }
            // Create Account
            Account testAccount = Test_Utils.insertAccount();
            testAccount.Is_Competitor__c = true;
            update testAccount;
            
            // Create an opportunity
            Opportunity sObjOpp = Test_utils.createOpportunity(testAccount.Id);
            sObjOpp.RecordTypeId = oppRecTypeMap.get('Standard');
            insert sObjOpp;
            
            User opptyOwner = Test_Utils.createUser(Constants.PROFILE_SYS_ADMIN);
            opptyOwner.Global_Business_Line__c = 'Credit Services';
            opptyOwner.Business_Line__c = 'UK&I Credit Services';
            opptyOwner.business_unit__c = 'UK&I GTM FS';
            opptyOwner.Region__c = Constants.REGION_UKI;
            insert opptyOwner;
            
            // Test_Utils.createOpptyTasks(sObjOpp.Id, true);
            Contact newcontact  = new Contact (
                FirstName = 'Larry',
                LastName = 'Ellison',
                AccountId = testAccount.Id,
                Email = 'larrye@email.com'
            );
            insert newcontact;
            //    Task newTask = new Task(WhatId = sObjOpp.Id,whoId = newcontact.Id,Outcomes__c=Constants.ACTIVITY_TYPE_SELECTION_CONFIRMED, Status = Constants.STATUS_COMPLETED);
            //insert newTask;
            
            OpportunityContactRole oppContactRole = new OpportunityContactRole(
                ContactId = newcontact.Id,
                OpportunityId = sObjOpp.Id,
                IsPrimary = true,
                Role = Constants.DECIDER
            );
            insert oppContactRole ;
            
            Competitor__c comp = Test_Utils.createCompetitor(sObjOpp.Id);
            insert comp;
            
            sObjOpp.Budget__c = 'Client will not disclose';
            sObjOpp.Amount = 10000;
            sObjOpp.StageName = Constants.OPPTY_STAGE_4;
            sObjOpp.OwnerId = opptyOwner.ID;
            update sObjOpp;
            
            try {
                sObjOpp.StageName = Constants.OPPTY_STAGE_6;
                sObjOpp.Amount = 600000;
                update sObjOpp;
            }
            catch(Exception ex) {
                system.assert(ex.getMessage().contains(System.Label.OECS_MSG_POPULATE_SENIOR_APPROVER));
            }
            
            sObjOpp.Senior_Approver__c = UserInfo.getUserId();
            sObjOpp.Business_Unit__c = 'UK&I GTM';
            try {
                update sObjOpp;
            }
            catch (Exception ex) {
                system.assert(ex.getMessage().contains(System.Label.OECS_MSG_STAGE_4_TO_5_AMOUNTORTAA_OVER_APPROVAL));
            }
            
            try {
                OpportunityTriggerHandler.hasCheckedExitCriteria = false;
                sObjOpp.OwnerId = opptyOwner.ID;
                sObjOpp.Risk_Tool_Output__c = null;
                sObjOpp.StageName = Constants.OPPTY_STAGE_6;
                update sObjOpp;
            }
            catch (Exception ex) {
                system.assert(ex.getMessage().contains(System.Label.OECS_MSG_RISK_TOOL_OUTPUT_MISSING));
            }
            Opportunity_ExitCriteriaUtility.isMeetingExitCriteria(sObjOpp,Constants.OPPTY_STAGE_6,Constants.OPPTY_STAGE_4,sObjOpp);
            Test.stopTest();
        }
    }
    
    @isTest
    static void testExitCriteriaNotMetStage5(){
        //Creating admin user
        User testUser = Test_Utils.createUser(Constants.PROFILE_SYS_ADMIN);
        insert testUser;
        system.runAs(testUser) {
            
            // Create test data
            
            // Create Account
            Account testAccount = Test_Utils.insertAccount();
            
            // Create an opportunity
            Opportunity sObjOpp = Test_utils.createOpportunity(testAccount.Id);
            sObjOpp.Starting_Stage__c = Constants.OPPTY_STAGE_6;
            insert sObjOpp;
            
            User opptyOwner = Test_Utils.createUser(Constants.PROFILE_SYS_ADMIN);
            opptyOwner.Region__c = Constants.REGION_UKI;
            opptyOwner.CPQ_User_Type__c = 'BIS Manager';
            
            User opptyOwner2 = Test_Utils.createUser(Constants.PROFILE_SYS_ADMIN);
            opptyOwner2.Region__c = Constants.REGION_UKI;
            opptyOwner2.CPQ_User_Type__c = 'CSDA AE Manager';
            
            insert new List<User>{opptyOwner,opptyOwner2};
                
                //  Test_Utils.createOpptyTasks(sObjOpp.Id, true);
                Contact newcontact  = new Contact(
                    FirstName = 'Larry',
                    LastName = 'Ellison',
                    AccountId = testAccount.Id,
                    Email = 'larrye@email.com'
                );
            insert newcontact;
            //   Task newTask = new Task(WhatId = sObjOpp.Id,whoId = newcontact.Id,Outcomes__c=Constants.ACTIVITY_TYPE_SELECTION_CONFIRMED, Status = Constants.STATUS_COMPLETED);
            // insert newTask;
            
            OpportunityContactRole oppContactRole = new OpportunityContactRole(
                ContactId = newcontact.Id,
                OpportunityId = sObjOpp.Id,
                IsPrimary = true,
                Role = Constants.DECIDER
            );
            insert oppContactRole ;
            
            //Competitor__c comp = new Competitor__c(Opportunity__c = sObjOpp.Id);
            //insert comp;
            
            sObjOpp.Budget__c = 'Client will not disclose';
            sObjOpp.Amount = 10000;
            sObjOpp.StageName = Constants.OPPTY_STAGE_4;
            update sObjOpp;
            
            //Task t = Test_Utils.createTask(newContact.Id, sObjOpp.Id);
            //t.Type = Constants.ACTIVITY_TYPE_QUOTE_DELIVERED;
            //t.Status = Constants.STATUS_COMPLETED;
            //insert t;
            //Product2 product = Test_Utils.insertProduct();
            //Pricebook2 pricebook = Test_Utils.getPriceBook2();
            //Pricebook2 standardPricebook = Test_Utils.getPriceBook2(Constants.STANDARD_PRICE_BOOK);
            //stdPricebookEntryObj = Test_Utils.insertPricebookEntry(product.Id, standardPricebook.Id, Constants.CURRENCY_USD);
            ////insert OLI
            //olis = new List<OpportunityLineItem>();
            //olis.add(Test_Utils.createOpportunityLineItem(sObjOpp.Id, stdPricebookEntryObj.Id));
            //olis.add(Test_Utils.createOpportunityLineItem(sObjOpp.Id, stdPricebookEntryObj.Id));
            
            Test.startTest();
            sObjOpp.StageName = Constants.OPPTY_STAGE_6;
            update sObjOpp;
            
            sObjOpp.StageName = Constants.OPPTY_STAGE_6;
            sObjOpp.Amount = 600000;
            //Assert to check senior approver to be filled as amount is > 500000
            try {
                update sObjOpp;
            }
            catch (Exception ex) {
                system.assert(ex.getMessage().contains(System.Label.OECS_MSG_POPULATE_SENIOR_APPROVER));
            }
            
            sObjOpp.Senior_Approver__c = UserInfo.getUserId();
            
            //Assert to check approval to be taken as amount is > 500000
            try {
                update sObjOpp;
            }
            catch (Exception ex) {
                system.assert(ex.getMessage().contains(System.Label.OECS_MSG_STAGE_5_TO_6_OPPTY_APPROVAL));
            }
            
            //Owner has region UKI, so all risk fields has to be populated.
            try {
                sObjOpp.OwnerId = opptyOwner.ID;
                sObjOpp.StageName = Constants.OPPTY_STAGE_6;
                sObjOpp.Stage_3_Approver__c = UserInfo.getUserId();
                sObjOpp.Has_Stage_3_Approval__c = true;
                sObjOpp.Has_Senior_Approval__c = true;
                update sObjOpp;
            }
            catch (Exception ex) {
                system.assert(ex.getMessage().contains(System.Label.OECS_MSG_POPULATE_RISK_FIELDS));
            }
            
            //Test non BIS primary quote requirement
            try {
                sObjOpp.OwnerId = opptyOwner2.ID;
                sObjOpp.StageName = Constants.OPPTY_STAGE_6;
                sObjOpp.Stage_3_Approver__c = UserInfo.getUserId();
                sObjOpp.Has_Stage_3_Approval__c = true;
                sObjOpp.Has_Senior_Approval__c = true;
                update sObjOpp;
            }
            catch (Exception ex) {
                system.assert(ex.getMessage().contains(System.Label.OECS_MSG_POPULATE_RISK_FIELDS));
            }
            
            //Everything is well so Oppty should be in Stage 6
            sObjOpp.OwnerId = UserInfo.getUserId();
            sObjOpp.Has_Senior_Approval__c = true;
            update sObjOpp;
            
            //Check significant change to be populated.
            try {
                sObjOpp.StageName = Constants.OPPTY_STAGE_6;
                update sObjOpp;
            }
            catch (Exception ex) {
                system.assert(ex.getMessage().contains(System.Label.OECS_MSG_POPULATE_SIGNIFICANT_CHANGE));
            }
            //Check If significant change is populated than should have Senior Approver.
            //sObjOpp.Has_There_Been_Significant_Change__c = 'Yes';
            sObjOpp.Senior_Approver__c = null;
            try {
                sObjOpp.StageName = Constants.OPPTY_STAGE_6;
                update sObjOpp;
            }
            catch (Exception ex) {
                system.assert(ex.getMessage().contains(System.Label.OECS_MSG_POPULATE_SENIOR_APPROVER));
            }
            
            //Check If significant change & Senior Approver is populated than should have senior approval true.
            //sObjOpp.Has_There_Been_Significant_Change__c = 'Yes';
            sObjOpp.Senior_Approver__c = UserInfo.getUserId();
            try {
                sObjOpp.StageName = Constants.OPPTY_STAGE_6;
                update sObjOpp;
            }
            catch (Exception ex) {
                system.assert(ex.getMessage().contains(System.Label.OECS_MSG_STAGE_6_TO_7_OPPTY_APPROVAL));
            }
            Test.stopTest();
        }
    }
    
    //test methods to check the functionality of Opportunity_ExitCriteriaUtility.cls
    // @isTest (seealldata=true)
    static testMethod void testOpportunitiesExitCriteriaNotMet(){
        // create User
        Profile p = [SELECT Id FROM Profile WHERE Name = :Constants.PROFILE_SYS_ADMIN];
        User testUser1 = Test_Utils.createUser(p, 'test1234@experian.com', 'test1');
        insert testUser1;
        
        system.runAs(testUser1) {
            User user1= Test_Utils.createUser(Constants.PROFILE_SYS_ADMIN);
            insert user1;
            
            Account testAccount = Test_Utils.insertAccount();
            testAccount.Is_Competitor__c = true;
            update testAccount;
            // Create an opportunity
            Opportunity testOpp = Test_Utils.createOpportunity(testAccount.Id);
            testOpp.Has_Senior_Approval__c = true;
            testOpp.StageName = Constants.OPPTY_STAGE_3;
            //testOpp.Below_Review_Thresholds__c = 'Yes';  T-271695: Removed reference to Below_Review_Thresholds__c field
            testOpp.Starting_Stage__c = Constants.OPPTY_STAGE_3;
            testOpp.Type = Constants.OPPTY_TYPE_RENEWAL;
            insert testOpp;
            
            Test_Utils.insertCompetitor(testOpp.Id);
            Contact contact = new Contact(FirstName = 'Test-Contact', LastName = 'J');
            insert contact;
            
            //  Test_Utils.createOpptyTasks(testOpp.Id, true);
            
            OpportunityContactRole OppRole = new OpportunityContactRole(
                OpportunityId = testOpp.Id,
                ContactId = contact.Id,
                Role = Constants.DECIDER,
                IsPrimary = true
            );
            insert OppRole;
            
            //create opportunity line item
            Product2 product = Test_Utils.insertProduct();
            product.RevenueScheduleType = Constants.REVENUE_SCHEDULED_TYPE_REPEAT;
            product.RevenueInstallmentPeriod = Constants.INSTALLMENT_PERIOD_DAILY;
            product.NumberOfRevenueInstallments = 2;
            //product.CanUseQuantitySchedule = false;
            product.CanUseRevenueSchedule = true;
            update product;
            
            PricebookEntry stdPricebookEntryObj = Test_Utils.insertPricebookEntry(product.Id, Test.getStandardPricebookId(), Constants.CURRENCY_USD);
            //insert OLI
            List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
            olis.add(Test_Utils.createOpportunityLineItem(testOpp.Id, stdPricebookEntryObj.Id, testOpp.Type));
            olis.add(Test_Utils.createOpportunityLineItem(testOpp.Id, stdPricebookEntryObj.Id, testOpp.Type));
            
            olis[0].Type__c = Constants.OPPTY_LINE_ITEM_TYPE_RENEWAL;//Case #02088090
            
            for (OpportunityLineItem oli : olis){
                oli.Start_Date__c = System.today().addDays(-5);
                oli.End_Date__c = System.today();
            }
            insert olis;
            
            Test.startTest();
            
            Opportunity newtestOpp = [
                SELECT Id, Has_Senior_Approval__c, StageName,  Starting_Stage__c, Competitor_Count__c,
                Turn_Off_Contact_Role_Criteria_Check__c
                FROM Opportunity
                WHERE Id = :testOpp.Id
            ];
            
            // Test_Utils.createOpptyTasks(newtestOpp.Id, true);
            newtestOpp.StageName = Constants.OPPTY_STAGE_4;
            newtestOpp.Turn_Off_Contact_Role_Criteria_Check__c = false;
            newtestOpp.Senior_Approver__c = user1.Id;
            //newtestOpp.Has_Completed_Task__c = false;
            try {
                update newtestOpp;
            }
            catch(Exception ex) {
                system.assert(ex.getMessage().contains(System.Label.Opp_Stage_3_Stage_Exit_Failure));
            }
            
            Opportunity test4stage = [
                SELECT Id, Has_Stage_3_Approval__c, Has_Senior_Approval__c, StageName, Starting_Stage__c
                FROM Opportunity
                WHERE Id = :testOpp.Id
            ];
            
            test4stage.Has_Stage_3_Approval__c = false;
            test4stage.StageName = Constants.OPPTY_STAGE_6;
            test4stage.Senior_Approver__c = user1.Id;
            update test4stage;
            
            Opportunity test5stage = [
                SELECT Id, Senior_Approver__c, Has_Senior_Approval__c, StageName, Starting_Stage__c, Amount
                //Has_There_Been_Significant_Change__c,
                FROM Opportunity
                WHERE Id = :testOpp.Id
            ];
            test5stage.Senior_Approver__c = user1.Id;
            test5stage.Has_Senior_Approval__c = true;
            //test5stage.Has_There_Been_Significant_Change__c = 'No';
            test5stage.Amount = 600000;
            update test5stage;
            
            test5stage.StageName = Constants.OPPTY_STAGE_6;
            update test5Stage;
            
            Test.stopTest();
        }
    }
    
    //test methods to check the functionality of Opportunity_ExitCriteriaUtility.cls
    // @isTest (seealldata=true)
    static testMethod void testOpportunitiesExitCriteriaNotMet2() {
        // create User
        
        Profile p = [SELECT Id FROM Profile WHERE Name = :Constants.PROFILE_SYS_ADMIN];
        Map<String, Id> mapstr1 = Opportunity_ExitCriteriaUtility.oppRecordTypeMap;
        MAP<String,Id> oppRecTypeMap = new MAP<String,Id>();
        for (RecordType rt : [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Opportunity']) {
            oppRecTypeMap.put(rt.Name, rt.Id); }
            
        User testUser1 = Test_Utils.createUser(p, 'test1234@experian.com', 'test1');
        testUser1.Region__c = Constants.REGION_UKI;
        testUser1.business_unit__c = Constants.BUSINESS_UNIT_UKI_GTM;
        insert testUser1;
        
        system.runAs(testUser1) {
            
            Account testAccount = Test_Utils.insertAccount();
            testAccount.Is_Competitor__c = true;
            update testAccount;
            //Opportunity parentOppty = Test_utils.insertOpportunity(testAccount.ID);
            // Create an opportunity
            Opportunity testOpp = Test_Utils.createOpportunity(testAccount.Id);
            testOpp.Has_Senior_Approval__c = true;
            testOpp.StageName = Constants.OPPTY_STAGE_3;
            testOpp.Starting_Stage__c = Constants.OPPTY_STAGE_3;
            testOpp.Type = Constants.OPPTY_TYPE_RENEWAL;
            testOpp.RecordTypeId = oppRecTypeMap.get('Standard');
            //testOpp.Previous_Opportunity__c = parentOppty.ID;
            insert testOpp;
            
            Opportunity testOpp2 = getOpptyDetail(testOpp.ID);
            
            //OpportunityTriggerHandler.hasCheckedExitCriteria = false;
            testOpp2.Amount = 500001;
            testOpp2.Risk_Tool_Output__c = null;
            testOpp2.ownerId = testUser1.Id;
            testOpp2.StageName = Constants.OPPTY_STAGE_4;
            testOpp2.Business_Unit__c = 'UK&I GTM';
            
            OpportunityTriggerHandler.groupName = 'REGION_UKI';
            update testOpp2;
            
            
            
            Boolean testAssert = Opportunity_ExitCriteriaUtility.isMeetingExitCriteria(testOpp, Constants.OPPTY_STAGE_4, Constants.OPPTY_STAGE_3,testOpp2);
            //DO Case 13543302: Disabled as no loner needed to validate
            //system.assertEquals(false, testAssert);
            
            //Test_Utils.insertCompetitor(testOpp.Id);
            Contact contact = new Contact(FirstName = 'Test-Contact', LastName = 'J');
            insert contact;
            
            // Test_Utils.createOpptyTasks(testOpp.Id, true);
            
            OpportunityContactRole OppRole = new OpportunityContactRole(
                OpportunityId = testOpp.Id,
                ContactId = contact.Id,
                Role = Constants.DECIDER,
                IsPrimary = true
            );
            insert OppRole;
            
            Opportunity testOpp3 = getOpptyDetail(testOpp2.ID);
            Test.startTest();
            OpportunityTriggerHandler.hasCheckedExitCriteria = false;
            testOpp3.Amount = 600001;
            testOpp3.Risk_Tool_Output__c = null;
            testOpp3.Selection_confirmed_date__c = System.today().addDays(10);
            testOpp3.Quote_delivered_date__c = System.today().addDays(10);
            testOpp3.RecordTypeId = oppRecTypeMap.get('Standard');
            testOpp3.StageName = Constants.OPPTY_STAGE_6;
            
            OpportunityTriggerHandler.groupName = 'REGION_UKI';
            update testOpp3;
            
            
            
            testAssert = Opportunity_ExitCriteriaUtility.isMeetingExitCriteria(testOpp2, Constants.OPPTY_STAGE_6, Constants.OPPTY_STAGE_4,testOpp3);
            //system.assertEquals(false, testAssert);
            //testAssert = Opportunity_ExitCriteriaUtility.isMeetingExitCriteria(testOpp, Constants.OPPTY_STAGE_6, Constants.OPPTY_STAGE_5,testOpp);
            //system.assertEquals(false, testAssert);
            testAssert = Opportunity_ExitCriteriaUtility.isMeetingExitCriteria(testOpp2, Constants.OPPTY_STAGE_7, Constants.OPPTY_STAGE_6,testOpp3);
            //system.assertEquals(false, testAssert);
            //testAssert = Opportunity_ExitCriteriaUtility.isMeetingExitCriteria(testOpp, Constants.OPPTY_STAGE_5, Constants.OPPTY_STAGE_3,testOpp);
            //system.assertEquals(true, testAssert);
        }
        Test.stopTest();
    }
    
    //test methods to check the functionality of Opportunity_ExitCriteriaUtility.cls
    // @isTest (seealldata=true)
    static testMethod void testOpportunitiesExitCriteriaNotMet3() {
        // create User
        Profile p = [SELECT Id FROM Profile WHERE Name = :Constants.PROFILE_SYS_ADMIN];
        
        User testUser1 = Test_Utils.createUser(p, 'test1234@experian.com', 'test1');
        testUser1.business_unit__c = 'APAC CS SEA';
        insert testUser1;
        
        Map<String, Id> mapstr1 = Opportunity_ExitCriteriaUtility.oppRecordTypeMap;
        MAP<String,Id> oppRecTypeMap = new MAP<String,Id>();
        for (RecordType rt : [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Opportunity']) {
            oppRecTypeMap.put(rt.Name, rt.Id); }
        
        system.runAs(testUser1) {
            User user1 = Test_Utils.createUser(Constants.PROFILE_SYS_ADMIN);
            insert user1;
            
            Account testAccount = Test_Utils.insertAccount();
            testAccount.Is_Competitor__c = true;
            update testAccount;
            //Opportunity parentOppty = Test_utils.insertOpportunity(testAccount.ID);
            // Create an opportunity
            Opportunity testOpp = Test_Utils.createOpportunity(testAccount.Id);
            testOpp.Has_Senior_Approval__c = true;
            testOpp.StageName = Constants.OPPTY_STAGE_3;
            testOpp.Starting_Stage__c = Constants.OPPTY_STAGE_3;
            testOpp.Type = Constants.OPPTY_TYPE_NEW_FROM_NEW ;
            //testOpp.Business_Unit__c = 'UK&I GTM';
            testOpp.RecordTypeId = oppRecTypeMap.get('Transactional Sale');
            //testOpp.Previous_Opportunity__c = parentOppty.ID;
            insert testOpp;
            
            
            //OpportunityTriggerHandler.hasCheckedExitCriteria = false;
            testOpp.Amount = 500001;
            testOpp.amount_corp__c = 20000;
            testOpp.Stage_3_Approver__c = UserInfo.getUserId();
            testOpp.Has_Stage_3_Approval__c = true;
            testOpp.DP_Qualify_Approval__c = false;
            testOpp.StageName = Constants.OPPTY_STAGE_4;
            
            OpportunityTriggerHandler.groupName = 'REGION_APAC';
            update testOpp;
            
            testOpp = getOpptyDetail(testOpp.ID);
            
            Boolean testAssert = Opportunity_ExitCriteriaUtility.isMeetingExitCriteria(testOpp, Constants.OPPTY_STAGE_4, Constants.OPPTY_STAGE_3,testOpp);
            //DO Case 13543302: Disabled as no loner needed to validate
            //system.assertEquals(false, testAssert); 
            
            //Test_Utils.insertCompetitor(testOpp.Id);
            Contact contact = new Contact(FirstName = 'Test-Contact', LastName = 'J', Title = 'Test12');
            insert contact;
            
            Task newTask = new Task(WhatId = testOpp.Id,whoId = contact.Id,Outcomes__c=Constants.ACTIVITY_TYPE_SELECTION_CONFIRMED, Status = Constants.STATUS_COMPLETED);
              insert newTask;
            
            // Test_Utils.createOpptyTasks(testOpp.Id, true);
            
            OpportunityContactRole OppRole = new OpportunityContactRole(
                OpportunityId = testOpp.Id,
                ContactId = contact.Id,
                Role = Constants.DECIDER,
                IsPrimary = true
            );
            insert OppRole;
            Test.startTest();
            OpportunityTriggerHandler.hasCheckedExitCriteria = false;
            testOpp.ownerId = testUser1.Id;
            testOpp.Selection_confirmed_date__c = System.today().addDays(10);
            testOpp.Quote_delivered_date__c = System.today().addDays(10);
            testOpp.RecordTypeId = oppRecTypeMap.get('Standard');
            testOpp.Risk_Tool_Output__c = null;
            testOpp.StageName = Constants.OPPTY_STAGE_6;
            
            OpportunityTriggerHandler.groupName = 'REGION_APAC';
            update testOpp;

            testOpp = getOpptyDetail(testOpp.ID);
            
            testAssert = Opportunity_ExitCriteriaUtility.isMeetingExitCriteria(testOpp, Constants.OPPTY_STAGE_6, Constants.OPPTY_STAGE_4,testOpp);
            //system.assertEquals(false, testAssert);
            //testAssert = Opportunity_ExitCriteriaUtility.isMeetingExitCriteria(testOpp, Constants.OPPTY_STAGE_6, Constants.OPPTY_STAGE_5,testOpp);
            //system.assertEquals(false, testAssert);
            testAssert = Opportunity_ExitCriteriaUtility.isMeetingExitCriteria(testOpp, Constants.OPPTY_STAGE_7, Constants.OPPTY_STAGE_6,testOpp);
            //system.assertEquals(false, testAssert);
            //testAssert = Opportunity_ExitCriteriaUtility.isMeetingExitCriteria(testOpp, Constants.OPPTY_STAGE_5, Constants.OPPTY_STAGE_3,testOpp);
            //system.assertEquals(true, testAssert);
        }
        Test.stopTest();
    }
    //Added by Manoj
    static testMethod void testOpportunitiesReqTask() {
        // create User
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name = :Constants.PROFILE_SYS_ADMIN];
        
        User testUser1 = Test_Utils.createUser(p, 'test1234@experian.com', 'test1');
        testUser1.Region__c = Constants.REGION_EMEA;
        insert testUser1;
        
        system.runAs(testUser1) {
            User user1 = Test_Utils.createUser(Constants.PROFILE_SYS_ADMIN);
            insert user1;
            
            Account testAccount = Test_Utils.insertAccount();
            testAccount.Is_Competitor__c = true;
            update testAccount;
            //Opportunity parentOppty = Test_utils.insertOpportunity(testAccount.ID);
            // Create an opportunity
            Opportunity testOpp = Test_Utils.createOpportunity(testAccount.Id);
            testOpp.Has_Senior_Approval__c = true;
            testOpp.StageName = Constants.OPPTY_STAGE_3;
            testOpp.Starting_Stage__c = Constants.OPPTY_STAGE_3;
            testOpp.Type = 'New';
            //testOpp.Previous_Opportunity__c = parentOppty.ID;
            insert testOpp;
            
            Contact contact = new Contact(FirstName = 'Test-Contact', LastName = 'J');
            insert contact;
            
            Opportunity_ExitCriteriaUtility.hasTechSuppFieldRequired(testOpp);
            Opportunity_ExitCriteriaUtility.hasRequiredTask(testOpp,'Quote delivered');
            Map<String, String> mapstr = Opportunity_ExitCriteriaUtility.stagePicklistLabels; //Added by Manoj
            Map<String, Id> mapstr1 = Opportunity_ExitCriteriaUtility.oppRecordTypeMap;
        }
        Test.stopTest();
    }
    
    static testMethod void testTechSuppFieldRequired() {
        
        Profile p = [select id from profile where name=: Constants.PROFILE_SYS_ADMIN ];
        User testUser1 = Test_Utils.createUser(p, 'test1234@experian.com', 'test1');
        testUser1.region__c='EMEA';
        insert testUser1;
        
        system.runAs(testUser1) {
            
            // Create an account
            Account testAccount = Test_Utils.insertAccount();
            // Create an opportunity
            Opportunity testOpp = Test_Utils.createOpportunity(testAccount.Id);
            testOpp.Type = Constants.OPPTY_NEW_FROM_EXISTING ;
            testOpp.Tech_Support_Maintenance_Tiers__c = null;
            insert testOpp;
            
            //////////////////////
            // Create Opportunity Line Item
            Product2 product = Test_Utils.insertProduct();
            product.RevenueScheduleType = Constants.REVENUE_SCHEDULED_TYPE_REPEAT;
            product.RevenueInstallmentPeriod = Constants.INSTALLMENT_PERIOD_DAILY;
            product.NumberOfRevenueInstallments = 2;
            //product.CanUseQuantitySchedule = false;
            product.CanUseRevenueSchedule = true;
            product.business_line__c='Software';
            product.Global_Business_Line__c='Decision Analytics';
            update product;
            System.debug('***debug1.0**'+Limits.getQueries());
            
            
            //Pricebook2 pricebook = Test_Utils.getPriceBook2();
            //Pricebook2 standardPricebook = Test_Utils.getPriceBook2('Standard Price Book');
            PricebookEntry stdPricebookEntry = Test_Utils.insertPricebookEntry(product.Id, Test.getStandardPricebookId(), Constants.CURRENCY_USD);
            //insert OLI
            OpportunityLineItem opportunityLineItem2 = Test_Utils.creATEOpportunityLineItem(testOpp.Id, stdPricebookEntry.Id, testOpp.Type);
            
            opportunityLineItem2.Type_of_Sale__c='Maintenance';
            opportunityLineItem2.UnitPrice=1;
            opportunitylineItem2.totalprice=null;
            
            INSERT opportunityLineItem2;
            
            Opportunity_ExitCriteriaUtility.hasTechSuppFieldRequired(testOpp);
            
            DP_No_Admin_Required__c DPno= new DP_No_Admin_Required__c(name='Test',product_name__c='Test',DP_Package_code__c='Test');
            insert DPno;
            
            
            Opportunity opptest  = getOpptyDetail(testOpp.ID);
            
            Opportunity_ExitCriteriaUtility.hasTechSuppFieldRequired(opptest);
            Boolean testAssert = Opportunity_ExitCriteriaUtility.isMeetingExitCriteria(opptest, Constants.OPPTY_STAGE_7, Constants.OPPTY_STAGE_6,testOpp);
            
        }
        
    }
    
    //Get oppty detail from database
    private static Opportunity getOpptyDetail (String opptyID) {
        return [
            SELECT ID, RecordTypeId, Competitor_Count__c, Turn_Off_Contact_Role_Criteria_Check__c, StageName,Starting_Stage__c,
            CurrencyIsoCode, Budget__c, Has_Stage_3_Approval__c, Has_Senior_Approval__c,Opportunity_Products_Count__c,
            Owner.Region__c, Stage_3_Approver__c, Senior_Approver__c,
            /*Is_There_Commercial_Risk__c, Is_There_Delivery_Risk__c,
            Is_There_Financial_Risk__c, Is_There_Legal_Risk__c,
            Has_There_Been_Significant_Change__c,*/ Type, OwnerId, Owner_s_Business_Unit__c,
            Risk_Tool_Output__c, Risk_Tool_Output_Code__c,
            Deployment__c, Hard_Go_Live_Date__c, Total_Eligible_Population__c,Customer_Base_Migration__c,
            Business_Unit__c,
            //Below_Review_Thresholds__c, T-271695: Removed reference to Below_Review_Thresholds__c
            Amount, CloseDate, Tech_Support_Maintenance_Tiers__c,
            Primary_Quote_has_been_Approved__c, Quote_Primary__c, Quote_Count__c,CPQ_User_to_Validate__c,CPQ_User_to_Validate2__c,CPQ_User_to_Validate3__c,// CRM2:W-005496
            Amount_Corp__c,DP_Qualify_Approval__c,Contract__c,Original_Contract_Effective_date__c,
            Conflict_of_Interest__c, //Case 14818841
            Recurring_Incremental__c,Deal_Category__c,CPQ_Approval_Required__c,Title_of_Original_Agreement__c,Commencement_Date_of_Original_Agreement__c,Effective_Date__c,Quote_Status__c,
            (SELECT Id, Type_of_Sale__c, PricebookEntry.Product2.Global_Business_Line__c, PricebookEntry.Product2.Business_Line__c,
             Product_Features__c,Product_Type__c,Contracted_MRR__c,Setup_Fee__c,Pre_payment__c,Revenue_type__c,Blanket_Coverage__c,
             Data_Usage__c, Manual_Registration__c, Users_To__c,PricebookEntry.Product2.Name,DP_Product_Package_Code__c //16166194
             FROM OpportunityLineItems WHERE IsDeleted = false),
            (SELECT Id, Role, IsPrimary
             FROM OpportunityContactRoles
             WHERE (Role = :Constants.DECIDER AND IsDeleted = false)
             OR (Role =: Constants.OPPTY_CONTACT_ROLE_PURCHASE_LEDGER AND IsDeleted = false) OR (Role =: Constants.OPPTY_CONTACT_ROLE_ADMIN AND IsDeleted = false)),
            (SELECT Id, Type, Status, Outcomes__c FROM Tasks
             WHERE Status = :Constants.STATUS_COMPLETED AND IsDeleted = false)
            FROM Opportunity  WHERE ID = :opptyID ALL ROWS
            
        ];
    }
    
    static testMethod void testOpportunities_Deal() {
        // create User
        Profile p = [SELECT Id FROM Profile WHERE Name = :Constants.PROFILE_SYS_ADMIN];
        
        User testUser1 = Test_Utils.createUser(p, 'test1234@experian.com', 'test1');
        testUser1.Region__c = Constants.REGION_UKI;
        testUser1.business_unit__c = Constants.BUSINESS_UNIT_UKI_GTM;
        insert testUser1;
        
        Opportunity_Deal_Categories__mdt deal = [select MasterLabel, Deal_Category__c, CPQ_Quote_Required__c,Mandatory_Label__c, CPQ_Contract_Required__c, Mandatory__c from Opportunity_Deal_Categories__mdt where Business_Unit__c like '%UK%' limit 1];
        
        system.runAs(testUser1) {
            User user1 = Test_Utils.createUser(Constants.PROFILE_SYS_ADMIN);
            insert user1;
            
            Account testAccount = Test_Utils.insertAccount();
            testAccount.Is_Competitor__c = true;
            update testAccount;
            //Opportunity parentOppty = Test_utils.insertOpportunity(testAccount.ID);
            // Create an opportunity
            Opportunity testOpp = Test_Utils.createOpportunity(testAccount.Id);
            testOpp.Has_Senior_Approval__c = true;
            testOpp.StageName = Constants.OPPTY_STAGE_3;
            testOpp.Starting_Stage__c = Constants.OPPTY_STAGE_3;
            testOpp.Type = Constants.OPPTY_TYPE_RENEWAL;
            //testOpp.Previous_Opportunity__c = parentOppty.ID;
            testOpp.OwnerId = testUser1.id;
            testOpp.Business_Unit__c = 'UK&I GTM';
            testOpp.Deal_Category__c = deal.Deal_Category__c;
            insert testOpp;
            
            OpportunityTriggerHandler.hasCheckedExitCriteria = false;
            testOpp.Amount = 500001;
            testOpp.StageName = Constants.OPPTY_STAGE_4;
            
            OpportunityTriggerHandler.groupName = 'REGION_UKI';
            update testOpp;
            
            testOpp = getOpptyDetail(testOpp.ID);
            
            Boolean testAssert = Opportunity_ExitCriteriaUtility.isPassingRequiredExitCriteria(testOpp, Constants.OPPTY_STAGE_4, Constants.OPPTY_STAGE_3,testOpp);
            
            //Test_Utils.insertCompetitor(testOpp.Id);
            Contact contact = new Contact(FirstName = 'Test-Contact', LastName = 'J');
            contact.Status__c = Constants.CONTACT_STATUS_LEFT;
            insert contact;
            
            //   Test_Utils.createOpptyTasks(testOpp.Id, true);
            
            OpportunityContactRole OppRole = new OpportunityContactRole(
                OpportunityId = testOpp.Id,
                ContactId = contact.Id,
                Role = Constants.DECIDER,
                IsPrimary = true
            );
            insert OppRole;
            
            Boolean testAssert1 = Opportunity_ExitCriteriaUtility.isMeetingExitCriteria(testOpp, Constants.OPPTY_STAGE_6, Constants.OPPTY_STAGE_4,testOpp);
            
            Boolean testAssert2 = Opportunity_ExitCriteriaUtility.isMeetingExitCriteria(testOpp, Constants.OPPTY_STAGE_7, Constants.OPPTY_STAGE_6,testOpp);
          
            Opportunity_ExitCriteriaUtility.hasRequiredTask([select id, (select id, Status, Outcomes__c from Tasks) from Opportunity where id=:testOpp.Id limit 1],'Quote delivered');
            
            
        }
    }
    
    static testMethod void testOpportunities_DealManditory() {
        // create User
        Profile p = [SELECT Id FROM Profile WHERE Name = :Constants.PROFILE_SYS_ADMIN];
        
        User testUser1 = Test_Utils.createUser(p, 'test1234@experian.com', 'test1');
        testUser1.Region__c = Constants.REGION_UKI;
        testUser1.business_unit__c = Constants.BUSINESS_UNIT_UKI_GTM;
        insert testUser1;
        
        Opportunity_Deal_Categories__mdt[] deallist = [select MasterLabel, Deal_Category__c, CPQ_Quote_Required__c,Mandatory_Label__c, CPQ_Contract_Required__c, Mandatory__c from Opportunity_Deal_Categories__mdt where Business_Unit__c LIKE '%uk%' ];
        Opportunity_Deal_Categories__mdt deal;
        
        for (Opportunity_Deal_Categories__mdt d : deallist){
            if(d.Mandatory__c !=null){
                deal = d;
            }
        }
        
        system.runAs(testUser1) {
            User user1 = Test_Utils.createUser(Constants.PROFILE_SYS_ADMIN);
            insert user1;
            
            Account testAccount = Test_Utils.insertAccount();
            testAccount.Is_Competitor__c = true;
            update testAccount;
            //Opportunity parentOppty = Test_utils.insertOpportunity(testAccount.ID);
            // Create an opportunity
            Opportunity testOpp = Test_Utils.createOpportunity(testAccount.Id);
            testOpp.Has_Senior_Approval__c = true;
            testOpp.StageName = Constants.OPPTY_STAGE_3;
            testOpp.Starting_Stage__c = Constants.OPPTY_STAGE_3;
            testOpp.Type = Constants.OPPTY_TYPE_RENEWAL;
            //testOpp.Previous_Opportunity__c = parentOppty.ID;
            testOpp.OwnerId = testUser1.id;
            testOpp.Business_Unit__c = 'UK&I GTM';
            testOpp.Deal_Category__c = deal.Deal_Category__c;
            insert testOpp;
            
            OpportunityTriggerHandler.hasCheckedExitCriteria = false;
            testOpp.Amount = 500001;
            testOpp.StageName = Constants.OPPTY_STAGE_4;
            
            OpportunityTriggerHandler.groupName = 'REGION_UKI';
            update testOpp;
            
            testOpp = getOpptyDetail(testOpp.ID);
            
            Boolean testAssert = Opportunity_ExitCriteriaUtility.isPassingRequiredExitCriteria(testOpp, Constants.OPPTY_STAGE_4, Constants.OPPTY_STAGE_3,testOpp);
            
            Test_Utils.insertCompetitor(testOpp.Id);
            Contact contact = new Contact(FirstName = 'Test-Contact', LastName = 'J');
            contact.Status__c = Constants.CONTACT_STATUS_LEFT;
            insert contact;
            
            // Test_Utils.createOpptyTasks(testOpp.Id, true);
            
            Task newTask = new Task(WhatId = testOpp.Id,whoId = contact.Id,Outcomes__c = Constants.ACTIVITY_TYPE_QUOTE_DELIVERED, Status = Constants.STATUS_COMPLETED);
            insert newTask;
            
            OpportunityContactRole OppRole = new OpportunityContactRole(
                OpportunityId = testOpp.Id,
                ContactId = contact.Id,
                Role = Constants.DECIDER,
                IsPrimary = true
            );
            insert OppRole;
            
            Boolean testAssert1 = Opportunity_ExitCriteriaUtility.isMeetingExitCriteria(testOpp, Constants.OPPTY_STAGE_6, Constants.OPPTY_STAGE_4,testOpp);
            
            Boolean testAssert2 = Opportunity_ExitCriteriaUtility.isMeetingExitCriteria(testOpp, Constants.OPPTY_STAGE_7, Constants.OPPTY_STAGE_6,testOpp);
            String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Task' and Name = 'Opportunity Plan'].Id;
                        
            Opportunity_ExitCriteriaUtility.hasRequiredTask([select id, (select id, Status, Outcomes__c from Tasks) from Opportunity  limit 1],'Quote delivered');
            
            
        }
    }
    static testMethod void testOpportunities_DealManditory2() {
        // create User
        Profile p = [SELECT Id FROM Profile WHERE Name = :Constants.PROFILE_SYS_ADMIN];
        
        User testUser1 = Test_Utils.createUser(p, 'test1234@experian.com', 'test1');
        testUser1.Region__c = Constants.REGION_NA;
        testUser1.business_unit__c = 'NA CS Automotive';
        insert testUser1;
        
        Opportunity_Deal_Categories__mdt[] deallist = [select MasterLabel, Deal_Category__c, CPQ_Quote_Required__c,Mandatory_Label__c, CPQ_Contract_Required__c, Mandatory__c from Opportunity_Deal_Categories__mdt where Business_Unit__c LIKE '%na cs%' ];
        Opportunity_Deal_Categories__mdt deal;
        
        for (Opportunity_Deal_Categories__mdt d : deallist){
            if(d.Mandatory__c !=null){
                deal = d;
            }
        }
        
        system.runAs(testUser1) {
            User user1 = Test_Utils.createUser(Constants.PROFILE_SYS_ADMIN);
            insert user1;
            
            Account testAccount = Test_Utils.insertAccount();
            testAccount.Is_Competitor__c = true;
            update testAccount;
            //Opportunity parentOppty = Test_utils.insertOpportunity(testAccount.ID);
            // Create an opportunity
            Opportunity testOpp = Test_Utils.createOpportunity(testAccount.Id);
            testOpp.Has_Senior_Approval__c = true;
            testOpp.StageName = Constants.OPPTY_STAGE_3;
            testOpp.Starting_Stage__c = Constants.OPPTY_STAGE_3;
            testOpp.Type = Constants.OPPTY_TYPE_RENEWAL;
            //testOpp.Previous_Opportunity__c = parentOppty.ID;
            testOpp.OwnerId = testUser1.id;
            testOpp.Business_Unit__c = 'NA CS Automotive';
            testOpp.Deal_Category__c = deal.Deal_Category__c;
            testOpp.No_Previous_Opportunity__c = true;
            insert testOpp;
                        
            testOpp = getOpptyDetail(testOpp.ID);
            OpportunityTriggerHandler.hasCheckedExitCriteria = false;
            testOpp.Amount = 500001;
            testOpp.OwnerId = testUser1.id;
            testOpp.StageName = Constants.OPPTY_STAGE_4;
            
            OpportunityTriggerHandler.groupName = 'REGION_NA';
            update testOpp;
                        
            Boolean testAssert = Opportunity_ExitCriteriaUtility.isPassingRequiredExitCriteria(testOpp, Constants.OPPTY_STAGE_4, Constants.OPPTY_STAGE_3,testOpp);
            
            //Test_Utils.insertCompetitor(testOpp.Id);
            Contact contact = new Contact(FirstName = 'Test-Contact', LastName = 'J');
            contact.Status__c = Constants.CONTACT_STATUS_LEFT;
            insert contact;
            
            // Test_Utils.createOpptyTasks(testOpp.Id, true);
            
            Task newTask = new Task(WhatId = testOpp.Id,whoId = contact.Id,Outcomes__c = Constants.ACTIVITY_TYPE_QUOTE_DELIVERED, Status = Constants.STATUS_COMPLETED);
            insert newTask;
            
            OpportunityContactRole OppRole = new OpportunityContactRole(
                OpportunityId = testOpp.Id,
                ContactId = contact.Id,
                Role = Constants.DECIDER,
                IsPrimary = true
            );
            insert OppRole;
            
            Boolean testAssert1 = Opportunity_ExitCriteriaUtility.isMeetingExitCriteria(testOpp, Constants.OPPTY_STAGE_6, Constants.OPPTY_STAGE_4,testOpp);
            
            Boolean testAssert2 = Opportunity_ExitCriteriaUtility.isMeetingExitCriteria(testOpp, Constants.OPPTY_STAGE_7, Constants.OPPTY_STAGE_6,testOpp);
            String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Task' and Name = 'Opportunity Plan'].Id;
                        
            Opportunity_ExitCriteriaUtility.hasRequiredTask([select id, (select id, Status, Outcomes__c from Tasks) from Opportunity  limit 1],'Quote delivered');
        
        }
    }
    
    static testMethod void testOpportunities_EPS() {
        // create User
        Profile p = [select id from profile where name=: Constants.PROFILE_SYS_ADMIN ];
        User testUser1 = Test_Utils.createUser(p, 'test1234@experian.com', 'test1');
        testUser1.Region__c = Constants.REGION_NA;
        testUser1.Global_Business_Line__c = 'Consumer Services';
        testUser1.Business_Line__c = 'NA Consumer Services';
        testUser1.business_unit__c = 'NA Consumer Services';
        insert testUser1;
        
        system.runAs(testUser1) {
                        
            // Create an account
            Account testAccount = Test_Utils.insertAccount();
            // Create an opportunity
            Opportunity testOpp = Test_Utils.createOpportunity(testAccount.Id);
            testOpp.Type = Constants.OPPTY_NEW_FROM_EXISTING ;
            testOpp.Hard_Go_Live_Date__c='No';
            testOpp.Customer_Base_Migration__c='N/A';
            testOpp.ownerId = testUser1.Id;
            testOpp.Deployment__c = 'Hybrid';
            insert testOpp;
            
            
            //////////////////////
            // Create Opportunity Line Item
            Product2 product = Test_Utils.insertProduct();
            product.name = 'DTC Core';
            product.RevenueScheduleType = Constants.REVENUE_SCHEDULED_TYPE_REPEAT;
            product.RevenueInstallmentPeriod = Constants.INSTALLMENT_PERIOD_DAILY;
            product.NumberOfRevenueInstallments = 2;
            //product.CanUseQuantitySchedule = false;
            product.CanUseRevenueSchedule = true;
            product.business_line__c='Software';
            product.Global_Business_Line__c='Decision Analytics';
            update product;
            System.debug('***debug1.0**'+Limits.getQueries());
            
            
            //Pricebook2 pricebook = Test_Utils.getPriceBook2();
            //Pricebook2 standardPricebook = Test_Utils.getPriceBook2('Standard Price Book');
            PricebookEntry stdPricebookEntry = Test_Utils.insertPricebookEntry(product.Id, Test.getStandardPricebookId(), Constants.CURRENCY_USD);
            //insert OLI
            OpportunityLineItem opportunityLineItem2 = Test_Utils.creATEOpportunityLineItem(testOpp.Id, stdPricebookEntry.Id, testOpp.Type);
            
            opportunityLineItem2.Type_of_Sale__c='Maintenance';
            opportunityLineItem2.UnitPrice=1;
            opportunitylineItem2.totalprice=null;
            opportunitylineItem2.Product_Features__c = null;
            opportunitylineItem2.Revenue_type__c='Wholesale';
            opportunitylineItem2.Blanket_Coverage__c = null;
            
            INSERT opportunityLineItem2;
            
            Opportunity Opptest = getOpptyDetail(testOpp.ID);
            
            OpportunityTriggerHandler.hasCheckedExitCriteria = false;
            Opptest.Total_Eligible_Population__c = null;
            Opptest.ownerId = testUser1.Id;
            Opptest.Tech_Support_Maintenance_Tiers__c = null;
            Opptest.StageName = Constants.OPPTY_STAGE_4;
            update Opptest;
            
            
            
            Boolean testAssert = Opportunity_ExitCriteriaUtility.isMeetingExitCriteria(testOpp, Constants.OPPTY_STAGE_4, Constants.OPPTY_STAGE_3,Opptest);
                                
            Opportunity_ExitCriteriaUtility.hasTechSuppFieldRequired(testOpp);
            
            DP_No_Admin_Required__c DPno= new DP_No_Admin_Required__c(name='Test',product_name__c='Test',DP_Package_code__c='Test');
            insert DPno;
            
            
            Opportunity opptest2  = getOpptyDetail(Opptest.ID);
            OpportunityTriggerHandler.hasCheckedExitCriteria = false;
            opptest2.StageName = Constants.OPPTY_STAGE_6;
            update opptest2;
            
            Opportunity_ExitCriteriaUtility.hasTechSuppFieldRequired(opptest);
            testAssert = Opportunity_ExitCriteriaUtility.isMeetingExitCriteria(opptest, Constants.OPPTY_STAGE_7, Constants.OPPTY_STAGE_6,opptest2);
            opptest2.StageName =Constants.OPPTY_STAGE_7;
            //update testOpp;
            testAssert= Opportunity_ExitCriteriaUtility.isStage7Ready(opptest);
        }
    }
    static testMethod void testisStage7ReadyForEBA(){
        //Creating admin user
        User testUser = Test_Utils.createUser(Constants.PROFILE_SYS_ADMIN);
        insert testUser;
        system.runAs(testUser) {
            
            // Create Account
            Account testAccount = Test_Utils.insertAccount();
            
            Address__c addrs1 = Test_Utils.insertAddress(true);
            
            Account_Address__c accAddrs = Test_Utils.insertAccountAddress(true, addrs1.Id, testAccount.Id);
            // Create an opportunity
            Opportunity sObjOpp = Test_utils.createOpportunity(testAccount.Id);
            insert sObjOpp;
            
            Contact newcontact  = Test_Utils.insertContact(testAccount.id);
            Address__c address = Test_Utils.insertAddress(true);
            
            Test_Utils.insertContactAddress(true, address.Id, newcontact.Id);
            
            OpportunityContactRole oppContactRole = new OpportunityContactRole(
                ContactId = newcontact.Id,
                OpportunityId = sObjOpp.Id,
                IsPrimary = true,
                Role = Constants.OPPTY_CONTACT_ROLE_PURCHASE_LEDGER
            );
            insert oppContactRole;
            system.debug(oppContactRole);
            OpportunityContactRole oppcrole = [select id,opportunityid,isdeleted, role from OpportunityContactRole where opportunityid = : sObjOpp.Id];
            system.debug('oppcrole--'+oppcrole);
            //create opportunity line item
            Product2 product = Test_Utils.insertProduct();
            product.Name = 'Business Express: Credit Review';
            product.RevenueScheduleType = Constants.REVENUE_SCHEDULED_TYPE_REPEAT;
            product.RevenueInstallmentPeriod = Constants.INSTALLMENT_PERIOD_DAILY;
            product.NumberOfRevenueInstallments = 2;
            product.CanUseRevenueSchedule = true;
            update product;
            test.StartTest();
            PricebookEntry stdPricebookEntryObj = Test_Utils.insertPricebookEntry(product.Id, Test.getStandardPricebookId(), Constants.CURRENCY_USD);
            //insert OLI
            List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
            olis.add(Test_Utils.createOpportunityLineItem(sObjOpp.Id, stdPricebookEntryObj.Id, sObjOpp.Type));
            olis.add(Test_Utils.createOpportunityLineItem(sObjOpp.Id, stdPricebookEntryObj.Id, sObjOpp.Type));
            
            olis[0].Type__c = Constants.OPPTY_LINE_ITEM_TYPE_RENEWAL;//Case #02088090
            
            for (OpportunityLineItem oli : olis){
                oli.Start_Date__c = System.today().addDays(-5);
                oli.End_Date__c = System.today();
            }
            insert olis;
            Opportunity_ExitCriteriaUtility.hasTechSuppFieldRequired(sObjOpp);
            
            DP_No_Admin_Required__c DPno= new DP_No_Admin_Required__c(name='Test',product_name__c='Test',DP_Package_code__c='Test');
            insert DPno;
            Opportunity opptest  = getOpptyDetail(sObjOpp.ID);
            
            Opportunity_ExitCriteriaUtility.hasTechSuppFieldRequired(opptest);
            Boolean testAssertboolean = Opportunity_ExitCriteriaUtility.isMeetingExitCriteria(opptest, Constants.OPPTY_STAGE_7, Constants.OPPTY_STAGE_6,sObjOpp);
            sObjOpp.StageName = Constants.OPPTY_STAGE_7;
            //update sObjOpp; 
            string testAssert= Opportunity_ExitCriteriaUtility.isStage7ReadyForEBA(opptest);
            test.stopTest();
        }
    }
    
        static testMethod void testOpportunitiesXPartner() {
        
        //Creating admin user
        User AdminUser = Test_Utils.createUser(Constants.PROFILE_SYS_ADMIN);
        insert AdminUser;
            Boolean natest = Opportunity_ExitCriteriaUtility.isNACustomer;
        system.runAs(AdminUser) {
            Account partnerAccount1 = new Account(Name = 'Test Account1', BillingCountry = 'India', ShippingCountry = 'India',BillingState='Karnataka' ,Is_Partner__c=true,Industry='Automotive',Sector__c='Sales and service (dealers and groups)');
            insert partnerAccount1;
            Contact contact = new Contact(FirstName = 'Test-Contact', LastName = 'J');
            contact.Status__c = Constants.CONTACT_STATUS_LEFT;
            contact.AccountId=partnerAccount1.id;
            contact.Is_Community_User__c=true;
            contact.Title='Mr';
            
            insert contact;
            Opportunity sObjOpp = Test_utils.createOpportunity(partnerAccount1.Id);
            insert sObjOpp;
            Task newTask = new Task(WhatId = sObjOpp.Id,whoId = contact.Id,Outcomes__c=Constants.ACTIVITY_TYPE_SELECTION_CONFIRMED, Status = Constants.STATUS_COMPLETED);
                insert newTask;
            Profile partnerprofile = [SELECT Id FROM Profile WHERE Name = 'XPartner - NA Auto Sales Exec'];    
            User user = new User(alias = 'test123', email='test123@experian.com',
                                 emailencodingkey='UTF-8', lastname='NetworkMember123', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = partnerprofile.Id, country='United States',IsActive =true,
                                 ContactId = contact.Id,
                                 timezonesidkey='America/Los_Angeles', username='Experiantest.partner@experian.com');
            
            insert user;
            sObjOpp.OwnerId= user.id;
        Opportunity_ExitCriteriaUtility.hasRequiredTask([select id, (select id, Status, Outcomes__c from Tasks) from Opportunity  limit 1],'Quote delivered');
        
        }
    }
    
}