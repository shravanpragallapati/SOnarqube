/**=====================================================================
 * Name: AssignmentTeamTriggerHandler_Test
 * Description: Test class for BatchAccountAssignmentTeamUpdate
 * Created Date: Feb 18th, 2020
 * Created By: Dheekonda Ganesh
 *
 * Date Modified                Modified By                  Description of the update
  =====================================================================*/
@isTest
private class BatchAssignmentTeamUpdate_Test{  
  
    static testMethod void assignmentTeamUpdateAndDelete_BIS_CIS_Test(){
    
        map<Id,Assignment_Team__c> accTeams_CIS_Map = new map<Id,Assignment_Team__c>([SELECT id, Account_Executive__c FROM Assignment_Team__c WHERE Name LIKE '%CIS%']);    
        map<Id,Assignment_Team__c> accTeams_BIS_List = new map<Id,Assignment_Team__c>([SELECT id, Account_Executive__c FROM Assignment_Team__c WHERE Name LIKE '%BIS%']);  
        Test.startTest();   
        
            BatchAssignmentTeamUpdate objbatch = new BatchAssignmentTeamUpdate(accTeams_BIS_List, accTeams_CIS_Map, new set<Id>(), 'update');
            Database.executeBatch(objbatch,50);         
          
        Test.stopTest();
    
    }
    static testMethod void assignmentTeamUpdateAndDelete_BIS_CIS_Test_2(){
    
        map<Id,Assignment_Team__c> accTeams_CIS_Map = new map<Id,Assignment_Team__c>([SELECT id, Account_Executive__c FROM Assignment_Team__c WHERE Name LIKE '%CIS%']);    
        map<Id,Assignment_Team__c> accTeams_BIS_List = new map<Id,Assignment_Team__c>([SELECT id, Account_Executive__c FROM Assignment_Team__c WHERE Name LIKE '%BIS%']);  
        Test.startTest();   
        
            BatchAssignmentTeamUpdate objbatch = new BatchAssignmentTeamUpdate(accTeams_BIS_List, accTeams_CIS_Map, new set<Id>(), 'delete');
            Database.executeBatch(objbatch,50);         
          
        Test.stopTest();
    
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