@isTest
private class CTCOM_CaseController_Test{
  
    static testmethod void testMethod1(){
      Test.startTest();
          Case cs = [select id, Subject from Case limit 1];
          CTCOM_CaseController.getCaseDetails(cs.Id);
          CTCOM_CaseController.saveCaseComment(cs.Id,'Test Comments');
          CTCOM_CaseController.saveCaseComment(cs.Id,'Test Comments Replied');
          CTCOM_CaseController.getCaseComments(cs.Id);
          CTCOM_CaseController.getCaseFiles(cs.Id);
          CTCOM_CaseController.getSubcodes('0','');
          CTCOM_CaseController.getAccountEntitlement();
          CTCOM_CaseController.getAssetList('ctcomCaseCreateANDViewSC');
      Test.stopTest();
    }
     
    static testmethod void testMethod2(){
      Test.startTest();
          Case cs = [select id, Subject from Case limit 1];
          
           Account testAccount1 = Test_Utils.createAccount();
           insert testAccount1;
		   Sub_code__c sc = Test_Utils.createSubCode(testAccount1, '01');
        insert sc;
           Contact testContact1 = Test_Utils.createContact(testAccount1.id);
           testContact1.Permission_to_Contact_Confirmed__c = 'No';
           insert testContact1;
          
           User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
           User testUser;
           system.runAs(thisUser){
    
              testUser = Test_Utils.createUser('Xcustomer - Experian User');
              testUser.Contactid = testContact1.id;
              testUser.Community_User_Group__c = 'Reseller CIS/BIS';
              insert testUser;
          }
          system.runAs(testUser){
              CTCOM_CaseController.getSubcodes('0','00;01');
              CTCOM_CaseController.getAccountEntitlement();
              CTCOM_CaseController.getAssetList('ctcomCaseCreateANDViewEDQ');
          }
      Test.stopTest();
    }
    
    @testSetup 
    static void testData() {
        // create User
        Profile p = [select id from profile where name=: Constants.PROFILE_SYS_ADMIN ];
        User testUser1 = Test_Utils.createUser(p, 'test1234@experian.com', 'test1');
        insert testUser1;
        
        // Create AA custom settings 04/13/16
        Agile_Accelerator_Settings__c  agileSettings = new Agile_Accelerator_Settings__c();
        agileSettings.CaseType__c ='GCSS Support';
        agileSettings.Name= 'GCSS Support Team';
        insert agileSettings;
        
        Agile_Accelerator_Settings__c  csaAgileSettings = new Agile_Accelerator_Settings__c();
        csaAgileSettings.CaseType__c ='CSA Support Team';
        csaAgileSettings.Name= 'CSA Support Team';
        insert csaAgileSettings;
        
        Agile_Accelerator_Settings__c  cpqAgileSettings = new Agile_Accelerator_Settings__c();
        cpqAgileSettings.CaseType__c ='CPQ Support Team';
        cpqAgileSettings.Name= 'CPQ Support Team';
        insert cpqAgileSettings;
        
        System.runAs(testUser1){
        
            // Need to Query permission set name 'Agile Accelerator Admin' to let the test class pass.
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Agile_Accelerator_Admin'];
            
            // Assign the above inserted user for the Agile Accelerator Admin Permission Set.
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = testUser1.Id;
            psa.PermissionSetId = ps.Id;
            insert psa; 
            
            //Create Scrum Team
            agf__ADM_Scrum_Team__c newTeam  = new agf__ADM_Scrum_Team__c(Name = 'Test Team',agf__Active__c=true,agf__Cloud__c ='IT');
            
            insert newTeam;
            
            //Create Agile Product Tag
            agf__ADM_Product_Tag__c  newProductTag = new agf__ADM_Product_Tag__c(Name = 'GCSS Product Team',agf__Team__c =newTeam.Id,agf__Team_Tag_Key__c ='123',      agf__Active__c=true );
            
            insert newProductTag;
            
            // Create custom settings
            Agile_Accelerator_Settings__c  agileSettings1 = Agile_Accelerator_Settings__c.getValues('GCSS Support Team'); 
            agileSettings1.agf_Product_Tag_c__c =newProductTag.Id;
            agileSettings1.agf_Scrum_Team_c__c = newTeam.Id;
            agileSettings1.Default_Assignee_Id__c = testUser1.Id;
            update agileSettings1; 
            
            IsDataAdmin__c isDateAdmin = Test_Utils.insertIsDataAdmin(false);
            //create Account
            Account acc = Test_Utils.insertAccount();
            
            Confidential_Information__c confInfoSaaS = new Confidential_Information__c();
            //confInfoSaaS.Account__c = acc.id;
            confInfoSaaS.Document_Type__c = 'DA SaaS Document';
            //confInfoSaaS.RecordTypeId=confInfoOppRT.id;
            insert confInfoSaaS;                       
            
            String crmRecordType = DescribeUtility.getRecordTypeIdByName(Constants.SOBJECT_CASE, Constants.RECORDTYPE_Service_Central); 
            
            
            //Create Case   
            Case GCSSCase = new Case(
            RecordTypeId = crmRecordType,
            Status = Constants.CASE_STATUS_IN_PROGRESS,
            Subject = 'Test Case 124',
            Description = 'Test details goes here',
            Implementation_Status__c = Constants.CASE_STATUS_IN_PROGRESS,
            Type = agileSettings1.CaseType__c, //'GCSS Support' , //Constants.CASE_TYPE_INCIDENT,  
            Account__c = acc.Id
            );
            insert GCSSCase;
            
            //Create Case   
            Case GCSSCase1 = new Case(
            RecordTypeId = crmRecordType,
            Status = Constants.CASE_STATUS_IN_PROGRESS,
            Subject = 'Test Case 124',
            Description = 'Test details goes here',
            Implementation_Status__c = Constants.CASE_STATUS_IN_PROGRESS,
            Type = agileSettings1.CaseType__c, //'GCSS Support' , //Constants.CASE_TYPE_INCIDENT,  
            Account__c = acc.Id
            );
            insert GCSSCase1;
            
            GCSSCase.Status= 'Closed - Complete';
            GCSSCase.Resolution__c  = 'Case Closed';
            update GCSSCase;  
            
            Attachment att = new Attachment();
            att.Name = 'Test File';
            att.Body = Blob.ValueOf('SomeData');
            att.ParentId = GCSSCase.Id;
            insert att;
            
            ContentVersion cv1 = Test_Utils.insertContentVersion(true,Blob.valueOf('SomeData'),'Test1','Test1');              
            ContentVersion cv2 = Test_Utils.getContentVersion(cv1.Id);
            ContentDocumentLink cdl = Test_Utils.insertContentDocumentLink(true,cv2.ContentDocumentId,GCSSCase.Id);                           
                         
        }                        
    }
    
    @isTest
    private static void testGetCaseTeamMembers(){
        Test.startTest();
        Account acc = Test_Utils.insertAccount();
        Case cs = Test_Utils.insertCase(true, acc.Id);
        Contact con = Test_Utils.insertContact(acc.Id);
        CaseTeamRole ctr = [select id from CaseTeamRole where name='Collaborator' limit 1];
        CaseTeamMember ctm = new CaseTeamMember(memberId=con.Id, parentId=cs.Id, teamroleid=ctr.Id);
        insert ctm;
        CTCOM_CaseController.getCaseTeamMembers(cs.Id);
        Test.stopTest();
    }
    
    @isTest
    private static void testgetContacts(){
        Test.startTest();
        Account acc = Test_Utils.insertAccount();
        Case cs = Test_Utils.insertCase(true, acc.Id);
        Contact con = Test_Utils.createcontact(acc.Id);
        con.Status__c='Active';
        con.FirstName = 'Test 123';
        insert con;
        Contact con1 = Test_Utils.insertContact(acc.Id);
        CaseTeamRole ctr = [select id from CaseTeamRole where name='Collaborator' limit 1];
        CaseTeamMember ctm = new CaseTeamMember(memberId=con1.Id, parentId=cs.Id, teamroleid=ctr.Id);
        CTCOM_CaseController.getContacts('test', acc.Id, cs.Id);
        Test.stopTest();
    }
  
    @isTest
    private static void testsaveCaseTeamMember(){
        Test.startTest();
        Account acc = Test_Utils.insertAccount();
        Case cs = Test_Utils.insertCase(true, acc.Id);
        Contact con = Test_Utils.insertContact(acc.Id);
        Map<String, String> newMap = new Map<String, String>();
        newMap.put('MemberId', con.Id);
        newMap.put('ParentId', cs.Id);
        CTCOM_CaseController.saveCaseTeamMember(newMap);
        Test.stopTest();
    }
    
    @isTest
    private static void testdeleteCaseTeamMember(){
        Test.startTest();
        Account acc = Test_Utils.insertAccount();
        Case cs = Test_Utils.insertCase(true, acc.Id);
        Contact con = Test_Utils.insertContact(acc.Id);
        Map<String, String> newMap = new Map<String, String>();
        newMap.put('MemberId', con.Id);
        newMap.put('ParentId', cs.Id);
        CTCOM_CaseController.deleteCaseTeamMember(newMap);
        Test.stopTest();
    }
}