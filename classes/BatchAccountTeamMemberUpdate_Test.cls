/**=====================================================================
 * Appirio, Inc
 * Name: BatchAccountTeamMemberUpdate_Test
 * Description:  Story:     S-123907
 *               Task:      T-194927
 *               The following test class is designed to test the 'BatchAccountTeamMemberUpdate.cls' class.
 * Created Date: 
 * Created By: Shane Khublall (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 * Jan 30th, 2014               Jinesh Goyal(Appirio)        T-232760: Homogenize the comments
 * Feb 13th, 2014               Jinesh Goyal(Appirio)        T-232763: Added Exception Logging
 * Mar 04th, 2014               Arpita Bose (Appirio)        T-243282: Added Constants in place of String
 * Mar 05th, 2014               Jinesh Goyal (Appirio)       T-253906: test class renaming
 * Mar 14th, 2014               Arpita Bose (Appirio)        T-253906: Error fixed 
 * Oct 29th, 2014               Arpita Bose                  Updated to increase the code coverage
 * Aug 24th, 2015               Paul Kissick                 Case 01098587: Adding checks for UK&I MS Data Quality
 * Dec 3rd, 2015                Paul Kissick                 Case 01266075: Removing Global Settings for timings
 * Apr 7th, 2016                Paul Kissick                 Case 01932085: Fixing Test User Email Domain
 * Aug 5th, 2016                Paul Kissick                 CRM2:W-005393: Replacing Lead Qualifier with Sales Rep
 * Jul 08th, 2021               Manoj Gopu                   Case 22376534: Upgraded API Version to 48.0
 =====================================================================*/
@isTest
private class BatchAccountTeamMemberUpdate_Test {
  static testMethod void testBatch() {
    // Create Global Setting for datetime , for the test method.
    TestMethodUtilities.createTestGlobalSettings();
    Global_Settings__c lastRun = Global_Settings__c.getInstance(Constants.GLOBAL_SETTING);

    Datetime testBeforeDateTime = BatchHelper.getBatchClassTimestamp('AccountTeamMemberJobLastRun');
    BatchHelper.setBatchClassTimestamp('AccountTeamMemberJobLastRun', testBeforeDateTime.addMinutes(-60));
    lastRun.Batch_Failures_Email__c = 'test@experian.com';
    update lastRun;
    
    lastRun = Global_Settings__c.getInstance(Constants.GLOBAL_SETTING);
    
    // generate the new users
    // create a test utils class put some methods to generate the data in, create global utils as well to retrieve global settings across org.
 
    // select profile, role from the org, by name.
    TestMethodUtilities testData = new TestMethodUtilities();
    testData.createTestUltimateParentAndChildAccounts();
    Account ultimateParent = testData.getUltimateParent();
 
 //RJ 
    AccountTriggerHandler.isAfterUpdateTriggerExecuted=false ;
 
 
    //TestMethodUtilities.createTestUltimateParentAndChildAccounts();
    Profile p = [select id from profile where name='System Administrator'];
    User testUser1 = Test_Utils.createUser(p, 'test1@experian.com', 'test1'); //,Email = 'test1@gmail.com', profileId = p.Id, Business_Unit__c = null, Global_Business_Line__c = null,alias = 'test1', emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='America/Los_Angeles', username='test1@testorg.com');
    User testUser2 = Test_Utils.createUser(p, 'test2@experian.com', 'test2');//,Email = 'test2@gmail.com', profileId = p.Id, Business_Unit__c = Constants.BUSINESS_UNIT_MS_CIT, Global_Business_Line__c = null,alias = 'test2', emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='America/Los_Angeles', username='test2@testorg.com');
    testUser2.Business_Unit__c = Constants.BUSINESS_UNIT_MS_CIT;
    User testUser3 = Test_Utils.createUser(p, 'test3@experian.com', 'test3'); // profileId = p.Id, Business_Unit__c = null, Global_Business_Line__c = Constants.GLOBAL_BUSINESS_MARKETING_SERVICES,alias = 'test3', emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='America/Los_Angeles', username='test3@testorg.com');       
    testUser3.Global_Business_Line__c = Constants.GLOBAL_BUSINESS_MARKETING_SERVICES;
    User testUser4 = Test_Utils.createUser(p, 'test4@experian.com', 'test4');
    testUser4.Global_Business_Line__c = Constants.GLOBAL_BUSINESS_MARKETING_SERVICES;
    testUser4.Business_Line__c = Constants.REGION_UKI + ' ' + Constants.GLOBAL_BUSINESS_MARKETING_SERVICES;
    testUser4.Business_Unit__c = BatchAccountTeamMemberUpdate.UKI_MS_DATA_QUALITY;

    List <User> testUsers = new List<User>();
    testUsers.add(testUser1);
    testUsers.add(testUser2);
    testUsers.add(testUser3);
    testUsers.add(testUser4);
    insert testUsers;
    
    // Now create 3 Account Team Members, add them to 3 separate accounts, one to planes, one to boats, one to cars.
    AccountTeamMember mem1 = new AccountTeamMember(
      UserId = testUser1.Id, 
      AccountId = testData.getUltimateParentId(), 
      TeamMemberRole=Constants.TEAM_ROLE_ACCOUNT_MANAGER
    );
    AccountTeamMember mem2 = new AccountTeamMember(
      UserId = testUser1.Id, 
      AccountId = testData.getchildOneId(),
      TeamMemberRole=Constants.TEAM_ROLE_CHANNEL_MANAGER
    );
    AccountTeamMember mem3 = new AccountTeamMember(
      UserId = testUser2.Id, 
      AccountId = testData.getUltimateParentId(),
      TeamMemberRole=Constants.TEAM_ROLE_SALES_REP
    );
    AccountTeamMember mem4 = new AccountTeamMember(
      UserId = testUser3.Id, 
      AccountId = testData.getchildTwoId(),
      TeamMemberRole=Constants.TEAM_ROLE_SALES_REP
    );
    
    // Now test the UK&I MS Data Quality user - This person should now flow to the children accounts
    AccountTeamMember mem5 = new AccountTeamMember(
      UserId = testUser4.Id, 
      AccountId = testData.getUltimateParentId(),
      TeamMemberRole=Constants.TEAM_ROLE_RENEWAL_OWNER
    );
    
    //RJ 
    AccountTriggerHandler.isAfterUpdateTriggerExecuted=false ;
    
    List <AccountTeamMember> testMembers = new List<AccountTeamMember>();
    testMembers.add(mem1);
    testMembers.add(mem2);
    testMembers.add(mem3);
    testMembers.add(mem4);
    testMembers.add(mem5);
    insert testMembers;
    system.debug('testMembers::' + testMembers);
        
    //child accounts
    Account testChild1 = new Account(
      Name ='Child1', 
      DQ_Status__c='Pending', 
      Region__c='APAC', 
      Type='Prospect',
      ParentId =  ultimateParent.Id,
      Industry='Apparel', 
      Ultimate_Parent_Account__c = ultimateParent.Id
    );
    Account testChild2 = new Account(
      Name ='Child2', 
      DQ_Status__c='Pending', 
      Region__c='APAC', 
      Type='Prospect', 
      ParentId = ultimateParent.Id,
      Industry='Apparel', 
      Ultimate_Parent_Account__c = ultimateParent.Id
    );

    //RJ 
    AccountTriggerHandler.isAfterUpdateTriggerExecuted=false ;

    List<Account> testChildAcc = new List<Account>();
    testChildAcc.add(testChild1);
    testChildAcc.add(testChild2);
    insert testChildAcc;
    system.debug('testChildAcc::' + testChildAcc);
    List<Account> resAccounts = [SELECT ID, Ultimate_Parent_Account__c FROM Account WHERE id in : testChildAcc];
    system.debug(':::resAccounts'+resAccounts);
    
    
    
    Test.StartTest();
    //RJ 
    AccountTriggerHandler.isAfterUpdateTriggerExecuted=false ;
    BatchAccountTeamMemberUpdate batu = new BatchAccountTeamMemberUpdate();        
    
    ID batchprocessid = Database.executeBatch(batu); 
    batu.execute((Database.BatchableContext) null, testMembers);
    Test.StopTest();

    //assert that 2 records were inserted on child accounts, excluding records inserted on the ultimate parent account
    //system.assertEquals([SELECT COUNT() FROM AccountTeamMember WHERE AccountID =: testData.getchildOneId()], 2);
       
    system.assert(testBeforeDateTime != BatchHelper.getBatchClassTimestamp('AccountTeamMemberJobLastRun'));
    
    
  }
}