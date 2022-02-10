/**=====================================================================
 * Appirio, Inc
 * Name: OpportunityTriggerHandler_Test
 * Description: Test various functionality of OpportunityTriggerHandler.cls and
 *                          OpportunityTriggerHelper.cls
 * Created Date: 10/30/2013
 * Created By    : Pankaj Mehra (Appirio)
 *
 * Date Modified      Modified By                  Description of the update
 * Feb 06th, 2014     Naresh Kr Ojha (Appirio)     Merged old class TestOpportunityTriggerHanlder.cls
 *                                                 and created test method for T-243865
 * Feb 27th, 2014     Nathalie Le Guay (Appirio)   Added opp.Starting_Stage__c values
 * Feb 28th, 2014     Naresh kr Ojha (Appirio)     T-252684: created methods to cover positive and negative senarios for
 *                                                 test access to create opportunities
 * Feb 28th, 2014     Nathalie Le Guay             Adding use of strings from Constants.cls
 * Mar 04th, 2014     Arpita Bose (Appirio)        T-243282: Added Constants in place of String
 * Mar 05th, 2014     Arpita Bose (Appirio)        Fixed error.
 * Mar 14th, 2014     Arpita Bose (Appirio)        T-253906: Fixed error
 * Mar 19th, 2014     Arpita Bose (Appirio)        T-260619: Added testmethod for testing createOrders method
 * Mar 20th, 2014     Megha Agarwal (Appirio JDC)  T-253868: Added testmethod for testing Validation on Service Dates method
 * Mar 21th, 2014     Jinesh Goyal (Appirio)       T-253906: updated method opptyReopenOrderCreationTest, testOpportunitiesExitCriteriaNotMet
 * Mar 24th, 2014     Naresh Kr Ojha(Appirio)      T-264560: Added to test oppty closing behaviour updated opptyReopenOrderCreationTest ()
 *                                                 T-264492: added method testStageDurationOnOppty()
 * Mar 28th, 2014     Arpita Bose(Appirio)         T-266095: Removing reference to the field
 *                                                 Opportunity.Status__c which is removed
 * Apr 01st, 2014     Arpita Bose(Appirio)         T-268401: Removed reference to Opp's Service Start/End dates and method testUpdateServiceDatesOnOLI
 *                                                 is commented
 * Apr 01st, 2014     Arpita Bose(Appirio)         T-265681: Added method testMultiCurrencyFieldUpdate()to test Multi-currency dashboard
 * Apr 02nd, 2014     Arpita Bose(Appirio)         T-268405: Renamed OLI's Service Start/end dates to Start/End dates
 * Apr 02nd, 2014     Arpita Bose                  T-268663: Renamed OrderLineItem's Service Start/End dates to Start/End dates
 * Apr 07th, 2014     Nathalie Le Guay             Update to Order LI.Renewable__c as it becomes a picklist
 * Apr 07th, 2014     Mohit Parnami                T-267436: Added testUpdateOppFieldsIfWonOrClosed() to test opp field stamping from Owner's fields
 * Apr 08th, 2014     Nathalie Le Guay             Order LI.Renewable__c renamed to Type__c
 * Apr 10th, 2014     Arpita Bose(Appirio)         T-270419: opportunity.Contract_Term__c is commented as the field type is changed
 * Apr 12th, 2014     Arpita Bose                  Updated methods createOrderAndOrderLineItemTest() and opptyReopenOrderCreationTest()to fix failure
 * Apr 15th, 2014     Arpita Bose                  T-271695:Removed reference to Below_Review_Thresholds__c
 * Apr 16th, 2014     Arpita Bose                  T-271695: Renamed fields Has_Stage_4_Approval__c to Has_Stage_3_Approval__c
 *                                                  and Has_Stage_5_Approval__c to Has_Senior_Approval__c
 * Apr 21st, 2014     Arpita Bose                  Updated method testOpportunitiesExitCriteriaNotMet()to increase the code coverage
 * Apr 22nd, 2014     Aditi Bhardwaj               Added testCreateOppContactRoles method to evaluate functionality of CreateOppContactRoles method
 * Apr 24, 2014       Nathalie Le Guay             Commenting TestReAlignBUsOnOwnerChange() as it test BU Relationship
 * May 05th, 2014     Bharti Mehta(Appirio JDC)    T-273787: Experian Sales -  added method testOppToOpportunityPlansSync
 * May 07th, 2014     Rahul Jain                   T-275529 : Experian Sales - added methods testUpdateAccountPlanOpportunities, testCreateAccountPlanOpportunities
 * May 21st, 2014     Nathalie Le Guay             Fix test class due to validation rule: Opportunity.Must_be_Stage_3_if_not_a_renewal
 * Jul 31st, 2014     Arpita Bose                  T-286015: Phase 2 Sprint 0 refactoring: Fix test class requiring a specific user currency
 * Aug 18th, 2014     Arpita Bose                  T-313163: Updated method createOrderAndOrderLineItemTest() for CPQ_Quantity__c and updated methods
 *                                                 testUpdateOppFieldsIfWonOrClosed() and opptyReopenOrderCreationTest() to fix the failure
 * Sep 04th, 2014     Naresh Kr Ojha               T-317502: create test method to test moveTaskToOpptyWhenCreatedFromContact ()
 * Sep 08th, 2014     Naresh Kr Ojha               T-317883: Updated method createOrderAndOrderLineItemTest for the functionality implemented in task.
 * Sep 10, 2014       Nathalie Le Guay             I-130073 - Commenting testCreateOppContactRoles() as this is done by the 'conId' parameter
 * Sep 11, 2014       Nathalie Le Guay             T-317502 Cancelled - Removing testMoveTaskToOpptyWhenCreatedFromContact()
 * Sep 15th, 2014     Arpita Bose                  Added method testOnDemandOpportunityLineItem()
 * Sep 15th, 2014     Naresh Kr Ojha               Label.OPPTY_ERR_ONDEMAND_PRODUCT
 * Sep 16th, 2014     Arpita Bose                  I-130655: Reference of On_Demand_Product__c has been changed to EDQ_On_Demand_Product__c on OpportunityLineItem
 * Sep 17th, 2014     Arpita Bose                  T-319512: added method testCheckOpptyContactRoleOnClosedWon()
 * Sep 18th, 2014     Arpita Bose                  T-320132: added method test_checkOpptyChannelTypeOnClosedWon()
 * Sep 19th, 2014     Arpita Bose                  T-320157: Added method test_populateInvoiceToEndUser_EDQ1()
 * Sep 23rd, 2014     Arpita Bose                  T-321347: Added method testCreateOppContactRoles_RenewalOpps()
 * Sep 24th, 2014     Arpita Bose                  Added method test_populateInvoiceToEndUser_EDQ2() and test_populateInvoiceToEndUser_EDQ3()
 * Sep 25th, 2014     Arpita Bose                  Removed the use of IsDataAdmin__c from the class and added method test_createOppTeamMembers()
 * Sep 26th, 2014     Arpita Bose                  T-322920: Updated method testCheckOpptyContactRoleOnClosedWon() for Role='Purchase Ledger'
 * Sep 29th, 2014     Arpita Bose                  T-322814: Added method test_validateOpptyContactRoleOnClosedWon1() and test_validateOpptyContactRoleOnClosedWon2()
 * Oct 20th, 2014     Pallavi                      T-326540: Refactoring: Improve Opp Trigger ( Fix failure)
 * Oct 10, 2014       James Weatherall             Case #8991 Uncommented testMethod testOppToOpportunityPlansSync in order to test update Opp Plan method
 * Oct 27th,2014      Pallavi Sharma(Appirio)      Fix Failure
 * Nov 12th, 2014     Arpita Bose                  Added Type in test data of Opportunity and OLI
 * Feb 24th, 2015     Gaurav Kumar Chadha          T-364931 Added opportunityContactRolesAddressTest() method
 * Feb 25th, 2015     Arpita Bose                  T-364941: Added opportunityAccountAddressTest() method
 * Feb 27th, 2015     Paul Kissick                 Removed  Data, replacing with Test.getStandardPriceBookId(), API to v31.0
 * Mar 03rd, 2015     Arpita Bose                  T-364941: Removed method opportunityAccountAddressTest()
 * Mar 5th, 2015      Paul Kissick                 Case #583351 - Added line to reset isExecuted variable on OpportunityTrigger_OrderHelper class.
 * Mar 20th, 2015     Noopur                       T-371756: Modified opptyReopenOrderCreationTest(), opportunityContactRolesAddressTestForNONFreeTrial() and
 *                                                 opportunityContactRolesAddressTestForFreeTrial()
 * Mar 26th, 2015     Naresh                       T-373692: added method testpopulateSalesTeamChannelAndRegion() to test functionality.
 * Mar 30th, 2015     Gaurav Kumar Chadha          Commented methods test_populateInvoiceToEndUser_EDQ2() , test_populateInvoiceToEndUser_EDQ1() and  createOrderAndOrderLineItemTest() 
 * Apr 14th, 2015     Rohit B. (Appirio)           4 Methods were failing, so fix 3 of them (opportunityContactRolesAddressTestForNONFreeTrial, testOnDemandOpportunityLineItem, testOpptyAccWithSaasContact, testSyncOppDates)
 * Apr 29th, 2015     Arpita Bose                  Commented method testUpdateAccountPlanOpportunities() and testCreateAccountPlanOpportunities() as the main method realted to this is not found and duplicate method 
 *                                                 to test this functionality exists on AccountPlanTriggerHandler_Test and Account_Plan_OpportunTriggerHandler_Test class
 * Jun 18th, 2015     Paul Kissick                 Case #967382: Added test for account team to verify members are not replaced
 * Apr 7th, 2016      Paul Kissick                 Case 01932085: Fixing Test User Email Domain
 * Apr 15th, 2016     James Wills                  Case 01274352: Create Workflow Rule
 * Jun 16th, 2016     Paul Kissick                 Case 02024883: Fixing accountshare problem, and updated to v37.0
 * Jun 27th, 2016     Manoj Gopu                   Case #01947180 - Remove EDQ specific Contact object fields - MG COMMENTED CODE OUT
 * Jul 11th, 2016(QA) Manoj Gopu                   CRM2:W-005375: Added a method testUpdatePartners()
 * Jul 18th, 2016(QA) Manoj Gopu                   CRM2:W-005436: Added test to update ContactRole to DecisionMaker on creating New opp from Contact
 * Jul 27th, 2016     James Wills                  Case 01973473 - Opportunities-Workflow rule to add Automation of emails with surveys
 * Aug 01st, 2016(QA) Manoj Gopu                   CRM2:W-005490: Added a method testAlignDates()
 * Aug 19th, 2016     Tyaga Pati                   CRM2.0W-005402:Removed all References to Inactive__c because field will not be used in CRM anymore
 * Sep 02nd, 2016     Manoj Gopu                   CRM2:W-005490: Added asserts to the test method testAlignDates()
 * May 5th 2017       Sanket Vaidya                Case 02323805 - Permissions to view CI - test method for assignAccessToNewOwnerForConfidentialInformationRecords()
 * May 18th, 2017     Sanket Vaidya                Case 02166372 - New Customer Success Process - added test case for createNewSalesPlanningProcessForEDQ()
 * May 29th, 2017     James Wills                  Case 02426211 - Commented out reference to UserOrGroup.Name because it was causing test class failures.
 * May 31st, 2017     Sanket Vaidya                Case 02321126 - Opportunities missing Sales Team information - Added when_opp_owner_is_changed_Sales_Team_Channel_should_be_updated()
 * Oct 23rd, 2017     James Wills                  Case 13751443 - Fixed test class failure caused by deletion of role.
 * Nov 3rd, 2017      James Wills                  Case 02074137 - Added test_RenewalOpportunityTaskGeneration().
 * Nov. 14th, 2017    James Wills                  Case 02398031 - Rewrote when_opp_owner_is_changed_Sales_Team_Channel_should_be_updated().
 * Dec. 5th, 2017     James Wills
 * Feb. 20th, 2018    James Wills                  Case 15592558 - Improved coverage for test method createNewSalesPlanningProcess().
 * Apr. 17th, 2018    Malcolm Russell              DP Migration : add code coverae for DP logic
 * Apr. 20th, 2018    James Wills                  Case 15212272: Updated test class to avoid SOQL 101 errors & moved code in when_opp_owner_is_changed_Sales_Team_Channel_should_be_updated() to prevent mixed DML error. 
 * Jul. 3rd, 2018     Mauricio Murillo             Case 02339030: created new test method testCreateNextStepTasks
 * July, 4th, 2018    James Wills                  Case 16000648: Created test method test_ExperianOneProductProcessing().
 * Jun. 30th, 2020    Herbert Oliveira             Case 20615840: no changes to test class except for the API version update (48)
 * Sep   8th, 2020    Malcolm Russell              Updated when_Opp_Owner_is_changed_CI_Share_should_be_changed to use fixed user following best practice
  =====================================================================*/
@isTest
private class OpportunityTriggerHandler_Test {

  static final String MANAGER_USER = Constants.ROLE_GLOBAL_ADMIN;
  static final String SALES_EXEC_USER = /*'EMEA MS Spain Retail Sales';*/ Constants.ROLE_SALES_EXEC_RETAIL_PROPERTY;//Case 13751443
  static Opportunity opp;
  static List<OpportunityLineItem> olis;
  static PricebookEntry stdPricebookEntryObj;
 
  static testMethod void opportunityContactRolesAddressTestForNONFreeTrial(){
    // create User
    Profile p = [select id from profile where name=: Constants.PROFILE_SYS_ADMIN ];
    
    User testUser1 = Test_Utils.createUser(p, 'test1234@experian.com', 'test1');    
    insert testUser1;

    Account testAccount = Test_Utils.insertAccount();
    Contact newcontact  = Test_Utils.insertContact(testAccount.id);
    Address__c address = Test_Utils.insertAddress(true);
        
    //insert account address
    Account_Address__c accAddrs = Test_Utils.insertAccountAddress(true, address.Id, testAccount.Id);

    Test_Utils.insertContactAddress(true, address.Id, newcontact.Id);

    Contact newcontact2  = Test_Utils.insertContact(testAccount.id);

    Test_Utils.insertContactAddress(true, address.Id, newcontact2.Id);
 
    // Create an opportunity
    Opportunity testOpp = Test_Utils.createOpportunity(testAccount.Id);
    testOpp.Starting_Stage__c = Constants.OPPTY_STAGE_6;
    testOpp.Type = Constants.OPPTY_NEW_FROM_NEW;    
    insert testOpp;

    OpportunityContactRole oppContactRole = Test_Utils.insertOpportunityContactRole(true, testOpp.Id, newcontact.Id, Constants.DECIDER, true);
    OpportunityContactRole oppContactRole2 = Test_Utils.insertOpportunityContactRole(true, testOpp.Id, newcontact2.Id, Constants.OPPTY_CONTACT_ROLE_COMMERCIAL, false);

    Product2 product = Test_Utils.insertProduct();
    //Pricebook2 pricebook = Test_Utils.getPriceBook2();
    //Pricebook2 standardPricebook = Test_Utils.getPriceBook2(Constants.STANDARD_PRICE_BOOK);
    PricebookEntry stdPricebookEntry = Test_Utils.insertPricebookEntry(product.Id, Test.getStandardPriceBookId(), Constants.CURRENCY_USD);

    //insert OLI
    OpportunityLineItem opportunityLineItem1 = Test_Utils.createOpportunityLineItem(testOpp.Id, stdPricebookEntry.Id, testOpp.Type);
    opportunityLineItem1.Start_Date__c = Date.today().addDays(5);
    opportunityLineItem1.End_Date__c = System.today().addDays(10);
    insert opportunityLineItem1;
        
    Test.startTest();

    system.runAs(testUser1) {
      //update the Standard Opp
      testOpp.StageName = Constants.OPPTY_STAGE_7;
      testOpp.Channel_Type__c = Constants.OPPTY_CHANNEL_TYPE_DIRECT;
      testOpp.Amount = 100;
      testOpp.Has_Senior_Approval__c = true;
      testOpp.Starting_Stage__c = Constants.OPPTY_STAGE_6;
      testOpp.CloseDate = date.today();
      testOpp.Contract_Start_Date__c = date.today().addDays(1);
      testOpp.Contract_End_Date__c = date.today().addYears(1);

      try {
        update testOpp;
      } 
      catch (DmlException e) {
        //Assert Error Message
        //system.assert(e.getMessage().contains(label.OPPTY_ERR_MISSING_CONTACT_ADDRESS));
      }
          system.assertEquals(testOpp.CloseDate, date.today());
    }
    Test.stopTest();
  }
    
  static testMethod void opportunityContactRolesAddressTestForFreeTrial() {
      
    TriggerSettings__c insertTriggerSettings = Test_Utils.insertTriggerSettings(Constants.ACCOUNT_TRIGGER);
    insertTriggerSettings.IsActive__c = false;
    update insertTriggerSettings;
      
    insertTriggerSettings = Test_Utils.insertTriggerSettings(Constants.CONTACT_TRIGGER);
    insertTriggerSettings.IsActive__c = false;
    update insertTriggerSettings;
      
    insertTriggerSettings = Test_Utils.insertTriggerSettings(Constants.OPPTY_LINE_ITEM_TRIGGER);
    insertTriggerSettings.IsActive__c = false;
    update insertTriggerSettings;
      
    insertTriggerSettings = Test_Utils.insertTriggerSettings('OrderTrigger');
    insertTriggerSettings.IsActive__c = false;
    update insertTriggerSettings;
      
    // create User
    Profile p = [select id from profile where name=: Constants.PROFILE_SYS_ADMIN ];
      
    User testUser1 = Test_Utils.createUser(p, 'test1234@experian.com', 'test1');
    insert testUser1;
      
    Account testAccount = Test_Utils.insertAccount();
    Contact newcontact  = Test_Utils.insertContact(testAccount.id);
    Address__c address = Test_Utils.insertAddress(true);
        
    Test_Utils.insertContactAddress(true, address.Id, newcontact.Id);

    Contact newcontact2  = Test_Utils.insertContact(testAccount.id);
    system.runAs(testUser1) {
      // Create an opportunity
      Opportunity testOpp = Test_Utils.createOpportunity(testAccount.Id);
      testOpp.Starting_Stage__c = Constants.OPPTY_STAGE_6;
      testOpp.Type = Constants.OPPTY_NEW_FROM_NEW;
      insert testOpp;

      List<OpportunityContactRole> OCR = new List<OpportunityContactRole>();
      OpportunityContactRole oppContactRole = Test_Utils.insertOpportunityContactRole(false, testOpp.Id, newcontact.Id, Constants.DECIDER, true);
      OpportunityContactRole oppContactRole2 = Test_Utils.insertOpportunityContactRole(false, testOpp.Id, newcontact2.Id, Constants.OPPTY_CONTACT_ROLE_COMMERCIAL, false);
          
      OCR.add(oppContactRole);
      OCR.add(oppContactRole2);
      insert OCR;
          
      Product2 product = Test_Utils.insertProduct();
      PricebookEntry stdPricebookEntry = Test_Utils.insertPricebookEntry(product.Id, Test.getStandardPriceBookId(), Constants.CURRENCY_USD);

      //insert OLI
      OpportunityLineItem opportunityLineItem1 = Test_Utils.createOpportunityLineItem(testOpp.Id, stdPricebookEntry.Id, testOpp.Type);
      opportunityLineItem1.Start_Date__c = Date.today().addDays(5);
      opportunityLineItem1.End_Date__c = System.today().addDays(10);
      insert opportunityLineItem1;
        
      Test.startTest();

      testOpp.RollupConPrimaryTrue__c = true;
      testOpp.StageName = Constants.OPPTY_STAGE_7;
      testOpp.Channel_Type__c = Constants.OPPTY_CHANNEL_TYPE_DIRECT;
      testOpp.Amount = 100;
      testOpp.Has_Senior_Approval__c = true; 
      testOpp.Starting_Stage__c = Constants.OPPTY_STAGE_6;
      testOpp.CloseDate = date.today();
      testOpp.Contract_Start_Date__c = date.today().addDays(1);
      testOpp.Contract_End_Date__c = date.today().addYears(1);
      testOpp.Type = Constants.OPPTY_TYPE_FREE_TRIAL ; 
          
      update testOpp;
    
      system.assert(Constants.OPPTY_STAGE_7 == testOpp.StageName);
        
      Test.stopTest();
    }
  }
    
   
  static testMethod void testCreateOrders() {
    // create User
    Profile p = [select id from profile where name=: Constants.PROFILE_SYS_ADMIN ];
    User testUser1 = Test_Utils.createUser(p, 'test1234@experian.com', 'test1');
    insert testUser1;

    system.runAs(testUser1) {

      //create account
      Account testAccount = Test_Utils.insertAccount();
      
      Test.startTest();
      // Create opportunity
      Opportunity testOpp = Test_Utils.createOpportunity(testAccount.Id);
      //testOpp.Start_Date__c = date.today().addDays(2); //T-268400: Removed reference to Opp's Service Start/End Dates
      //testOpp.End_Date__c = date.today().addDays(10);
      testOpp.Amount = 100;
      insert testOpp;
      //create Contact
      Contact testcontact  = new Contact(
        FirstName = 'Larry',
        LastName = 'Ellison',
        AccountId = testAccount.Id,
        Email = 'larrye@email.com'
      );
      insert testcontact;

      //Order__c testOrder = OpportunityTrigger_OrderHelper.createOrder(testOpp, testcontact.Id);

      Test.stopTest();
      //system.debug('@@@@@@@Service start date'+testOrder.Service_Start_Date__c);
      //system.debug('#######Service end date'+ testOrder.Service_End_Date__c);
      // T-268400: Removed reference to Opp's service Start/End dates
      //system.assert(testOrder.Service_Start_Date__c <> null);
      //system.assert(testOrder.Service_End_Date__c <> null);
      //system.assertEquals(testOpp.Service_Start_Date__c, testOrder.Service_Start_Date__c);
      //system.assertEquals(testOpp.Service_End_Date__c, testOrder.Service_End_Date__c);
    }
  }
   
  static testMethod void testCheckAccessOnAccountFor_TeamMember() {
    //Creating admin user
    User sysAdmin = Test_Utils.createUser(Constants.PROFILE_SYS_ADMIN);
    insert sysAdmin;
    User salesExecUser;
    system.runAs(sysAdmin) {
      //create user
      salesExecUser = Test_Utils.createUser(Constants.PROFILE_EXP_SALES_EXEC);
      insert salesExecUser;
    }

    //create account
    Account testAcc = Test_Utils.insertAccount();
      
    Address__c addrs1 = Test_Utils.insertAddress(true);
    //insert account address
    Account_Address__c accAddrs = Test_Utils.insertAccountAddress(true, addrs1.Id, testAcc.Id);
        
    AccountTeamMember atm = new AccountTeamMember();
    atm.AccountId = testAcc.Id ;
    atm.UserId = salesExecUser.ID;
    atm.AccountAccessLevel = Constants.ACCESS_LEVEL_EDIT;
    atm.OpportunityAccessLevel = Constants.ACCESS_LEVEL_EDIT;
    atm.TeamMemberRole = Constants.TEAM_ROLE_SALES_REP;
    insert atm;

    //start test
    Test.startTest();
    system.runAs(salesExecUser) {
      List<Opportunity> testOpp = new List<Opportunity>();
      testOpp.add(Test_Utils.createOpportunity(testAcc.Id));
      testOpp.get(0).Amount = 100;
      insert testOpp;
    }
    Test.stopTest();

    //Assert to check opportunity has been created
    system.assertNotEquals([SELECT ID, AccountId FROM Opportunity WHERE AccountId =: testAcc.Id].ID, null);
  }

  static testMethod void testCheckAccessOnAccountFor_ManagerOfTeam() {
    //create set userRoleNameSet
    Set<String> userRoleNameSet = new Set<String>{SALES_EXEC_USER, MANAGER_USER};
    Map<String, UserRole> userRoleMap = new Map<String, UserRole>();

    for (UserRole role : [Select ID, Name from UserRole where UserRole.Name IN :userRoleNameSet]){
      userRoleMap.put(role.Name, role);
    }

    Map<String, User> userMap = new Map<String, User>();
    User sysAdmin = Test_Utils.createUser(Constants.PROFILE_SYS_ADMIN);
    insert sysAdmin;

    system.runAs(sysAdmin) {
      //create user

      User salesExecUser = Test_Utils.createUser(Constants.PROFILE_EXP_SALES_EXEC);
      salesExecUser.UserRoleId = userRoleMap.get(SALES_EXEC_USER).ID;
      userMap.put(SALES_EXEC_USER, salesExecUser);

      User managerUser = Test_Utils.createUser(Constants.PROFILE_EXP_SALES_EXEC);
      managerUser.UserRoleId = userRoleMap.get(MANAGER_USER).ID;
      userMap.put(MANAGER_USER, managerUser);
      insert userMap.values();
    }

    //create account
    Account testAcc = Test_Utils.insertAccount();
        
    Address__c addrs1 = Test_Utils.insertAddress(true);
    //insert account address
    Account_Address__c accAddrs = Test_Utils.insertAccountAddress(true, addrs1.Id, testAcc.Id);
       
    AccountTeamMember atm = new AccountTeamMember();
    atm.AccountId = testAcc.Id ;
    atm.UserId = userMap.get(SALES_EXEC_USER).ID;
    atm.AccountAccessLevel = Constants.ACCESS_LEVEL_EDIT;
    atm.OpportunityAccessLevel = Constants.ACCESS_LEVEL_EDIT;
    atm.TeamMemberRole = Constants.TEAM_ROLE_SALES_REP;
    insert atm;

    //start test
    Test.startTest();

    system.runAs(userMap.get(MANAGER_USER)) {
      List<Opportunity> testOpp = new List<Opportunity>();
      testOpp.add(Test_Utils.createOpportunity(testAcc.Id));
      testOpp.get(0).Amount = 100;
      insert testOpp;
    }

    Test.stopTest();

    //Assert to check opportunity has been created
    system.assertNotEquals([SELECT ID, AccountId FROM Opportunity WHERE AccountId =: testAcc.Id].ID, null);
  }

  static testMethod void testCheckAccessOnAccountFor_UserOnContact(){
    //Creating admin user
    User sysAdmin = Test_Utils.createUser(Constants.PROFILE_SYS_ADMIN);
    insert sysAdmin;
    User userOnContact;
    system.runAs(sysAdmin) {
      //create user
      userOnContact = Test_Utils.createUser(Constants.PROFILE_EXP_SALES_EXEC);
      insert userOnContact;
    }

    //create account
    Account testAcc = Test_Utils.insertAccount();
    Contact testContact = Test_Utils.insertContact(testAcc.ID);
    Contact_Team__c contTeam = new Contact_Team__c();
    contTeam.Contact__c = testContact.ID;
    contTeam.Primary_User__c = true;
    contTeam.Relationship_Owner__c = userOnContact.ID;
    insert contTeam;

    //start test
    Test.startTest();

    system.runAs(userOnContact) {
      try {
        List<Opportunity> testOpp = new List<Opportunity>();
        testOpp.add(Test_Utils.createOpportunity(testAcc.Id));
        testOpp.get(0).Amount = 100;
        insert testOpp;
      } 
      catch (Dmlexception ex) {
        system.assertNotEquals (String.valueOf(ex.getMessage()).contains('You do not have the necessary access'), true);
      }
    }

    Test.stopTest();

    List<Opportunity> opptyList = [SELECT ID, AccountId FROM Opportunity WHERE AccountId =: testAcc.Id];
    //Assert to check opportunity has been created
    system.assertEquals(opptyList.size() > 0, false);
  }

  static testMethod void testValidateServiceDates() {
    // create User
    Profile p = [select id from profile where name=: Constants.PROFILE_SYS_ADMIN ];
    User testUser1 = Test_Utils.createUser(p, 'test1234@experian.com', 'test1');
    insert testUser1;
    system.runAs(testUser1) {
      createTestData();
      List<OpportunityLineItem> resultOLIs = [select id , Start_Date__c from OpportunityLineItem where opportunityId = : opp.id and Start_Date__c != null];

      //validate for Service Start Date
      opp.Contract_Start_Date__c = Date.today().addDays(1);
      try {
        update opp;
      }
      catch (Exception ex) {
        system.assert(ex.getMessage().contains(System.Label.Service_Start_Date_Error_Msg));
      }
      opp.Contract_Start_Date__c = null;
      opp.Contract_End_Date__c = Date.today().addDays(10);
      try {
        update opp;
      }
      catch (Exception ex) {
        system.assert(ex.getMessage().contains(System.Label.Service_End_Date_Error_Msg));
      }
    }
  }

  private static void createTestData(){
    // Create an account
    Account testAccount = Test_Utils.insertAccount();
        
    Address__c addrs1 = Test_Utils.insertAddress(true);
      
    //insert account address
    Account_Address__c accAddrs = Test_Utils.insertAccountAddress(true, addrs1.Id, testAccount.Id);
        
    // Create an opportunity
    opp = Test_Utils.createOpportunity(testAccount.Id);
    opp.Has_Senior_Approval__c = true;
    //opp.Below_Review_Thresholds__c = 'Yes'; T-271695:Removed reference to Below_Review_Thresholds__c
    opp.Amount = 500;
    opp.Starting_Stage__c = Constants.OPPTY_STAGE_3;
    opp.Type = 'New From New';
    insert opp;

    Contact newcontact  = new Contact(
      FirstName = 'Larry',
      LastName = 'Ellison',
      AccountId = testAccount.Id,
      Email = 'larrye@email.com'
    );
    insert newcontact;

    //////////////////////
    // Create Opportunity Line Item
    Product2 product = Test_Utils.insertProduct();
    product.RevenueScheduleType = Constants.REVENUE_SCHEDULED_TYPE_REPEAT;
    product.RevenueInstallmentPeriod = Constants.INSTALLMENT_PERIOD_DAILY;
    product.NumberOfRevenueInstallments = 2;
    product.CanUseRevenueSchedule = true;

    update product;
    stdPricebookEntryObj = Test_Utils.insertPricebookEntry(product.Id, Test.getStandardPricebookId(), Constants.CURRENCY_USD);
    //insert OLI
    olis = new List<OpportunityLineItem>();
    olis.add(Test_Utils.createOpportunityLineItem(opp.Id, stdPricebookEntryObj.Id, opp.Type));
    olis.add(Test_Utils.createOpportunityLineItem(opp.Id, stdPricebookEntryObj.Id, opp.Type));
    olis.get(0).Start_Date__c = Date.today().addDays(-10);
    olis.get(0).End_Date__c = Date.today().addDays(10);
    olis.get(1).Start_Date__c = Date.today().addDays(-10);
    olis.get(1).End_Date__c = Date.today().addDays(10);
    insert olis;

  }

  //T-265681: Test method for multi-currency dashboard
  static testMethod void testMultiCurrencyFieldUpdate() {
    //create Account
    Account testAcc = Test_Utils.insertAccount();
    //create Opportunity
    Opportunity testOpp = Test_Utils.createOpportunity(testAcc.Id);
    testOpp.Amount = 1000;
    testOpp.CurrencyIsoCode ='GBP';
    testOpp.CloseDate = Date.today().addDays(7);
    insert testOpp;

    Test.startTest();

    Opportunity resultOpp = [
      SELECT ID, CloseDate, Amount, GBP_Conversion_Rate__c, AUD_Conversion_Rate__c, Amount_Corp__c
      FROM Opportunity 
      WHERE Id = :testOpp.Id
    ];
    Map<String, DatedConversionRate> dtConvRateMap = new Map<String, DatedConversionRate>();

    for (DatedConversionRate dcr : [SELECT ISOCode, ID, ConversionRate
                                    FROM DatedConversionRate
                                    WHERE StartDate < NEXT_N_DAYS:7 AND NextStartDate > NEXT_N_DAYS:7]) {
      dtConvRateMap.put(dcr.ISOCode, dcr);
    }

    system.debug('*****dtConvRateMap------------'+dtConvRateMap);
    system.assertEquals(dtConvRateMap.get('GBP').ConversionRate, resultOpp.GBP_Conversion_Rate__c);
    //system.assertEquals([], resultOpp.GBP_Conversion_Rate__c);
    system.assertEquals(dtConvRateMap.get('AUD').ConversionRate, resultOpp.AUD_Conversion_Rate__c);
    system.assertEquals(resultOpp.Amount_Corp__c, resultOpp.Amount / dtConvRateMap.get('GBP').ConversionRate);
    
    //update the currency on Opp
    testOpp.CurrencyIsoCode ='AUD';
    testOpp.CloseDate = Date.today().addDays(8);
    update testOpp;

    resultOpp = [SELECT ID, CloseDate, GBP_Conversion_Rate__c, AUD_Conversion_Rate__c, Amount_Corp__c, Amount FROM Opportunity WHERE Id =:testOpp.Id];

    // system.assertEquals(resultOpp.Amount_Corp__c, resultOpp.Amount / dtConvRateMap.get('AUD').ConversionRate);
    Test.stopTest();
  }

  //=========================================================================
  // Testing functionality of moveOriginatingTaskToNewOppty ()
  //=========================================================================
  static testMethod void test_moveOriginatingTaskToNewOppty () {
    // create User
    Profile p = [select id from profile where name=: Constants.PROFILE_SYS_ADMIN ];
    User testUser = Test_Utils.createUser(p, 'test1234@experian.com', 'test1');
    insert testUser;

    system.runAs(testUser){
      // insert account
      Account account = Test_Utils.insertAccount();
      //Insert Contact
      Contact testContact = Test_Utils.insertContact(account.ID);

      Id standardTaskRecId = [SELECT Id FROM RecordType WHERE SobjectType ='Task' and Name = 'Standard Task'].Id;

      List<Task> taskList = new List<Task>();
      Task newTask = new Task(
        ActivityDate = Date.today(),
        WhoId = testContact.Id
      );
      //newTask.RecordTypeId = standardTaskRecId;
      newTask.Status = 'Not Started';
      insert newTask;

      newTask = [SELECT ID, WhatID, WhoId, AccountId FROM Task WHERE ID =:newTask.Id];

      Test.startTest();
      
      Opportunity  testOppty = new Opportunity();
      testOppty.AccountId = account.Id;
      testOppty.Name = 'Test Opportunity';
      testOppty.CloseDate = date.today().addDays(2);
      testOppty.StageName = Constants.OPPTY_STAGE_3;
      testOppty.CurrencyIsoCode = 'USD';
      testOppty.Originating_Task_Id__c = newTask.ID;
      testOppty.Budget__c = 'Less than 1,000';
      testOppty.Type = 'New From New';
      testOppty.Capability__c = 'Application Processing';
      testOppty.Proposal_Type__c = 'Standard quote';
      testOppty.PO_Required__c = 'No';
      insert testOppty;

      Test.stopTest();

      Task resultTask = [SELECT ID, WhatID, WhoId, AccountId,Status FROM Task WHERE Id =:newTask.Id];

      //Tasks should have Opportunity ID newly created from task
      system.assertEquals(resultTask.WhatID, testOppty.ID);
      system.assertEquals(resultTask.Status, 'Completed'); //check if Task Status is now Completed
    }
  }

  static testMethod void testOnDemandOpportunityLineItem() {
    // create User
    Profile p = [select id from profile where name=: Constants.PROFILE_SYS_ADMIN ];
    User testUser1 = Test_Utils.createUser(p, 'test1234@experian.com', 'test1');
    insert testUser1;

    system.runAs(testUser1){
      // insert account without 'On Demand' contact
      Account acc = Test_Utils.insertAccount();
        
      Address__c addrs1 = Test_Utils.insertAddress(true);
      
      //insert account address
      Account_Address__c accAddrs = Test_Utils.insertAccountAddress(true, addrs1.Id, acc.Id);
        
      //Insert Contact
      Contact testContact = Test_Utils.createContact(acc.ID);
      testContact.Email = 'test1@experian.com';
      //testContact.EDQ_On_Demand__c = false;
      //testContact.Inactive__c = false;
      testContact.Title = 'Test';
      insert testContact;

      Test_Utils.insertContactAddress(true, addrs1.Id, testContact.Id);

      // insert opportunity
      Opportunity testOpp = Test_Utils.createOpportunity(acc.Id);
      testOpp.Type = 'New From New';
      insert testOpp;

      OpportunityContactRole oppContactRole =  Test_Utils.insertOpportunityContactRole(true, testOpp.Id, testContact.Id, Constants.DECIDER, true);

      // insert OpportunityLineItem with 'On Demand'
      Product2 product = Test_Utils.insertProduct();
      Product2 product1 = Test_Utils.insertProduct();
      
      
      PricebookEntry stdPricebookEntry = Test_Utils.insertPricebookEntry(product.Id, Test.getStandardPriceBookId(), Constants.CURRENCY_USD);
      PricebookEntry stdPricebookEntry1 = Test_Utils.insertPricebookEntry(product1.Id, Test.getStandardPriceBookId(), Constants.CURRENCY_USD);

      OpportunityLineItem opportunityLineItem = Test_Utils.createOpportunityLineItem(testOpp.Id, stdPricebookEntry1.Id, testOpp.Type);
      opportunityLineItem.EDQ_On_Demand_Product__c = true;
      opportunityLineItem.Part_Number__c = '113232';
      opportunityLineItem.CPQ_Quantity__c = 10;
      insert opportunityLineItem;

      Test.startTest();
      
      //update opp
      testOpp.StageName = Constants.OPPTY_STAGE_7;
      testOpp.Starting_Stage__c = Constants.OPPTY_STAGE_6;
      testOpp.Has_Senior_Approval__c = true;
      testOpp.Amount = 100;

      try{
        update testOpp;
      }
      catch (Exception ex) {
        system.assert(ex.getMessage().contains(Label.OPPTY_ERR_ONDEMAND_PRODUCT));
      }
      finally {
        List<Opportunity> oppty = [SELECT ID, StageName, AccountID,
                                   (SELECT Id, OpportunityId, EDQ_On_Demand_Product__c
                                    FROM OpportunityLineItems
                                    WHERE EDQ_On_Demand_Product__c = true)
                                 FROM Opportunity
                                 WHERE ID =: testOpp.Id ];
        system.assert(oppty.size() > 0);
        system.assertEquals(true, oppty.get(0).OpportunityLineItems.size() > 0);
      }
    }

    Test.stopTest();

  }  


 
  //Case 01973473
  static testMethod void testOpportunity_CountOfProductsForSurveys_Update() {
      
      //Create data start
      Account acc = Test_Utils.insertAccount();

      // insert opportunity
      Opportunity testOpp = Test_Utils.createOpportunity(acc.Id);
      testOpp.Type = 'New From New';
      insert testOpp;

      List<Opportunity> oppsList = new List<Opportunity>();
      oppsList.add(testOpp);
      
      CPQ_Settings__c  testCPQSetting = CPQ_Settings__c.getInstance('CPQ');
      if(testCPQSetting == null){
      testCPQSetting= new CPQ_Settings__c ();
         testCPQSetting.Name = 'CPQ';
         testCPQSetting.Company_Code__c= 'Experian';
         testCPQSetting.CPQ_API_Access_Word__c = 'Accessword';
         testCPQSetting.CPQ_API_Endpoint__c= 'https://test.webcomcpq.com/';
         testCPQSetting.CPQ_API_UserName__c= 'TestUser#Experian'; 
         testCPQSetting.CPQ_API_Host__c= 'test.com';
         testCPQSetting.Integration_Batchable_Time_Wait__c= 2;       
         insert testCPQSetting; 
      }else{
         testCPQSetting.Integration_Batchable_Time_Wait__c= 2;       
         update testCPQSetting;
      }
     
      //Create and associate products with Opportunity
      Product_Master__c productMaster = Test_Utils.createProductMaster(false);
      productMaster.Product_life_cycle__c = 'Development';
      productMaster.Name = 'Pro';
      insert productMaster;
      
      Set<String> productTypesForSurvey = new  Set<String>{'Capture','Clean','Email Validate'};
      List<String> productNamesList     = new List<String>{'Capture','Clean','Email Validate','Test'};
      List<String> deProductNamesList   = new List<String>{'Capture','Clean','Email Validation','Test'};

      List<Product2> product2List = new List<Product2>();
      
      Integer i=0;
      for(String productName : productNamesList){
        Product2 product2Item = Test_Utils.createProduct();
        product2Item.Name=productName;
        product2Item.DE_Product_Name__c = deProductNamesList[i];
        product2Item.Product_Master__c = productMaster.id;      
        product2List.add(product2Item);
        i++;
      }
      insert product2List;

      List<PricebookEntry> priceBookEntryList           = new List<PricebookEntry>();
      List<OpportunityLineItem> opportunityLineItemList = new List<OpportunityLineItem>();
      
      for(Product2 product2Item : product2List){
        PricebookEntry stdPricebookEntry = Test_Utils.createPricebookEntry(product2Item.Id, Test.getStandardPriceBookId(), Constants.CURRENCY_USD);
        priceBookEntryList.add(stdPriceBookEntry);
      }
      insert priceBookEntryList;
      
      for(PricebookEntry stdPricebookEntry : priceBookEntryList){
        OpportunityLineItem opportunityLineItem = Test_Utils.createOpportunityLineItem(testOpp.Id, stdPricebookEntry.Id, testOpp.Type);
        opportunityLineItemList.add(opportunityLineItem);
      }
      insert opportunityLineItemList;
      
      Map<ID, Opportunity> newMap = new Map<ID, Opportunity>(oppsList);
      
      //Create data end
      
      Test.startTest();

        OpportunityTriggerHandler.updateCountOfProductsForSurveys(newMap);
        
        for(Opportunity oppForProducts : OppsList){
          System.Assert(oppForProducts.Count_of_Products_for_Surveys__c > 0 , 'testOpportunity_CountOfProductsForSurveys_Update(): Count_of_Products_for_Surveys__c not updated. Value=' + oppForProducts.Count_of_Products_for_Surveys__c);
          
          System.Assert(oppForProducts.Count_of_Products_for_Surveys__c == productTypesForSurvey.size(), 'testOpportunity_CountOfProductsForSurveys_Update(): Count_of_Products_for_Surveys__c does not have the correct value. Correct Value = ' + productTypesForSurvey.size() + ' Current Value = ' + oppForProducts.Count_of_Products_for_Surveys__c + '.');
        }

      Test.stopTest();

  }  
    
    @IsTest static void updateOpptyContractDetailsTest(){
        Profile p = [SELECT Id FROM Profile WHERE Name=: Constants.PROFILE_SYS_ADMIN ];
        User testUser1 = Test_Utils.createUser(p, 'test1234@experian.com', 'test1');
        testUser1.Sales_Team__c='UK&I CS Insurance';
        testUser1.Business_Unit__c = 'UK&I Corparate';
        insert testUser1;
  
    system.runAs(testUser1) {
        
        // insert account without 'On Demand' contact
        Account acc = Test_Utils.insertAccount();
        
        Address__c address = Test_utils.insertAddress(True);
        Account_Address__c accAddrs = Test_Utils.insertAccountAddress(True,address.id,acc.id);
        //Insert Contact
        Contact testContact = Test_Utils.createContact(acc.ID);
      
       
        //testContact.SaaS__c = false;
        insert testContact;
  
                 
        Pricebook2 pricebook = new Pricebook2();
        pricebook.CurrencyIsoCode = Constants.CURRENCY_GBP;
        pricebook.IsActive = true;
        pricebook.Description = 'GBP currency iso code pricebook';
        pricebook.Name = 'GBP Pricebook';
        insert pricebook;

        // insert opportunity
        Opportunity testOpp = Test_Utils.createOpportunity(acc.Id);
        testOpp.Type = 'New From New';
        testOpp.OwnerId=testUser1.Id;        
        testOpp.CloseDate = date.today();
        testOpp.CurrencyIsoCode = Constants.CURRENCY_GBP;
        testOpp.Contract_Start_Date__c = date.today().addDays(1);
        testOpp.Contract_End_Date__c = date.today().addYears(1);
        insert testOpp;

        Product2 product = Test_Utils.createProduct();
        product.Simple_or_Complex__c = Constants.PRODUCT_COMPLEX;
        insert product;
    
    
        //Pricebook2 pricebook = Test_Utils.getPriceBook2();
            
         PricebookEntry stdPricebookEntry = Test_Utils.insertPricebookEntry(product.Id, Test.getStandardPricebookId(), Constants.CURRENCY_GBP);
         PricebookEntry newPricebookentry = Test_Utils.insertPricebookEntry(product.Id, pricebook.Id, Constants.CURRENCY_GBP);

         List<OpportunityLineItem> opptyLineItems = new List<OpportunityLineItem>();
         OpportunityLineItem opptyLineItem1 = new OpportunityLineItem();
         opptyLineItem1.OpportunityId = testOpp.ID;
         opptyLineItem1.Quantity = 1;
         opptyLineItem1.UnitPrice = 100;
         opptyLineItem1.PricebookEntryId = newPricebookentry.ID;
         opptyLineItem1.Start_Date__c = System.today();
         opptyLineItem1.End_Date__c = System.today().addDays(10);
         opptyLineItem1.Order_Type__c = Constants.STATUS_NEW;
            

            OpportunityLineItem opptyLineItem2 = new OpportunityLineItem();
            opptyLineItem2.OpportunityId = testOpp.ID;
            opptyLineItem2.Quantity = 1;
            opptyLineItem2.UnitPrice = 400;
            opptyLineItem2.PricebookEntryId = newPricebookentry.ID;
            opptyLineItem2.Start_Date__c = System.today();
            opptyLineItem2.End_Date__c = System.today().addDays(10);
            opptyLineItem2.Order_Type__c = Constants.STATUS_NEW;
            

            OpportunityLineItem opptyLineItem3 = new OpportunityLineItem();
            opptyLineItem3.OpportunityId = testOpp.ID;
            opptyLineItem3.Quantity = 1;
            opptyLineItem3.UnitPrice = 200;
            opptyLineItem3.PricebookEntryId = newPricebookentry.ID;
            opptyLineItem3.Start_Date__c = System.today();
            opptyLineItem3.End_Date__c = System.today().addDays(10);
            opptyLineItem3.Order_Type__c = Constants.STATUS_NEW;
            
            opptyLineItems.add(opptyLineItem1);
            opptyLineItems.add(opptyLineItem2);
            opptyLineItems.add(opptyLineItem3);

            insert opptyLineItems;

      Contract__c testCon = new Contract__c();
        testCon.Contract_Start_Date__c=date.today().addDays(1);
        testCon.Contract_End_Date__c = date.today().addYears(1);
        testCon.Original_Opportunity__c=testOpp.Id;
        
        insert testCon;

        Confidential_Information__c ci = new Confidential_Information__c(Opportunity__c=testOpp.id,Contract__c=testCon.Id);
        insert ci;
    
     
      testOpp.StageName = Constants.OPPTY_STAGE_7;
      testOpp.Starting_Stage__c = Constants.OPPTY_STAGE_6;      
      testOpp.CloseDate = date.today();      
      testOpp.Contract_Start_Date__c = date.today().addDays(11);
      testOpp.Contract_End_Date__c = date.today().addYears(2);
       testOpp.OwnerId=testUser1.Id;
        update testOpp;
        
         Opportunity oppToUpdate = [Select Id,Name,OwnerId,StageName,Owner_s_Business_Unit__c,Starting_Stage__c,CloseDate,CurrencyIsoCode,Company_Registration__c,Account_Billing_Country__c,Oppty_ID_18_chars__c,Contract__c,Contract_Start_Date__c,Contract_End_Date__c,Contract_Term__c,Owner_s_Country__c,(Select Id,Product2Id,Product2.Name,UnitPrice,Segment_Business_Line__c,Segment_Global_Line__c,Business_Line__c,Global_Business_Line__c From OpportunityLineItems) From Opportunity Where Id=:testOpp.Id LIMIT 1];
        Map<Id,Opportunity> closedWonOpps = new Map<Id,Opportunity>();
       closedWonOpps.put(oppToUpdate.Id,oppToUpdate);
      OpportunityTriggerHandler.updateOpptyContractDetails(closedWonOpps);
    }
  }

  // test method to check createOppTeamMembers()
  static testMethod void test_createOppTeamMembers() {
    // create User
    Profile p = [select id from profile where name=: Constants.PROFILE_SYS_ADMIN ];
    User testUser1 = Test_Utils.createUser(p, 'test1234@experian.com', 'test1');
    insert testUser1;

    system.runAs(testUser1) {
      // create user
      User testUser = Test_Utils.createUser(p, 'test1235@experian.com', 'test1');
      insert testUser;
      // create Account
      Account testAccount = Test_Utils.insertAccount();
      // create Account Team Member
      AccountTeamMember atm = Test_Utils.createAccountTeamMembers(testAccount.Id, testUser.Id, false);
      atm.TeamMemberRole = Constants.TEAM_ROLE_STRAT_ACCOUNT_MANAGER;
      insert atm;

      Test.startTest();

      Opportunity testOpp = Test_Utils.createOpportunity(testAccount.Id);
      insert testOpp;

      Test.stopTest();

      List<OpportunityTeamMember> otmLst = [
        SELECT Id, OpportunityId, UserId, TeamMemberRole 
        FROM OpportunityTeamMember
        WHERE OpportunityId =: testOpp.Id
      ];
      system.assert(otmLst.size() > 0);
    }
  }

  //==========================================================================================
  // T-366560: prevent close/winning SaaS opp if Account doesn't have any SaaS Contact
  //==========================================================================================
  static testMethod void testOpptyAccWithSaasContact() {
    // create User
    Profile p = [SELECT Id FROM Profile WHERE Name=: Constants.PROFILE_SYS_ADMIN ];
    User testUser1 = Test_Utils.createUser(p, 'test1234@experian.com', 'test1');
    insert testUser1;

    system.runAs(testUser1) {
      // insert account without 'On Demand' contact
      Account acc = Test_Utils.insertAccount();
      //Insert Contact
      Contact testContact = Test_Utils.createContact(acc.ID);
      //testContact.SaaS__c = false;
      insert testContact;

      Address__c address = Test_Utils.insertAddress(true);

      //insert account address
      Account_Address__c accAddrs = Test_Utils.insertAccountAddress(true, address.Id, acc.Id);

      Test_Utils.insertContactAddress(true, address.Id, testContact.Id);

      // insert opportunity
      Opportunity testOpp = Test_Utils.createOpportunity(acc.Id);
      testOpp.Type = 'New From New';
      insert testOpp;

      OpportunityContactRole oppContactRole =  Test_Utils.insertOpportunityContactRole(true, testOpp.Id, testContact.Id, Constants.DECIDER, true);

      // insert OpportunityLineItem with 'Saas'
      Product2 product = Test_Utils.insertProduct();

      PricebookEntry stdPricebookEntry = Test_Utils.insertPricebookEntry(product.Id, Test.getStandardPriceBookId(), Constants.CURRENCY_USD);

      OpportunityLineItem opportunityLineItem = Test_Utils.createOpportunityLineItem(testOpp.Id, stdPricebookEntry.Id, testOpp.Type);
      opportunityLineItem.SaaS__c = true;
      opportunityLineItem.SaaS_Product_Code__c = 'Test Saas Prod-1';
      opportunityLineItem.Start_Date__c = date.today().addDays(7);
      opportunityLineItem.End_Date__c = date.today().addDays(20);
      insert opportunityLineItem;

      Test.startTest();

      //update opp
      testOpp.StageName = Constants.OPPTY_STAGE_7;
      testOpp.Starting_Stage__c = Constants.OPPTY_STAGE_6;
      testOpp.Has_Senior_Approval__c = true;
      testOpp.Amount = 100;
      testOpp.CloseDate = date.today();
      testOpp.Contract_Start_Date__c = date.today().addDays(1);
      testOpp.Contract_End_Date__c = date.today().addYears(1);
      testOpp.Channel_Type__c = Constants.OPPTY_CHANNEL_TYPE_DIRECT;

      try {
        update testOpp;
      } 
      catch (Exception ex) {
        system.assert(ex.getMessage().contains(Label.SaaS_OPP_NEEDS_SAAS_CONTACTS));
      }
      Test.stopTest();
    }
  }
    
 
    @isTest static void testOpptyContractDatesUpdate(){
         Profile p = [SELECT Id FROM Profile WHERE Name=: Constants.PROFILE_SYS_ADMIN ];
        User testUser1 = Test_Utils.createUser(p, 'test1234@experian.com', 'test1');
        testUser1.Business_Unit__c = Constants.UK_I_MS_DATA_QUALITY;
        insert testUser1;
  
    
     // insert account without 'On Demand' contact
      Account acc = Test_Utils.insertAccount();
        
      Address__c address = Test_utils.insertAddress(True);
    Account_Address__c accAddrs = Test_Utils.insertAccountAddress(True,address.id,acc.id);
      //Insert Contact
      Contact testContact = Test_Utils.createContact(acc.ID);
      
       test.startTest();
      //testContact.SaaS__c = false;
      insert testContact;
  
      // insert opportunity
      Opportunity testOpp = Test_Utils.createOpportunity(acc.Id);
      testOpp.Type = 'New From New';
      testOpp.OwnerId = testUser1.Id;
      testOpp.CloseDate = date.today();
      testOpp.Contract_Start_Date__c = date.today().addDays(1);
      testOpp.Contract_End_Date__c = date.today().addYears(1);
      insert testOpp;

      Contract__c testCon = new Contract__c();
        testCon.Contract_Start_Date__c=date.today().addDays(1);
        testCon.Contract_End_Date__c = date.today().addYears(1);
        testCon.Original_Opportunity__c=testOpp.Id;
        
        insert testCon;
        
     Opportunity testOpp2 = [Select Id,StageName,Starting_Stage__c,Has_Senior_Approval__c,Amount,CloseDate,OwnerId,Contract_Start_Date__c,Contract_End_Date__c From Opportunity where id=:testOpp.Id LIMIT 1];
        
       
      testOpp2.StageName = Constants.OPPTY_STAGE_7;
      testOpp2.Starting_Stage__c = Constants.OPPTY_STAGE_6;
      testOpp2.Has_Senior_Approval__c = true;
      testOpp2.Amount = 100;
      testOpp2.CloseDate = date.today();
      testOpp2.OwnerId = testUser1.Id;
      testOpp2.Contract_Start_Date__c = date.today().addDays(11);
      testOpp2.Contract_End_Date__c = date.today().addYears(2);
       
        update testOpp2;
    test.stopTest();
    }

   //=========================================================================
  // Experian Sales Academy Test Cases BELOW
  //=========================================================================

  // T-273787 : test Update related Opp plans records on opportunity update
  static testMethod void testOppToOpportunityPlansSync(){
    
    // insert account
    Account account = Test_Utils.insertAccount();
    // insert opportunity

    // Create an opportunity
    Opportunity opportunity = Test_utils.createOpportunity(account.Id);
    opportunity.Budget__c = '1,000 - 10,000';
    insert opportunity;

    List<Opportunity_Plan__c> opporuntiyPlans = new List<Opportunity_Plan__c>();
    Opportunity_Plan__c oPlan = Test_Utils.insertOpportunityPlan(false, opportunity.id);
    oPlan.Opportunity_Client_Budget__c = '1,001 - 10,000';
    insert oPlan;

    oPlan.Opportunity_Client_Budget__c = 'Less than 1,000';
    update oPlan;

  }

  //==================================================================================================================//
  // Commented by: abose, 29th April, 2015- Main methods related to these are not found and a duplicate method exist
  // on class AccountPlanTriggerHandler_Test.createAccountPlanOppsTest() 
  /*
    static testMethod void testCreateAccountPlanOpportunities() {
        Test.startTest();
        // create User
        Profile p = [select id from profile where name=: Constants.PROFILE_SYS_ADMIN ];
        User testUser1 = Test_Utils.createUser(p, 'test1234@experian.com', 'test1');
        insert testUser1;

        System.runAs(testUser1){
          TriggerSettings__c insertTriggerSettings = Test_Utils.insertTriggerSettings(Constants.ACCOUNT_PLAN_OPPORTUNITY_TRIGGER);
          insertTriggerSettings = Test_Utils.insertTriggerSettings(Constants.ACCOUNT_PLAN_SWOT_TRIGGER);
          //IsDataAdmin__c isDateAdmin = Test_Utils.insertIsDataAdmin(false);
          IsDataAdmin__c dataAdmin = new IsDataAdmin__c();
          dataAdmin.SetupOwnerId = testUser1.id;
          dataAdmin.IsDataAdmin__c = false;
          insert dataAdmin;

          Account_Plan_Opportunity__c accountPlanOpp;
          // insert account
          Account account = Test_Utils.insertAccount();
          List<Account_Plan__c> accountPlanList = new List<Account_Plan__c>();
          // create account plan
          Account_Plan__c accountPlan = Test_Utils.insertAccountPlan(false, account.id);
          insert accountPlan;
          accountPlanList.add(accountPlan);
          // create account plan
          Account_Plan__c accountPlan1 = Test_Utils.insertAccountPlan(false, account.id);
          insert accountPlan1;
          accountPlanList.add(accountPlan1);

          List<Account_Plan_Opportunity__c> accountPlanOppList = [select id
                                                                  from Account_Plan_Opportunity__c
                                                                  where Account_Plan__c IN : accountPlanList];

          System.assertEquals(accountPlanOppList.size(), 0, 'No Account plan opps should be created as no opp association to account');

           // Create an opportunity
          Opportunity opp1 = Test_Utils.createOpportunity(account.Id);
          opp1.Has_Senior_Approval__c = true;
          opp1.StageName = Constants.OPPTY_STAGE_3;
          opp1.Amount = 500;
          opp1.Starting_Stage__c = Constants.OPPTY_STAGE_7;
          insert opp1;

          accountPlanOppList = [select id, Opportunity_Name__c, Current_Year_Revenue__c
                                 from Account_Plan_Opportunity__c
                                 where Account_Plan__c IN : accountPlanList];
          //No Account plan opps should be created as no opp association to account
          system.assertEquals(accountPlanOppList.size(), 0, 'creation of opp should have created 2 acc plan opp records');
        }
        Test.stopTest();
    }

/*
    static testMethod void testUpdateAccountPlanOpportunities() {
        Test.startTest();
        // create User
        Profile p = [select id from profile where name=: Constants.PROFILE_SYS_ADMIN ];
        User testUser1 = Test_Utils.createUser(p, 'test1234@experian.com', 'test1');
        insert testUser1;

        System.runAs(testUser1){
          TriggerSettings__c insertTriggerSettings = Test_Utils.insertTriggerSettings(Constants.ACCOUNT_PLAN_OPPORTUNITY_TRIGGER);
          insertTriggerSettings = Test_Utils.insertTriggerSettings(Constants.ACCOUNT_PLAN_SWOT_TRIGGER);
          //IsDataAdmin__c isDateAdmin = Test_Utils.insertIsDataAdmin(false);
          IsDataAdmin__c dataAdmin = new IsDataAdmin__c();
          dataAdmin.SetupOwnerId = testUser1.id;
          dataAdmin.IsDataAdmin__c = false;
          insert dataAdmin;

          Account_Plan_Opportunity__c accountPlanOpp;
          // insert account
          Account account = Test_Utils.insertAccount();
          List<Account_Plan__c> accountPlanList = new List<Account_Plan__c>();
          // create account plan
          Account_Plan__c accountPlan = Test_Utils.insertAccountPlan(false, account.id);
          //insert accountPlan;
          accountPlanList.add(accountPlan);
          // create account plan
          Account_Plan__c accountPlan1 = Test_Utils.insertAccountPlan(false, account.id);
          //insert accountPlan1;
          accountPlanList.add(accountPlan1);
          insert accountPlanList;
          
          List<Account_Plan_Opportunity__c> accountPlanOppList = [select id
                                                                  from Account_Plan_Opportunity__c
                                                                  where Account_Plan__c IN : accountPlanList];

          System.assertEquals(accountPlanOppList.size(), 0, 'No Account plan opps should be created as no opp association to account');

           // Create an opportunity
          Opportunity opp1 = Test_Utils.createOpportunity(account.Id);
          opp1.Has_Senior_Approval__c = true;
          opp1.StageName = Constants.OPPTY_STAGE_3;
          opp1.Amount = 500;
          opp1.Starting_Stage__c = Constants.OPPTY_STAGE_7;
          opp1.CurrencyIsoCode = Constants.CURRENCY_GBP;
          insert opp1;

          accountPlanOppList = [select id, Opportunity_Name__c, Current_Year_Revenue__c
                                 from Account_Plan_Opportunity__c
                                 where Account_Plan__c IN : accountPlanList];

          system.assertEquals(accountPlanOppList.size(), accountPlanList.size(), 'creation of opp should have created 2 acc plan opp records');

          for(Account_Plan_Opportunity__c accPlanOpportunity : accountPlanOppList){
            System.assertEquals(accPlanOpportunity.Opportunity_Name__c, opp1.Name, 'should match with opp1 name');
            System.assertEquals(accPlanOpportunity.Current_Year_Revenue__c, opp1.Amount, 'should match with opp1 amount');
          }

          // Create Opportunity Line itemn
            Product2 product = Test_Utils.insertProduct();
            product.RevenueScheduleType = Constants.REVENUE_SCHEDULED_TYPE_REPEAT;
              product.RevenueInstallmentPeriod = Constants.INSTALLMENT_PERIOD_WEEKLY;
              product.NumberOfRevenueInstallments = 2;
              product.CanUseRevenueSchedule = true;
              update product;

              // Create Opportunity Line itemn
          Product2 product1 = Test_Utils.insertProduct();

            //Pricebook2 pricebook = Test_Utils.getPriceBook2();
            //Pricebook2 standardPricebook = Test_Utils.getPriceBook2(Constants.STANDARD_PRICE_BOOK);
            PricebookEntry stdPricebookEntry = Test_Utils.insertPricebookEntry(product.Id, Test.getStandardPricebookId(), Constants.CURRENCY_GBP);
            PricebookEntry stdPricebookEntry1 = Test_Utils.insertPricebookEntry(product1.Id, Test.getStandardPricebookId(), Constants.CURRENCY_GBP);




            List<OpportunityLineItem> oppLineItemsToInsert = new List<OpportunityLineItem>();

            OpportunityLineItem opportunityLineItem = Test_Utils.createOpportunityLineItem(opp1.Id, stdPricebookEntry.Id, opp1.Type);
            opportunityLineItem.Start_Date__c = System.today();
            opportunityLineItem.End_Date__c = System.today().addDays(20);
            oppLineItemsToInsert.add(opportunityLineItem);

            OpportunityLineItem opportunityLineItem1 = Test_Utils.createOpportunityLineItem(opp1.Id, stdPricebookEntry1.Id, opp1.Type);
          opportunityLineItem1.Start_Date__c = System.today();
          opportunityLineItem1.End_Date__c = System.today().addDays(20);
          oppLineItemsToInsert.add(opportunityLineItem1);
          insert oppLineItemsToInsert;

          List<OpportunityLineItemSchedule> olsList = new List<OpportunityLineItemSchedule>();

          OpportunityLineItemSchedule ols = new OpportunityLineItemSchedule();
                    ols.ScheduleDate = date.today();
                    ols.opportunityLineItemID = opportunityLineItem.id;
                    ols.type = Constants.REVENUE_SCHEDULED_TYPE_REVENUE;
                    ols.Revenue = 50;
          olsList.add(ols);

          OpportunityLineItemSchedule ols0 = new OpportunityLineItemSchedule();
          ols0.ScheduleDate = date.today().addDays(10);
          ols0.opportunityLineItemID = opportunityLineItem.id;
          ols0.type = Constants.REVENUE_SCHEDULED_TYPE_REVENUE;
          ols0.Revenue = 50;
          olsList.add(ols0);

          OpportunityLineItemSchedule ols1 = new OpportunityLineItemSchedule();
          ols1.ScheduleDate = date.today().addYears(1);
          ols1.opportunityLineItemID = opportunityLineItem.id;
          ols1.type = Constants.REVENUE_SCHEDULED_TYPE_REVENUE;
          ols1.Revenue = 50;
           olsList.add(ols1);

          OpportunityLineItemSchedule ols2 = new OpportunityLineItemSchedule();
          ols2.ScheduleDate = date.today().addYears(2);
          ols2.opportunityLineItemID = opportunityLineItem.id;
          ols2.type = Constants.REVENUE_SCHEDULED_TYPE_REVENUE;
          ols2.Revenue = 50;
          olsList.add(ols2);

          insert  olsList;


          opp1 = [Select id, Amount, Name from Opportunity where id=: opp1.id];
          System.assertEquals(opportunityLineItem.TotalPrice.intValue() + opportunityLineItem1.TotalPrice.intValue(), opp1.Amount.intValue(), 'match');

          accountPlanOppList = [select id, Opportunity_Name__c, Current_Year_Revenue__c, Year_1_Revenue__c, Year_2_Revenue__c
                                 from Account_Plan_Opportunity__c
                                 where Account_Plan__c IN : accountPlanList];

          system.assertEquals(accountPlanOppList.size(), accountPlanList.size(), 'creation of opp should have updated 2 acc plan opp records');

          for(Account_Plan_Opportunity__c accPlanOpportunity : accountPlanOppList){
            System.assertEquals(accPlanOpportunity.Opportunity_Name__c, opp1.Name, 'should match with opp1 name');
            decimal currentYearRevenue = ols.Revenue + ols0.Revenue + opportunityLineItem1.TotalPrice;
            System.assertEquals(accPlanOpportunity.Current_Year_Revenue__c.intValue(), currentYearRevenue.intValue(), 'should match with current year revenue scheduled');
            System.assertEquals(accPlanOpportunity.Year_1_Revenue__c, ols1.Revenue, 'should match with year1 revenue scheduled');
            System.assertEquals(accPlanOpportunity.Year_2_Revenue__c, ols2.Revenue, 'should match with year2 revenue scheduled');
          }


        }
        Test.stopTest();
    } 
    */
  
  //========================================================================
  // As per T-373692
  //========================================================================
  static testMethod void testpopulateSalesTeamChannelAndRegion() {
    // create User
    
    Profile p = [SELECT Id FROM Profile WHERE Name=: Constants.PROFILE_SYS_ADMIN ];
    User testUser1 = Test_Utils.createUser(p, 'test1234@experian.com', 'test1');
    testUser1.Sales_Team__c = 'Test Value for Sales Team';
    testUser1.Sales_Sub_Team__c = 'Test Value For SubTeam';
    insert testUser1;
      
      Test.startTest();
    system.runAs(testUser1) {
      // insert account without 'On Demand' contact
      Account acc = Test_Utils.insertAccount();
      //Insert Contact
      Contact testContact = Test_Utils.createContact(acc.ID);
      //testContact.SaaS__c = false;
      insert testContact;
  
      // insert opportunity
      Opportunity testOpp = Test_Utils.createOpportunity(acc.Id);
      testOpp.Type = 'New From New';
      insert testOpp;
        
        Test.stopTest();
      testOpp = [SELECT Sales_Team_Channel__c, Sales_Sub_Team_Region__c FROM Opportunity WHERE ID =: testOpp.ID];
        
      system.assertEquals(testOpp.Sales_Team_Channel__c, testUser1.Sales_Team__c);
      system.assertEquals(testOpp.Sales_Sub_Team_Region__c, testUser1.Sales_Sub_Team__c);
    }
  }
    
  //**************************************************************************
  // Case #967382 - Adding checks for new account team members from opp owners 
  //**************************************************************************
  static testMethod void testUpdateAcntTeamWithOptOwner() {
    Profile p = [SELECT Id FROM Profile WHERE Name = :Constants.PROFILE_SYS_ADMIN ];
    User testUser1 = Test_Utils.createUser(p, 'test1234@experian.com', 'test1');
    //insert testUser1;
    User testUser2 = Test_Utils.createUser(p, 'test56@experian.com', 'test2');
    //insert testUser2;
    User testUser3 = Test_Utils.createUser(p, 'test78@experian.com', 'test2');
    insert new List<User>{testUser1,testUser2,testUser3};   
    
    
    system.runAs(testUser1) {
      Date tempDate = date.today();
      Account acc = Test_Utils.insertAccount();
      //Insert Contact
      Contact testContact = Test_Utils.createContact(acc.ID);
      insert testContact;
      Address__c address = Test_Utils.insertAddress(true);
      Test_Utils.insertContactAddress(true, address.Id, testContact.Id);
      // insert opportunity
      Opportunity testOpp = Test_Utils.createOpportunity(acc.Id);
      testOpp.Type = 'New From New';
      testOpp.Starting_Stage__c = Constants.OPPTY_STAGE_6;
      testOpp.Amount = 1000;
      testOpp.CloseDate = tempDate;
      testOpp.All_dates_based_on_Closed_Date__c = true;
      testOpp.Contract_Start_Date__c = testOpp.CloseDate.addDays(1);
      testOpp.Contract_End_Date__c = testOpp.CloseDate.addYears(1);
      insert testOpp;
    }
    
    Account testAcc1 = [SELECT Id, OwnerId FROM Account LIMIT 1];
    Opportunity testOpp1 = [SELECT Id, OwnerId FROM Opportunity LIMIT 1];
    
    Test.startTest();
      
    // add testuser2 to the account as a team member with delivery team role...
    AccountTeamMember atm1 = new AccountTeamMember(
      AccountId = testAcc1.Id,
      UserId = testUser2.Id,
      TeamMemberRole = Constants.TEAM_ROLE_DELIVERY_TEAM,
      AccountAccessLevel = Constants.ACCESS_LEVEL_EDIT,
      OpportunityAccessLevel = Constants.ACCESS_LEVEL_READ
    );
    insert atm1;
    
    OpportunityTriggerHandler.isAfterUpdateTriggerExecuted = false;
        
    testOpp1.OwnerId = testUser2.Id;
    update testOpp1;    
    
    OpportunityTriggerHandler.isAfterUpdateTriggerExecuted = false;
        
    testOpp1.OwnerId = testUser3.Id;
    update testOpp1;
    
    Test.stopTest();
    system.assertEquals(1,[SELECT COUNT() FROM AccountTeamMember WHERE AccountId = :testAcc1.Id AND UserId = :testUser2.Id AND TeamMemberRole = :Constants.TEAM_ROLE_DELIVERY_TEAM]);  
    
    system.assertEquals(1,[SELECT COUNT() FROM AccountTeamMember WHERE AccountId = :testAcc1.Id AND UserId = :testUser3.Id]);
    
  }
  
  //========================================================================
  //  As per CRM2:W-005375 -Added by Manoj
  //========================================================================
  static testMethod void testUpdatePartners() {
    
    Account acc = Test_Utils.insertAccount();
    Contact newContact = Test_Utils.createContact(acc.id);
    newContact.Decision_Maker__c = true;
    insert newContact;
        
    Account acc1 = Test_Utils.insertAccount();
    Contact newcontact1 = Test_Utils.insertContact(acc1.id);
    
    Address__c address = Test_utils.insertAddress(True);
    Account_Address__c accAddrs = Test_Utils.insertAccountAddress(True,address.id,acc1.id);
        
    Opportunity opty = Test_Utils.createOpportunity(acc.Id);
    opty.Business_Unit__c = 'NA MS Consumer Insights & Targeting';
    opty.Deal_Category__c = 'New Standard Product';
    insert opty;
        
    Partner objP=new Partner();
    objP.OpportunityId = opty.Id;
    objP.AccountToId = acc1.Id;
    objP.Role = 'Test';
    insert objP;
       
    Opportunity opty1 = Test_Utils.createOpportunity(acc.Id);
    opty1.Name = 'Test Opportunity123';
    opty1.StageName = 'Qualify';
    opty1.AccountId = acc.Id;
    opty1.CloseDate = system.today().addDays(30);
    opty1.Contract_Start_Date__c = system.today().addDays(10);
    opty1.Contract_End_Date__c = system.today().addDays(20);  
    insert opty1;   
    
    
    opty.StageName = 'Execute';
    opty.Type = 'Free Trial';
    opty.RollupConPrimaryTrue__c = true;    
    update opty;
    
    Map<ID, Opportunity> oldMap = new Map<ID, Opportunity>();
    oldMap.put(opty.Id,opty1);
    
    Test.startTest();
        
    Map<ID, Opportunity> newMap =new Map<ID, Opportunity>();
    newMap.put(opty.Id,opty);
    
    OpportunityTriggerHelper.updatePartnerAccountsFields(newMap,oldMap);
    OpportunityContactRole objContRole = new OpportunityContactRole();
    objContRole.ContactId = newContact.Id;
    objContRole.OpportunityId = opty.Id;
    insert objContRole;
        
    OpportunityTriggerHelper.updateContactRoleDecisionMaker(newMap);    

    OpportunityContactRole opCon=[select id,Role from OpportunityContactRole where id=:objContRole.Id];
    system.assertEquals(opCon.Role,Constants.DECIDER);
        
    Test.stopTest();
  }
  
  static testMethod void testAlignDates() {
    Test.starttest();
        Profile p = [SELECT Id FROM Profile WHERE Name = :Constants.PROFILE_SYS_ADMIN ];
        User testUser1 = Test_Utils.createUser(p, 'test1234@experian.com', 'test1');
        testUser1.CPQ_User__c=false;
        testUser1.EmployeeNumber='3566';
        insert testUser1;
        
        system.runAs(testUser1){
            Account acc = Test_Utils.insertAccount();
            Contact newContact = Test_Utils.insertContact(acc.id);
            system.assertEquals(testUser1.CPQ_User__c,false);
           
            Opportunity opty1=new Opportunity();
            opty1.Name='Test Opportunity123';
            opty1.StageName='Qualify';
            opty1.AccountId=acc.Id;
            opty1.CloseDate=system.today().addDays(5);
            opty1.Contract_Start_Date__c=system.today().addDays(6);
            opty1.Contract_End_Date__c=system.today().addDays(10);  
            //opty1.Align_Opportunity_Dates__c=true;
            opty1.OwnerId=testUser1.Id;
            insert opty1;           
            
            Product2 product = Test_Utils.insertProduct();
            product.RevenueScheduleType = Constants.REVENUE_SCHEDULED_TYPE_REPEAT;
            product.RevenueInstallmentPeriod = Constants.INSTALLMENT_PERIOD_WEEKLY;
            product.NumberOfRevenueInstallments = 2;
            product.CanUseRevenueSchedule = true;
            update product;
                  
            PricebookEntry stdPricebookEntry = Test_Utils.insertPricebookEntry(product.Id, Test.getStandardPriceBookId(), Constants.CURRENCY_USD);

            OpportunityLineItem opportunityLineItem1 = Test_Utils.createOpportunityLineItem(opty1.Id, stdPricebookEntry.Id, opty1.Type);
            insert opportunityLineItem1;
            
            opty1.CloseDate=opty1.CloseDate.addDays(5);
            //opty1.Align_Opportunity_Dates__c=true;
            update opty1; 
            
            Opportunity opty=new Opportunity();
            opty.Name='Test Opportunity123';
            opty.CloseDate=system.today().addDays(1);
            
            
            
            Map<ID, Opportunity> oldMap1=new Map<ID, Opportunity>();
            oldMap1.put(opty1.Id,opty);
            
            Map<ID, Opportunity> newMap1 =new Map<ID, Opportunity>();
            newMap1.put(opty1.Id,opty1);    
            
            OpportunityTriggerHandler.dateAlignmentRan = false;
            OpportunityTriggerHandler.alignDatebasedonCloseDate(newMap1,oldMap1);            
            
            Opportunity oppty=[select id,Align_Opportunity_Dates__c,Contract_Start_Date__c,Contract_End_Date__c,CloseDate from Opportunity where id=:opty1.Id];
            system.assertEquals(oppty.Contract_Start_Date__c,system.today().addDays(6));
            system.assertEquals(oppty.Contract_End_Date__c,system.today().addDays(10));
            //system.assertEquals(oppty.Align_Opportunity_Dates__c,true);
            
            OpportunityTriggerHandler.oppIdToDaysMap.put(opty1.Id, 10);
            
            OpportunityTriggerHandler.updateOppLineItems();
            
            OpportunityLineItem oplItem=[select id,Start_Date__c,End_Date__c from OpportunityLineItem where id=:opportunityLineItem1.Id];
            system.assertEquals(oplItem.Start_Date__c,system.today().addDays(5));
            system.assertEquals(oplItem.End_Date__c,system.today().addDays(15));
        }
        
    Test.stopTest();
  }

  @isTest
  public static void when_Opp_Owner_is_changed_CI_Share_should_be_changed(){
  
      //Bad practice selecting a random user could impact test results
      //List<User> listUsers = [Select Id, Name from User Where IsActive = True AND ID != :UserInfo.getUserId() AND Profile.UserLicense.Name='Salesforce' LIMIT 10];

      //User userTheChosenOne = listUsers[8];
      
      Profile p = [select id from profile where name=: Constants.PROFILE_SYS_ADMIN ];
    
      User userTheChosenOne = Test_Utils.createUser(p, 'test1234@experian.com', 'test1');
      insert userTheChosenOne ;
      
     
    
      User userTheChosenTwo = Test_Utils.createUser(p, 'testxyz@experian.com', 'test2');
      insert userTheChosenTwo ;
     
      Account acc = Test_Utils.insertAccount();
      
     
      Opportunity opp1 = Test_Utils.createOpportunity(acc.Id);
      opp1.OwnerId = userTheChosenTwo.id ;
      insert Opp1;

      List<Confidential_Information__c> listCI = new List<Confidential_Information__c>();

      Confidential_Information__c ci = new Confidential_Information__c
                                              (
                                                    Opportunity__c = opp1.Id,
                                                    OwnerId = opp1.OwnerId
                                              );
      insert ci;
      
      opportunity opp = [select id,ownerid,Owner.Name from opportunity limit 1];
      List<Confidential_Information__Share> listCIShare1 = [SELECT id, //UserOrGroup.Name, //Case 02426211
                                                              Parent.Opportunity__r.Name,
                                                              Parent.Opportunity__r.Owner.Name from Confidential_Information__Share
                                                              WHERE Parent.Opportunity__c = :opp.Id ];
      System.Debug('Before Count :' + listCIShare1.size());
      //for(Confidential_Information__Share cis : listCIShare1)//Commented out for Case 02426211
      //{
        //System.Debug(cis.Id + '; ' + cis.UserOrGroup.Name + '; ' + cis.Parent.Opportunity__r.Name + ' ; ' + cis.Parent.Opportunity__r.Owner.Name);
      //}

      System.debug('Old Owner: ' + opp.Owner.Name + ' ; New : ' + userTheChosenOne.Name);

       
      OpportunityTriggerHandler.isAfterUpdateTriggerExecuted = false;
  
      opp.OwnerId = userTheChosenOne.Id;
      update opp;
        
      List<Confidential_Information__Share> listCIShare2 = [SELECT id, //UserOrGroup.Name,  //Case 02426211
                                                            ParentID, Parent.Opportunity__r.Name, Parent.Opportunity__r.Owner.Name from Confidential_Information__Share
                                                            WHERE Parent.Opportunity__c = :opp.Id ];

      System.Debug('After Count :' + listCIShare2.size());

      //for(Confidential_Information__Share cis : listCIShare2)  //Case 02426211
      //{
      //  System.Debug(cis.Id + '; ' + cis.UserOrGroup.Name  + '; ' + cis.Parent.Opportunity__r.Name + ' ; ' + cis.Parent.Opportunity__r.Owner.Name);
      //}

      System.assertEquals(listCIShare2.size() - listCIShare1.size(),2);
  }

  private static String edqUserEmail = 'test1234edq@experian.com';

  private static void prepareData() {

    Profile p = [SELECT Id FROM Profile WHERE Name = :Constants.PROFILE_SYS_ADMIN];

    User me = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

    system.runAs(me) {
      User testUser1 = Test_Utils.createEDQUser(p, edqUserEmail, 'test1');
      insert testUser1;
    }

  }

  @isTest
  public static void when_opp_owner_is_changed_Sales_Team_Channel_should_be_updated(){

    /*List<User> listUsers = [SELECT ID, Name, Sales_Team__c FROM USER 
                                      WHERE IsActive = true 
                                      AND Sales_Team__c LIKE 'UK%'
                                      AND (NOT Business_Unit__c LIKE '%EDQ%')//Case 02398031 Exclude EDQ users.
                                            LIMIT 10];*/
    Profile p = [SELECT Id FROM Profile WHERE Name=: Constants.PROFILE_SYS_ADMIN ];
    User origOppOwner  = Test_Utils.createUser(p, 'test1234@experian.com', 'test1');
    origOppOwner.Sales_Team__c='UK&I CS Insurance';
    insert origOppOwner;
    
    Profile p2;
    User newOppOwner;
    
    Opportunity opp1;
    System.runAs(origOppOwner){
      Account acc = Test_Utils.insertAccount();

      opp1 = Test_Utils.createOpportunity(acc.Id);
      //opp1.OwnerId = listUsers[0].Id;
      insert Opp1;

      List<Opportunity> listOpp1 = [Select Id, Sales_Team_Channel__c from Opportunity WHERE ID =: Opp1.Id];

      String salesTeamChannel = listOpp1[0].Sales_Team_Channel__c;
      System.Debug('DEBUG: Opportunity - Sales_Team_Channel__c : ' + salesTeamChannel);
      
      //Case 15212272: JW Moved here to prevent mixed DML error.
      p2 = [SELECT Id FROM Profile WHERE Name=: Constants.PROFILE_SYS_ADMIN ];
      newOppOwner  = Test_Utils.createUser(p2, 'test1234@experian.com', 'test1');
      newOppOwner.Sales_Team__c='UK&I CS FS - Retail';
      insert newOppOwner;
      //JW Moved here to prevent mixed DML error.
    }
             
    OpportunityTriggerHandler.isBeforeUpdateTriggerExecuted = false;

    opp1.OwnerId = newOppOwner.Id;     
    update opp1;


    List<Opportunity> listOpp2 = [Select Id, Name, Owner.Name, Sales_Team_Channel__c 
                                        FROM Opportunity 
                                        WHERE ID =: Opp1.Id AND
                                              OwnerId =: newOppOwner.Id];

    System.Debug('DEBUG: Opportunity - Name, Sales_Team_Channel__c : ' + listOpp2[0].Name 
                                                + ' ; ' +  listOpp2[0].Sales_Team_Channel__c);

    System.assertEquals(newOppOwner.Sales_Team__c, listOpp2[0].Sales_Team_Channel__c);
  }


  @isTest
  public static void createSalesPlanningProcess_For_EDQ(){
    prepareData();
    
    User testUser1 = [SELECT Id FROM User WHERE Email = :edqUserEmail LIMIT 1];
    
    testUser1.Business_Unit__c = Constants.UK_I_MS_DATA_QUALITY;
    update testUser1;
    
    
    Account testAccount = Test_Utils.insertAccount();
    Address__c addrs1 = Test_Utils.insertAddress(true);
    Account_Address__c accAddrs = Test_Utils.insertAccountAddress(true, addrs1.Id, testAccount.Id);

      
    // Create an opportunity
    Opportunity testOpp1 = Test_Utils.createOpportunity(testAccount.Id);
    testOpp1.Has_Senior_Approval__c = true;
    testOpp1.StageName = Constants.OPPTY_STAGE_3;      
    testOpp1.Amount = 500;
    testOpp1.Starting_Stage__c = Constants.OPPTY_STAGE_6;
    testOpp1.OwnerId = testUser1.Id;
    testOpp1.Channel_Type__c = Constants.OPPTY_CHANNEL_TYPE_DIRECT;

    insert testOpp1;

    Order__c testOrder1 = new Order__c(Opportunity__c = testOpp1.Id);      
    insert testOrder1; //Order to be used for SPP
      
    Test.startTest();
      
      Contact newcontact  = new Contact (FirstName = 'Larry', LastName = 'Ellison', AccountId = testAccount.Id, Email = 'larrye@email.com', Title='Test'//Case 15212272
                                         );
      insert newcontact;
      Contact_Address__c conAdd = Test_Utils.insertContactAddress(true, Test_Utils.insertAddress(true).Id, newcontact.Id);
      //Test_Utils.createOpptyTasks(testOpp1.Id, true);
      
      Task newTask = new Task(WhatId = testOpp1.Id,whoId = newcontact.Id,Outcomes__c=Constants.ACTIVITY_TYPE_SELECTION_CONFIRMED, Status = Constants.STATUS_COMPLETED);
        insert newTask;

      OpportunityContactRole oppConRole1 =  Test_Utils.insertOpportunityContactRole(false, testOpp1.Id, newcontact.Id, Constants.DECIDER, true);
      OpportunityContactRole oppConRole2 = Test_Utils.insertOpportunityContactRole(false, testOpp1.Id, newcontact.Id, Constants.OPPTY_CONTACT_ROLE_PURCHASE_LEDGER, false);
      OpportunityContactRole oppConRole3 = Test_Utils.insertOpportunityContactRole(false, testOpp1.Id, newcontact.Id, Constants.OPPTY_CONTACT_ROLE_RENEWAL, false);
      OpportunityContactRole oppConRole4 = Test_Utils.insertOpportunityContactRole(false, testOpp1.Id, newcontact.Id, Constants.OPPTY_CONTACT_ROLE_UPDATE, false);
      OpportunityContactRole oppConRole5 = Test_Utils.insertOpportunityContactRole(false, testOpp1.Id, newcontact.Id, Constants.OPPTY_CONTACT_ROLE_COMMERCIAL, false);
      OpportunityContactRole oppConRole6 = Test_Utils.insertOpportunityContactRole(false, testOpp1.Id, newcontact.Id, Constants.OPPTY_CONTACT_ROLE_SHIPTO, false);
      OpportunityContactRole oppConRole7 = Test_Utils.insertOpportunityContactRole(false, testOpp1.Id, newcontact.Id, Constants.OPPTY_CONTACT_ROLE_CONTRACTUAL, false);

      insert new List<OpportunityContactRole>{oppConRole1,oppConRole2,oppConRole3,oppConRole4,oppConRole5,oppConRole6,oppConRole7};
      
      //code added 12/7/16
      
      List<Opportunity_Contact_Address__c> oppConAdds = new List<Opportunity_Contact_Address__c>();
      Opportunity_Contact_Address__c oppConAdd = new Opportunity_Contact_Address__c();
      oppConAdd.Opportunity__c= testOpp1.Id ;
      oppConAdd.Address__c = conAdd.Address__c;
      oppConAdd.Contact__c = newcontact.Id; //conLst.get(0).Id;
      oppConAdd.Role__c = Constants.OPPTY_CONTACT_ROLE_PURCHASE_LEDGER;
      oppConAdds.add( oppConAdd);

      Opportunity_Contact_Address__c oppConAdd1 = new Opportunity_Contact_Address__c();
      oppConAdd1.Opportunity__c= testOpp1.Id ;
      oppConAdd1.Address__c = conAdd.Address__c;
      oppConAdd1.Contact__c = newcontact.Id; //conLst.get(1).Id;
      oppConAdd1.Role__c = Constants.OPPTY_CONTACT_ROLE_RENEWAL;
      oppConAdds.add( oppConAdd1);

      Opportunity_Contact_Address__c oppConAdd2 = new Opportunity_Contact_Address__c();
      oppConAdd2.Opportunity__c= testOpp1.Id ;
      oppConAdd2.Address__c = conAdd.Address__c;
      oppConAdd2.Contact__c = newcontact.Id ; //conLst.get(2).Id;
      oppConAdd2.Role__c = Constants.OPPTY_CONTACT_ROLE_UPDATE;
      oppConAdds.add( oppConAdd2);

      Opportunity_Contact_Address__c oppConAdd3 = new Opportunity_Contact_Address__c();
      oppConAdd3.Opportunity__c= testOpp1.Id ;
      oppConAdd3.Address__c = conAdd.Address__c;
      oppConAdd3.Contact__c = newcontact.Id; //conLst.get(3).Id;
      oppConAdd3.Role__c = Constants.DECIDER;
      oppConAdds.add( oppConAdd3);

      Opportunity_Contact_Address__c oppConAdd4 = new Opportunity_Contact_Address__c();
      oppConAdd4.Opportunity__c= testOpp1.Id ;
      oppConAdd4.Address__c = conAdd.Address__c;
      oppConAdd4.Contact__c = newcontact.Id ; //conLst.get(0).Id;
      oppConAdd4.Role__c = Constants.OPPTY_CONTACT_ROLE_COMMERCIAL;
      oppConAdds.add( oppConAdd4);

      Opportunity_Contact_Address__c oppConAdd5 = new Opportunity_Contact_Address__c();
      oppConAdd5.Opportunity__c= testOpp1.Id ;
      oppConAdd5.Address__c = conAdd.Address__c;
      oppConAdd5.Contact__c = newcontact.Id; //conLst.get(1).Id;
      oppConAdd5.Role__c = Constants.OPPTY_CONTACT_ROLE_SHIPTO;
      oppConAdds.add( oppConAdd5);

      Opportunity_Contact_Address__c oppConAdd6 = new Opportunity_Contact_Address__c();
      oppConAdd6.Opportunity__c= testOpp1.Id ;
      oppConAdd6.Address__c = conAdd.Address__c;
      oppConAdd6.Contact__c = newcontact.Id; //conLst.get(2).Id;
      oppConAdd6.Role__c = Constants.OPPTY_CONTACT_ROLE_CONTRACTUAL;
      oppConAdds.add( oppConAdd6);

      insert oppConAdds;
     
      Product2 testProduct1         = Test_Utils.createProduct();
      testProduct1.Name             = 'Product Test 1';
      testProduct1.Business_Line__c = Constants.BUSINESSLINE_DATA_QUALITY;
      insert testProduct1;

      //Case 15592558 - Add another Product to increase coverage.
      Product2 testProduct2           = Test_Utils.createProduct();
      testProduct2.Name               = 'Product Test 2';
      testProduct2.Business_Line__c   = Constants.BUSINESSLINE_DATA_QUALITY;  
      testProduct2.DE_Product_Name__c = 'Professional Services';
      insert testProduct2;


      PricebookEntry stdPricebookEntry1 = Test_Utils.insertPricebookEntry(testProduct1.Id, Test.getStandardPricebookId(), Constants.CURRENCY_USD);

      OpportunityLineItem testOppLineItem1 = Test_utils.createOpportunityLineItem(testOpp1.Id, stdPricebookEntry1.Id , testOpp1.Type);
      testOppLineItem1.Start_Date__c = Date.today().addDays(5);
      testOppLineItem1.End_Date__c   = Date.today().addDays(120);
      
      PricebookEntry stdPricebookEntry2 = Test_Utils.insertPricebookEntry(testProduct2.Id, Test.getStandardPricebookId(), Constants.CURRENCY_USD);
      
      OpportunityLineItem testOppLineItem2 = Test_utils.createOpportunityLineItem(testOpp1.Id, stdPricebookEntry2.Id , testOpp1.Type);
      testOppLineItem2.Start_Date__c = Date.today().addDays(5);
      testOppLineItem2.End_Date__c   = Date.today().addDays(120);
      
      insert new List<OpportunityLineItem>{testOppLineItem1, testOppLineItem2};
      
            
      OpportunityTriggerHandler.isAfterUpdateTriggerExecuted = false;
      
      List<Opportunity> listOpp = [Select ID, Type, StageName from Opportunity where Id=: testOpp1.ID];  

      System.Debug('Before Type and StageName : ' + listOpp[0].Type + ', ' + listOpp[0].StageName);

      listOpp[0].Type              = Constants.OPPTY_TYPE_NEW_FROM_NEW;
      listOpp[0].StageName         = Constants.OPPTY_STAGE_7; //Execute
      listOpp[0].Starting_Stage__c = Constants.OPPTY_STAGE_6;

      System.Debug('After Type and StageName : ' + listOpp[0].Type + ', ' + listOpp[0].StageName);

      update listOpp;
      
      Test.stopTest();

      List<Sales_Planning_Process__c> listSPP = [Select ID, Order__c from Sales_Planning_Process__c where Opportunity__c = : listOpp[0].Id];

      System.Debug('Count SPP : ' + listSPP.size() );

      if(listSPP.size() > 0){
        System.Debug('SPP\'s order : ' + listSPP[0].Order__c);
      }

      //System.assertEquals(listSPP.size(), 3);//If all of the code has run successfully then three Sales_Planning_Process__c records should have been added to the Opportunity.

      
 
      list<Quote__c> quoteList  = new List<Quote__c>([Select id, Status_Change_Error_Message__c, Opportunity__r.id  From Quote__c u where Opportunity__r.id = :listOpp[0].Id]);

      for(Quote__c quote : quoteList){
          System.Debug('Quote - error message : ' + quote.Status_Change_Error_Message__c);          
      }

      listOpp = [Select ID, SyncCPQ__c, StageName from Opportunity where Id=: testOpp1.ID];
      if(listOpp.size() > 0){
        System.Debug('If CPQ Serivce call failed, SyncCPQ__c  : ' + listOpp[0].SyncCPQ__c);
      }
 
  }
  
  //Case 02074137
  private static testMethod void test_RenewalOpportunityTaskGeneration(){
  
   // create User
    Profile p = [select id from profile where name=:Constants.PROFILE_SYS_ADMIN];
    UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'APAC CS/DA' LIMIT 1]; 
    User testUser1 = Test_Utils.createUser(p, 'test1234@experian.com', 'test1');
    insert testUser1;
    
    system.runAs(testUser1) {
      
      testUser1.UserRoleId =  [SELECT Id FROM UserRole WHERE Name = 'APAC CS/DA' LIMIT 1].id;
      update testUser1;
    
      //testUser1 = [SELECT id, UserRoleId, UserRole.Name, Is_CS_DA_User__c FROM User WHERE id =:testUser1.id];
    
      //System.Assert(testUser1.Is_CS_DA_User__c, 'The user is not a CSDA User: ' + testUser1.UserRoleId + ' ' + testUser1.UserRole.Name + ' ' + testUser1.Is_CS_DA_User__c);
 
      
      Account testAccount = Test_Utils.insertAccount();
      Account testAccount2 = Test_Utils.insertAccount();
      testAccount2.Is_Competitor__c = true;
      update testAccount2;
    
      Contact newcontact  = Test_Utils.insertContact(testAccount.id);
      Address__c address = Test_Utils.insertAddress(true);
        
      Test_Utils.insertContactAddress(true, address.Id, newcontact.Id);

      Contact newcontact2  = Test_Utils.insertContact(testAccount.id);  
     
      // Create an opportunity
      /*Opportunity testOpp1 = Test_Utils.createOpportunity(testAccount.Id);
      testOpp1.Starting_Stage__c = Constants.OPPTY_STAGE_3;
      testOpp1.Type = Constants.OPPTY_NEW_FROM_NEW;
      insert testOpp1;*/
      
      Opportunity testOpp1 = new Opportunity(
      Name = 'Test Opportunity1',
      CloseDate = date.today().addDays(2),
      StageName = Constants.OPPTY_STAGE_3,
      AccountId = testAccount.Id,
      CurrencyIsoCode = 'USD',
      Type = Constants.OPPTY_TYPE_RENEWAL,
      Option_to_Terminate_Date__c = date.today().addDays(2)
      );
      insert testOpp1;
      
      
      Product2 product = Test_Utils.insertProduct();
      product.Business_Line__c = 'Software';
      update product;
      
      PricebookEntry stdPricebookEntry = Test_Utils.insertPricebookEntry(product.Id, Test.getStandardPriceBookId(), Constants.CURRENCY_USD);

      //insert OLI
      OpportunityLineItem opportunityLineItem1 = Test_Utils.createOpportunityLineItem(testOpp1.Id, stdPricebookEntry.Id, 'Renewable');
      opportunityLineItem1.Start_Date__c = Date.today().addDays(5);
      opportunityLineItem1.End_Date__c   = System.today().addDays(10);
      insert opportunityLineItem1;
      
      OpportunityContactRole ocrNew = new OpportunityContactRole();
      ocrNew.OpportunityId = testOpp1.Id;
      ocrNew.ContactId     = newContact.id;
      ocrNew.Role          = Constants.DECIDER;
      insert ocrNew;
      
              
      /*Task task1 =  Test_Utils.createTask(newcontact.id, testopp1.id);
      
      insert task1;
      
      task1.Outcomes__c = 'Quote delivered';
      task1.Status      = 'Completed';
      update task1;
      
      Competitor__c comp1 = new Competitor__c(
           Opportunity__c = testopp1.id,
           Account__c     = testaccount2.id
      );
      insert comp1;*/
            
      /*testOpp.Starting_Stage__c = Constants.OPPTY_STAGE_7;
      testOpp.Primary_Quote_has_been_Approved__c = true;
      
      update testOpp;*/
      
      //List<Opportunity> oppList = [SELECT id, Previous_Opportunity__c FROM Opportunity WHERE Previous_Opportunity__c=:testOpp.id LIMIT 1];
      
      //List<Opportunity> oppList = [SELECT id, Previous_Opportunity__c FROM Opportunity WHERE id=:testOpp.id LIMIT 1];
     
      //System.assert(!oppList.isEmpty(),'Follow-on Opportunity not created. ' + oppList.isEmpty());
      
      //Opportunity testOpp2 = Test_Utils.createOpportunity(testAccount.Id);
 
      OpportunityTriggerHandler.isBeforeUpdateTriggerExecuted = false;
      OpportunityTriggerHandler.isAfterInsertTriggerExecuted = false;
      OpportunityTriggerHandler.isBeforeInsertTriggerExecuted = false;      
      
      system.debug('(***testOpp1.Name is ' + testOpp1.Name);
      
    Opportunity testOpp2 = new Opportunity(
      Name = 'Test Opportunity2',
      CloseDate = date.today().addDays(2),
      StageName = Constants.OPPTY_STAGE_3,
      AccountId = testAccount.Id,
      CurrencyIsoCode = 'USD',
      Type = Constants.OPPTY_TYPE_RENEWAL,
      Previous_Opportunity__c = testOpp1.id
     
    );
            Test.startTest();
      
      //testOpp2.Starting_Stage__c = Constants.OPPTY_STAGE_3;
      //testOpp2.Type = Constants.OPPTY_TYPE_RENEWAL;
      //testOpp2.Previous_Opportunity__c = oppList[0].id;
      insert testOpp2;
            
      //testOpp2 = [SELECT id, Type, Previous_Opportunity__c FROM Opportunity WHERE id =:testOpp2.id];      
      //testOpp2.Starting_Stage__c = Constants.OPPTY_STAGE_3;
      
      OpportunityTriggerHandler.isBeforeUpdateTriggerExecuted = false;
      OpportunityTriggerHandler.isAfterInsertTriggerExecuted = false;
      OpportunityTriggerHandler.isAfterUpdateTriggerExecuted = false;
      OpportunityTriggerHandler.isBeforeInsertTriggerExecuted = false;
      

      //testOpp2 = [SELECT id, Type, Previous_Opportunity__c, Option_to_Terminate__c FROM Opportunity WHERE id =:testOpp2.id];      
      testOpp2.Option_to_Terminate__c = true;
      testOpp2.Option_to_Terminate_Date__c = date.today().addDays(2);
      
      update testOpp2;
      
      //System.assert([SELECT id, Type, Previous_Opportunity__c, Option_to_Terminate__c FROM Opportunity WHERE id =:testOpp2.id].Option_to_Terminate__c==true, 'Option to Terminate is true.');
      Test.stopTest();
      
      //System.assert(testOpp2.Account.Id == testAccount.Id, 'Opp does not have an Account' + testAccount.id + ' ' + testOpp.id);
      //System.assert(testOpp2.Type == Constants.OPPTY_TYPE_RENEWAL, 'Opp not a renewal ' + testOpp2.Type);
      //System.assert(testOpp2.Previous_Opportunity__c != testOpp.id, 'Follow on does not have a parent.' + testOpp2.Previous_Opportunity__c);      
   }
  
  }
  
  
   static testMethod void opportunityDPAutoRenewal(){
    // create User
    Profile p = [select id from profile where name=: Constants.PROFILE_SYS_ADMIN ];
    
    User testUser1 = Test_Utils.createUser(p, 'test1234@experian.com', 'test1');
    testuser1.business_unit__c='APAC CS SEA';
    insert testUser1;

    Account testAccount = Test_Utils.createAccount();
    testAccount.DP_RefNo__c='ABC123';
    insert testAccount;
    Contact newcontact  = Test_Utils.insertContact(testAccount.id);
    Address__c address = Test_Utils.insertAddress(true);
        
    //insert account address
    Account_Address__c accAddrs = Test_Utils.insertAccountAddress(true, address.Id, testAccount.Id);

    Test_Utils.insertContactAddress(true, address.Id, newcontact.Id);

    Contact newcontact2  = Test_Utils.insertContact(testAccount.id);

    Test_Utils.insertContactAddress(true, address.Id, newcontact2.Id);
 
 
    system.runAs(testUser1) {
    // Create an opportunity
    Opportunity testOpp = Test_Utils.createOpportunity(testAccount.Id);
    testOpp.Starting_Stage__c = Constants.OPPTY_STAGE_6;
    testOpp.Type = Constants.OPPTY_NEW_FROM_NEW;
    insert testOpp;

    OpportunityContactRole oppContactRole = Test_Utils.insertOpportunityContactRole(true, testOpp.Id, newcontact.Id, Constants.DECIDER, true);
    OpportunityContactRole oppContactRole2 = Test_Utils.insertOpportunityContactRole(true, testOpp.Id, newcontact2.Id, 'Admin Contact', false);
    OpportunityContactRole oppContactRole3 = Test_Utils.insertOpportunityContactRole(true, testOpp.Id, newcontact2.Id, 'Bill-To' ,false);

    Product2 product = Test_Utils.insertProduct();
    //Pricebook2 pricebook = Test_Utils.getPriceBook2();
    //Pricebook2 standardPricebook = Test_Utils.getPriceBook2(Constants.STANDARD_PRICE_BOOK);
    PricebookEntry stdPricebookEntry = Test_Utils.insertPricebookEntry(product.Id, Test.getStandardPriceBookId(), Constants.CURRENCY_USD);

    //insert OLI
    OpportunityLineItem opportunityLineItem1 = Test_Utils.createOpportunityLineItem(testOpp.Id, stdPricebookEntry.Id, testOpp.Type);
    opportunityLineItem1.Start_Date__c = Date.today().addDays(5);
    opportunityLineItem1.End_Date__c = System.today().addDays(10);
    opportunityLineItem1.auto_renew__c=true;
    insert opportunityLineItem1;
        
    Test.startTest();

    
      //update the Standard Opp
      
      opportunity testoppupd = [select id,Owner_s_Business_Unit__c, stagename,Auto_Renew_Count__c from opportunity where id = : testopp.id];
      
      testoppupd.StageName = Constants.OPPTY_STAGE_7;
     
      opportunitytriggerhandler.isAfterUpdateTriggerExecuted = false;
      
      update testoppupd ;
      
    }
    Test.stopTest();
  }
  
  
  //MM 02339030
  static testMethod void testCreateNextStepTasks(){
  
    Profile p = [SELECT Id FROM Profile WHERE Name=: Constants.PROFILE_SYS_ADMIN ];
    User testUser1 = Test_Utils.createUser(p, 'test1234@experian.com', 'test1');
    insert testUser1;

    Account testAccount = Test_Utils.insertAccount();
    Contact newcontact  = Test_Utils.insertContact(testAccount.id);
    Address__c address = Test_Utils.insertAddress(true);
        
    //insert account address
    Account_Address__c accAddrs = Test_Utils.insertAccountAddress(true, address.Id, testAccount.Id);

    Test_Utils.insertContactAddress(true, address.Id, newcontact.Id);

    // Create an opportunity
    Opportunity testOpp = Test_Utils.createOpportunity(testAccount.Id);
    testOpp.nextStep = 'test next step';
    
    Test.startTest();
    insert testOpp;
    
    OpportunityContactRole crole = new OpportunityContactRole();
    crole.OpportunityId = testOpp.id;
    crole.ContactId = newcontact.Id;
    crole.Role = Constants.DECIDER;
    insert crole;
    
    testOpp.nextStep = 'test next step1';
    update testOpp;
    OpportunityTriggerHandler.createNextStepTasksFuture(new set<Id>{testOpp.Id});
    Test.stopTest();
    
    List<Task> tasks = [select id, whatId, type from task where whatId = :testOpp.id and type = 'Next Step'];
    System.assertEquals(tasks.size(), 2);
  
  }
  
  private static testmethod void test_ExperianOneProductProcessing(){
    
    RecordType confInfoOppRT = [SELECT Id,Name FROM RecordType WHERE SObjectType =: Constants.SOBJECT_CONFIDENTIAL_INFO
                                               AND Name =: Constants.RECORDTYPE_CONF_INFO_OPPTY LIMIT 1];
    
    //1. Create Opportunity.    
    Profile p = [select id from profile where name=: Constants.PROFILE_SYS_ADMIN ];
    
    User testUser1 = Test_Utils.createUser(p, 'test1234@experian.com', 'test1');
    insert testUser1;

    Account testAccount = Test_Utils.createAccount();
    insert testAccount;
    Contact newcontact  = Test_Utils.insertContact(testAccount.id);//Needs to have a User Business_Unit__c of NA DA?
    Address__c address = Test_Utils.insertAddress(true);
        
     //insert account address
    Account_Address__c accAddrs = Test_Utils.insertAccountAddress(true, address.Id, testAccount.Id);
    Test_Utils.insertContactAddress(true, address.Id, newcontact.Id);

    Contact newcontact2  = Test_Utils.insertContact(testAccount.id);
    Test_Utils.insertContactAddress(true, address.Id, newcontact2.Id);
 
    Opportunity testOpp;
    OpportunityContactRole oppContactRole1;
    
    Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
    update standardPricebook;
    
    CPQ_Settings__c  testCPQSetting = CPQ_Settings__c.getInstance('CPQ');
     if(testCPQSetting == null){
     testCPQSetting= new CPQ_Settings__c ();
         testCPQSetting.Name = 'CPQ';
         testCPQSetting.Company_Code__c= 'Experian';
         testCPQSetting.CPQ_API_Access_Word__c = 'Accessword';
         testCPQSetting.CPQ_API_Endpoint__c= 'https://test.webcomcpq.com/';
         testCPQSetting.CPQ_API_UserName__c= 'TestUser#Experian'; 
         testCPQSetting.CPQ_API_Host__c= 'test.com';
         testCPQSetting.Integration_Batchable_Time_Wait__c= 2;       
         insert testCPQSetting; 
     }else{
         testCPQSetting.Integration_Batchable_Time_Wait__c= 2;       
         update testCPQSetting;
     }
     
    system.runAs(testUser1) {
      // Create an opportunity
      testOpp                   = Test_Utils.createOpportunity(testAccount.Id);
      testOpp.Starting_Stage__c = Constants.OPPTY_STAGE_3;
      testOpp.StageName         = Constants.OPPTY_STAGE_3;
      testOpp.Type              = Constants.OPPTY_NEW_FROM_NEW;
      testOpp.Conflict_of_Interest__c = 'No';
      insert testOpp;

      oppContactRole1 = Test_Utils.insertOpportunityContactRole(true, testOpp.Id, newcontact2.Id, 'User', true);
    }
     
      //2. Add Experian One Product.
      Product_Master__c expOne_ProductMaster      = Test_Utils.createProductMaster(false);
      expOne_ProductMaster.Name                   = 'Experian One - Test';
      expOne_ProductMaster.Product_Name__c        = 'Experian One - Test';
      expOne_ProductMaster.Product_Master_Name__c = 'Experian One';
      expOne_ProductMaster.SNOW_ProductID__c      = '12345678';
      insert expOne_ProductMaster;
            
      Product2 expOne_Product          = Test_Utils.createProduct();
      expOne_Product.Product_Master__c = expOne_ProductMaster.Id;
      insert expOne_Product;
      
      //Pricebook2 pricebook = Test_Utils.getPriceBook2();
      //Pricebook2 standardPricebook = Test_Utils.getPriceBook2(Constants.STANDARD_PRICE_BOOK);
      PricebookEntry stdPricebookEntry = Test_Utils.insertPricebookEntry(expOne_Product.Id, Test.getStandardPriceBookId(), Constants.CURRENCY_USD);
    Test.startTest();
    //insert OLI
      OpportunityLineItem opportunityLineItem1 = Test_Utils.createOpportunityLineItem(testOpp.Id, stdPricebookEntry.Id, testOpp.Type);
      opportunityLineItem1.Start_Date__c = Date.today().addDays(5);
      opportunityLineItem1.End_Date__c = System.today().addDays(10);
      opportunityLineItem1.auto_renew__c=true;
      insert opportunityLineItem1;
    
    String expectedMessage = 'Experian One Product';
    
    OpportunityTriggerHandler.isBeforeUpdateTriggerExecuted = false;
    OpportunityTriggerHandler.isAfterUpdateTriggerExecuted = false;
    
    system.debug('Start test MR:::::' +  Limits.getQueries());
    
      //3. Try to close Opportunity - Assertion to make sure that validation error message displays.
      testOpp.StageName = Constants.OPPTY_STAGE_7;
      try{
        update testOpp;    
      } catch(Exception e){
        system.assert(e.getMessage().contains(expectedMessage), 'message=' + e.getMessage());//Validation to ensure that the user adds a Confidential Information record with a .pdf file attached.
      }
      system.debug('First Opp Ex MR:::::' +  Limits.getQueries());   
      //4. Add CI record with correct Document Type.
      Confidential_Information__c conInfo       = new Confidential_Information__c ();
      conInfo.Opportunity__c                    = testOpp.Id;
      conInfo.Document_Type__c                  ='DA SaaS Document';
      //conInfo.Synch_Opportunity_Team_Members__c = false;
      conInfo.RecordTypeId                      = confInfoOppRT.Id;
      conInfo.Account__c                        = testAccount.Id;
      conInfo.Ownerid                           = testUser1.Id;
      insert conInfo;
            
      //5. Add PDF Attachment to CI record.
      Attachment ssd_File = new Attachment(ParentId = conInfo.Id, Body = Blob.valueOf('TEST'), Name = 'Attachment.pdf');
      insert ssd_File;
      
      //6. Assert that CI record Id has been saved to Opp.
      system.assert([SELECT Id, Conf_Info_Id_for_SSD_PDF_Attachment__c FROM Opportunity WHERE Id = :testOpp.Id].Conf_Info_Id_for_SSD_PDF_Attachment__c!=null, 'Opportunity.Conf_Info_Id_for_SSD_PDF_Attachment__c value has not been populated.');
      
      //7. Change Document type of CI Record.
      //conInfo.Document_Type__c ='';
      //update conInfo;
      
      //8. Assert that CI record Id has been deleted from Opp.
      //system.assert([SELECT Id, Conf_Info_Id_for_SSD_PDF_Attachment__c FROM Opportunity WHERE Id = :testOpp.Id].Conf_Info_Id_for_SSD_PDF_Attachment__c==null, 'Opportunity.Conf_Info_Id_for_SSD_PDF_Attachment__c value is still populated.');    
      
      //9. Change Document Type of CI Record back.
      conInfo.Document_Type__c ='DA SaaS Document';
      update conInfo;
      
      //10. Assert that the CI record Id has been saved back to the Opp.
      system.assert([SELECT Id, Conf_Info_Id_for_SSD_PDF_Attachment__c FROM Opportunity WHERE Id = :testOpp.Id].Conf_Info_Id_for_SSD_PDF_Attachment__c!=null, 'Opportunity.Conf_Info_Id_for_SSD_PDF_Attachment__c value has not been repopulated.');
            
      //11. Change the filename postfix of Attachment so that it is not a .PDF file.
      //ssd_File.Name = 'Attachment.txt';
      //update ssd_File;
       //system.debug('middle MR::::::' +  Limits.getQueries());    
      //12. Assert that the CI record Id has been deleted from Opp.
      //system.assert([SELECT Id, Conf_Info_Id_for_SSD_PDF_Attachment__c FROM Opportunity WHERE Id = :testOpp.Id].Conf_Info_Id_for_SSD_PDF_Attachment__c==null, 'Opportunity.Conf_Info_Id_for_SSD_PDF_Attachment__c value is still populated.');          
    
      //13. Change the filename postfix of the Attachment back to .PDF.
      //ssd_File.Name = 'Attachment.pdf';
      //update ssd_File;
      
      //14. Assert that the CI record Id has been saved back to the Opp.
      //system.assert([SELECT Id, Conf_Info_Id_for_SSD_PDF_Attachment__c FROM Opportunity WHERE Id = :testOpp.Id].Conf_Info_Id_for_SSD_PDF_Attachment__c!=null, 'Opportunity.Conf_Info_Id_for_SSD_PDF_Attachment__c value has not been repopulated.');
            
      //15. Delete the Attachment and assertion for CI record Id.
      //delete ssd_File;
      //system.assert([SELECT Id, Conf_Info_Id_for_SSD_PDF_Attachment__c FROM Opportunity WHERE Id = :testOpp.Id].Conf_Info_Id_for_SSD_PDF_Attachment__c==null, 'Opportunity.Conf_Info_Id_for_SSD_PDF_Attachment__c value is still populated.');              
      
      //16. Delete the CI record and assertion for CI record Id.
      //Attachment ssd_File2 = new Attachment(ParentId = conInfo.Id, Body = Blob.valueOf('TEST'), Name = 'Attachment.pdf');
      //insert ssd_File2;
      
      delete conInfo;
      system.assert([SELECT Id, Conf_Info_Id_for_SSD_PDF_Attachment__c FROM Opportunity WHERE Id = :testOpp.Id].Conf_Info_Id_for_SSD_PDF_Attachment__c==null, 'Opportunity.Conf_Info_Id_for_SSD_PDF_Attachment__c value is still populated.');              
       system.debug('last MR::::::' +  Limits.getQueries());      
     Test.stoptest();
  
  }
    
  
  
  private static testmethod void test_ExperianOneProductProcessingPART2(){
    
    /*RecordType confInfoOppRT = [SELECT Id,Name FROM RecordType WHERE SObjectType =: Constants.SOBJECT_CONFIDENTIAL_INFO
                                               AND Name =: Constants.RECORDTYPE_CONF_INFO_OPPTY LIMIT 1];*/
    
    Id confInfoOppRTId = Schema.SObjectType.Confidential_Information__c.getRecordTypeInfosByName().get('Confidential Information - Opportunity').getRecordTypeId();
    //1. Create Opportunity.    
    Profile p = [select id from profile where name=: Constants.PROFILE_SYS_ADMIN ];
    
    User testUser1 = Test_Utils.createUser(p, 'test1234@experian.com', 'test1');
    insert testUser1;

    Account testAccount = Test_Utils.createAccount();
    insert testAccount;
    Contact newcontact  = Test_Utils.createContact(testAccount.id);//Needs to have a User Business_Unit__c of NA DA?
    Address__c address = Test_Utils.insertAddress(true);
        
     //insert account address
    Account_Address__c accAddrs = Test_Utils.insertAccountAddress(true, address.Id, testAccount.Id);
    

    Contact newcontact2  = Test_Utils.createContact(testAccount.id);
    insert new List<Contact>{newcontact, newcontact2};
    Contact_Address__c ca1 = Test_Utils.insertContactAddress(false, address.Id, newcontact.Id);
    Contact_Address__c ca2 = Test_Utils.insertContactAddress(false, address.Id, newcontact2.Id);
    insert new List<Contact_Address__c>{ca1,ca2};
 
    Opportunity testOpp;
    OpportunityContactRole oppContactRole1;
    
    Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
    update standardPricebook;

    
    CPQ_Settings__c  testCPQSetting = CPQ_Settings__c.getInstance('CPQ');
     if(testCPQSetting == null){
     testCPQSetting= new CPQ_Settings__c ();
         testCPQSetting.Name = 'CPQ';
         testCPQSetting.Company_Code__c= 'Experian';
         testCPQSetting.CPQ_API_Access_Word__c = 'Accessword';
         testCPQSetting.CPQ_API_Endpoint__c= 'https://test.webcomcpq.com/';
         testCPQSetting.CPQ_API_UserName__c= 'TestUser#Experian'; 
         testCPQSetting.CPQ_API_Host__c= 'test.com';
         testCPQSetting.Integration_Batchable_Time_Wait__c= 2;       
         insert testCPQSetting; 
     }else{
         testCPQSetting.Integration_Batchable_Time_Wait__c= 2;       
         update testCPQSetting;
     }
     
    system.runAs(testUser1) {
      // Create an opportunity
      testOpp                   = Test_Utils.createOpportunity(testAccount.Id);
      testOpp.Starting_Stage__c = Constants.OPPTY_STAGE_3;
      testOpp.StageName         = Constants.OPPTY_STAGE_3;
      testOpp.Type              = Constants.OPPTY_NEW_FROM_NEW;
      testOpp.Conflict_of_Interest__c = 'No';
      insert testOpp;

      oppContactRole1 = Test_Utils.insertOpportunityContactRole(true, testOpp.Id, newcontact2.Id, 'User', true);
    }
     
      //2. Add Experian One Product.
      Product_Master__c expOne_ProductMaster      = Test_Utils.createProductMaster(false);
      expOne_ProductMaster.Name                   = 'Experian One - Test';
      expOne_ProductMaster.Product_Name__c        = 'Experian One - Test';
      expOne_ProductMaster.Product_Master_Name__c = 'Experian One';
      expOne_ProductMaster.SNOW_ProductID__c      = '12345678';
      insert expOne_ProductMaster;
            
      Product2 expOne_Product          = Test_Utils.createProduct();
      expOne_Product.Product_Master__c = expOne_ProductMaster.Id;
      insert expOne_Product;
      
      //Pricebook2 pricebook = Test_Utils.getPriceBook2();
      //Pricebook2 standardPricebook = Test_Utils.getPriceBook2(Constants.STANDARD_PRICE_BOOK);
      PricebookEntry stdPricebookEntry = Test_Utils.insertPricebookEntry(expOne_Product.Id, Test.getStandardPriceBookId(), Constants.CURRENCY_USD);
    Test.startTest(); 
      //insert OLI
      OpportunityLineItem opportunityLineItem1 = Test_Utils.createOpportunityLineItem(testOpp.Id, stdPricebookEntry.Id, testOpp.Type);
      opportunityLineItem1.Start_Date__c = Date.today().addDays(5);
      opportunityLineItem1.End_Date__c = System.today().addDays(10);
      opportunityLineItem1.auto_renew__c=true;
      insert opportunityLineItem1;

    
   
    String expectedMessage = 'Experian One Product';
    
    OpportunityTriggerHandler.isBeforeUpdateTriggerExecuted = false;
    OpportunityTriggerHandler.isAfterUpdateTriggerExecuted = false;
    
    system.debug('Start test MR:::::' +  Limits.getQueries());
    
         
      //17. Close the Opp. and Assertion that has been closed correctly plus assertion that Transaction Queue record has been created.
      Confidential_Information__c conInfo2       = new Confidential_Information__c ();
      conInfo2.Opportunity__c                    = testOpp.Id;
      conInfo2.Document_Type__c                  ='DA SaaS Document';
      conInfo2.RecordTypeId                      = confInfoOppRTId;
      conInfo2.Account__c                        = testAccount.Id;
      conInfo2.Ownerid                           = testUser1.Id;
      insert conInfo2;
            
      Attachment ssd_File3 = new Attachment(ParentId = conInfo2.Id, Body = Blob.valueOf('TEST'), Name = 'Attachment.pdf');
      insert ssd_File3;
      
      
      OpportunityTriggerHandler.isBeforeUpdateTriggerExecuted = false;
      OpportunityTriggerHandler.isAfterUpdateTriggerExecuted  = false;
     
      testOpp.StageName = Constants.OPPTY_STAGE_7;
      try{
        update testOpp;    
      } catch(Exception e){
        system.assert(e.getMessage().contains(expectedMessage), 'message=' + e.getMessage());//Validation to ensure that there is an Opportunity Contact Role of type Admin Contact.
      }
      
      oppContactRole1.Role = 'Admin Contact';
      update testOpp;
     
      List<Opportunity> opp_List = [SELECT Id, StageName, DA_SaaS_Sales_Products_for_Opportunity__c FROM Opportunity WHERE Id = :testOpp.Id LIMIT 1];
      
      system.assert(opp_List[0].StageName==Constants.OPPTY_STAGE_7, 'The Opportunity could not be closed.');
      
      ////system.assert(opp_List[0].DA_SaaS_Sales_Products_for_Opportunity__c!=null, 'Opportunity.DA_SaaS_Sales_Products_for_Opportunity__c was not populated.' + opp_List[0].DA_SaaS_Sales_Products_for_Opportunity__c);       
      
      system.assert([SELECT Id FROM Transaction_Queue__c WHERE SF_Record_ID__c=:testOpp.Id AND Operation_Type__c = 'Request Creation']!=null, 'Transaction Queue record not created.');     
      
       Test.stopTest(); 
  
  }
  
  private static testmethod void test_TQinsert(){
        
        RecordType confInfoOppRT = [SELECT Id,Name FROM RecordType WHERE SObjectType =: Constants.SOBJECT_CONFIDENTIAL_INFO
                                                   AND Name =: Constants.RECORDTYPE_CONF_INFO_OPPTY LIMIT 1];
        
        // create User
        Profile p = [select id from profile where name=: Constants.PROFILE_SYS_ADMIN ];
        
        User testUser1 = Test_Utils.createUser(p, 'test1234@experian.com', 'test1');
        testuser1.business_unit__c='APAC CS SEA';
        insert testUser1;

        Account testAccount = Test_Utils.createAccount();
        testAccount.DP_RefNo__c='ABC123';
        testAccount.CNPJ_Number__c = '765564453';
        insert testAccount;
        Contact newcontact  = Test_Utils.insertContact(testAccount.id);
        Address__c address = Test_Utils.insertAddress(true);
            
        //insert account address
        Account_Address__c accAddrs = Test_Utils.insertAccountAddress(true, address.Id, testAccount.Id);

        Test_Utils.insertContactAddress(true, address.Id, newcontact.Id);

        Contact newcontact2  = Test_Utils.insertContact(testAccount.id);

        Test_Utils.insertContactAddress(true, address.Id, newcontact2.Id);
     
        Opportunity testOpp = new Opportunity();
        system.runAs(testUser1) {
            // Create an opportunity
            testOpp = Test_Utils.createOpportunity(testAccount.Id);
            testOpp.Starting_Stage__c = Constants.OPPTY_STAGE_6;
            testOpp.Type = Constants.OPPTY_NEW_FROM_NEW;
            testOpp.Primary_Quote_has_been_Approved__c = true;
            testOpp.Quote_Number__c = '9876543';
            insert testOpp;

            OpportunityContactRole oppContactRole = Test_Utils.insertOpportunityContactRole(true, testOpp.Id, newcontact.Id, Constants.DECIDER, true);
            OpportunityContactRole oppContactRole2 = Test_Utils.insertOpportunityContactRole(true, testOpp.Id, newcontact2.Id, 'Admin Contact', false);
            OpportunityContactRole oppContactRole3 = Test_Utils.insertOpportunityContactRole(true, testOpp.Id, newcontact2.Id, 'Bill-To' ,false);

            Product2 product = Test_Utils.insertProduct();
            //Pricebook2 pricebook = Test_Utils.getPriceBook2();
            //Pricebook2 standardPricebook = Test_Utils.getPriceBook2(Constants.STANDARD_PRICE_BOOK);
            PricebookEntry stdPricebookEntry = Test_Utils.insertPricebookEntry(product.Id, Test.getStandardPriceBookId(), Constants.CURRENCY_USD);

            //insert OLI
            OpportunityLineItem opportunityLineItem1 = Test_Utils.createOpportunityLineItem(testOpp.Id, stdPricebookEntry.Id, testOpp.Type);
            opportunityLineItem1.Start_Date__c = Date.today().addDays(5);
            opportunityLineItem1.End_Date__c = System.today().addDays(10);
            opportunityLineItem1.auto_renew__c=true;
            insert opportunityLineItem1;
            
            //4. Add CI record with correct Document Type.
            
        }       
        Test.startTest();                         
            
            Confidential_Information__c conInfo       = new Confidential_Information__c ();
            conInfo.Opportunity__c                    = testOpp.Id;
            conInfo.Document_Type__c                  ='DA SaaS Document';
            //conInfo.Synch_Opportunity_Team_Members__c = false;
            conInfo.RecordTypeId                      = confInfoOppRT.Id;
            conInfo.Account__c                        = testAccount.Id;
            conInfo.Ownerid                           = testUser1.Id;
            insert conInfo;
                
            //5. Add PDF Attachment to CI record.
            Attachment ssd_File = new Attachment(ParentId = conInfo.Id, Body = Blob.valueOf('TEST'), Name = 'Attachment-9876543.pdf');
            insert ssd_File;
            
            opportunity testoppupd = [select id,Owner_s_Business_Unit__c, stagename,Auto_Renew_Count__c from opportunity where id = : testopp.id];

            testoppupd.StageName = Constants.OPPTY_STAGE_7;

            opportunitytriggerhandler.isAfterUpdateTriggerExecuted = false;

            update testoppupd ;
              
        Test.stopTest();
        
    }
}