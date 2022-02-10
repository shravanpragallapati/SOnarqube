/**=====================================================================
 * Name: AssignmentTeamTriggerHandler_Test
 * Description: Test class for AssignmentTeamTriggerHandler
 * Created Date: May 25th, 2017
 * Created By: James Wills
 *
 * Date Modified                Modified By                  Description of the update
  =====================================================================*/
@isTest
public class AssignmentTeamTriggerHandler_Test {

  public static testMethod void assignmentTeamUpdateAndDelete_BIS_Test(){
    
    List<Assignment_Team__c> accTeams_BIS_List    = [SELECT id, Account_Executive__c FROM Assignment_Team__c WHERE Name LIKE '%BIS%'];    
    List<Account_Assignment_Team__c> aat_BIS_List = [SELECT id, Account__c FROM Account_Assignment_Team__c WHERE Assignment_Team__c = :accTeams_BIS_List[0].id];    
    Account accForBIS                             = [SELECT id, BIS_Account_Executive_Role__c FROM Account WHERE id = :aat_BIS_List[0].Account__c];

    String accExecRole_BIS = accForBIS.BIS_Account_Executive_Role__c;

    Test.startTest();    
    
      accTeams_BIS_List[0].Account_Executive__c = [SELECT id FROM User WHERE FirstName = 'Test' AND LastName='User2'].id;
    
      update accTeams_BIS_List;      
      System.assert(accExecRole_BIS==accForBIS.BIS_Account_Executive_Role__c ,'assignmentTeamUpdateAndDelete_BIS_Test: BIS_Account_Executive_Role__c has not changed.');
      
      delete accTeams_BIS_List[0];       
      System.assert(accExecRole_BIS==accForBIS.BIS_Account_Executive_Role__c ,'assignmentTeamUpdateAndDelete_BIS_Test: BIS_Account_Executive_Role__c has not been deleted.');
      
    Test.stopTest();
  
  }
  
  public static testMethod void assignmentTeamUpdateAndDelete_CIS_Test(){
    
    List<Assignment_Team__c> accTeams_CIS_List    = [SELECT id, Account_Executive__c FROM Assignment_Team__c WHERE Name LIKE '%CIS%'];    
    List<Account_Assignment_Team__c> aat_CIS_List = [SELECT id, Account__c FROM Account_Assignment_Team__c WHERE Assignment_Team__c = :accTeams_CIS_List[0].id];    
    Account accForCIS                             = [SELECT id, CIS_Account_Executive_Role__c FROM Account WHERE id = :aat_CIS_List[0].Account__c];
    
    String accExecRole_CIS = accForCIS.CIS_Account_Executive_Role__c;
    
    Test.startTest();    
    
      accTeams_CIS_List[0].Account_Executive__c = [SELECT id FROM User WHERE FirstName = 'Test' AND LastName='User2'].id;
    
      update accTeams_CIS_List;    
      System.assert(accExecRole_CIS==accForCIS.CIS_Account_Executive_Role__c ,'assignmentTeamUpdateAndDelete_CIS_Test: CIS_Account_Executive_Role__c has not changed.');
  
      delete accTeams_CIS_List[0];
      System.assert(accExecRole_CIS==accForCIS.CIS_Account_Executive_Role__c ,'assignmentTeamUpdateAndDelete_CIS_Test: CIS_Account_Executive_Role__c has not been deleted.');
    
    Test.stopTest();
  
  }
  
      
  static testmethod void batch_Test() {

                             
      Test.startTest();
        //Execution of the batch
        BatchCreateNewSICrossReferenceRecords batu = new BatchCreateNewSICrossReferenceRecords();
        batu.execute((Database.BatchableContext) null, [SELECT id, Name, Assignment_Team__c, Account__c FROM Account_Assignment_Team__c]);
      //Stop test
      Test.StopTest();
        

      
    }
  
   
  @testSetup
  static void createTestData() {
    Account testAcc, testAcc2;
    Assignment_Team__c assignmentTeam_BIS, assignmentTeam_BIS_2, assignmentTeam_CIS, assignmentTeam_CIS_2;
    Account_Assignment_Team__c accountAssignmentTeam_BIS, accountAssignmentTeam_BIS_2, accountAssignmentTeam_CIS;
  
    // create users
    Profile p = [SELECT Id, Name FROM Profile WHERE Name=: Constants.PROFILE_SYS_ADMIN];
    
    User user1  = Test_Utils.createUser(p.Name);
    insert user1;
    
    User testUser1  = Test_Utils.createUser(p.Name);
    User testUser2  = Test_Utils.createUser(p.Name);
    
    system.runAs(user1){    
      testUser1.FirstName = 'Test';
      testUser1.LastName  = 'User1';
      testUser1.UserRoleId = [SELECT Id FROM UserRole WHERE Name = :Constants.ROLE_NA_COPS].id;
      insert testUser1;
    
      testUser2.FirstName = 'Test';
      testUser2.LastName  = 'User2';
      //testUser2.UserRoleId = [SELECT Id FROM UserRole WHERE Name = :Constants.ROLE_UKI_COPS].id;
      insert testUser2;
    }    
    
    // create accounts
    testAcc = Test_Utils.createAccount();
    testAcc.ownerId = userinfo.getuserId();
    testAcc.Name = 'Test Account 1';
    insert testAcc;
    
    
    // create assignment teams
    assignmentTeam_BIS           = Test_Utils.insertAssignmentTeam(false, testUser1.id);
    assignmentTeam_BIS_2         = Test_Utils.insertAssignmentTeam(false, testUser2.id);
    assignmentTeam_CIS           = Test_Utils.insertAssignmentTeam(false, testUser1.id);
    assignmentTeam_CIS_2         = Test_Utils.insertAssignmentTeam(false, testUser2.id);
    assignmentTeam_BIS.ownerId   = userinfo.getuserId();   
    assignmentTeam_BIS_2.ownerId = userinfo.getuserId();
    assignmentTeam_CIS.ownerId   = userinfo.getuserId();
   

    List<Assignment_Team__c> assignmentTeams = new List<Assignment_Team__c>();
    assignmentTeams.add(assignmentTeam_BIS);
    assignmentTeams.add(assignmentTeam_BIS_2);
    assignmentTeams.add(assignmentTeam_CIS);

    assignmentTeam_BIS.Name    = 'BIS - Growth';
    assignmentTeam_BIS_2.Name  = 'BIS - Growth 2';
    assignmentTeam_CIS.Name    = 'CIS - Growth';

    insert assignmentTeams;
    
    accountAssignmentTeam_BIS = new Account_Assignment_Team__c(Account__c = testAcc.id, Assignment_Team__c = assignmentTeam_BIS.id);
    insert accountAssignmentTeam_BIS;
    
    
    accountAssignmentTeam_CIS = new Account_Assignment_Team__c(Account__c = testAcc.id, Assignment_Team__c = assignmentTeam_CIS.id);
    insert accountAssignmentTeam_CIS;
    
  }

  
}