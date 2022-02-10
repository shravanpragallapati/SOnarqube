@isTest
private class BFS_Project_ProductScoreUpdate_Page_Test {
  
  @isTest static void test_method_one() {
      BFS_Data_Dictionary_Access__c settings = BFS_Data_Dictionary_Access__c.getOrgDefaults();
        settings.Enabled__c = true;
        upsert settings BFS_Data_Dictionary_Access__c.Id;
      
    Account testAcc = Test_Utils.insertAccount();
        Sub_Code__c subcode = new Sub_Code__c(Account__c = testAcc.ID, Subscriber_Code__c = 'test');
        insert subcode;
        Project__c newProject = Test_Utils.createProspectProject(testAcc.ID, subcode.ID);
        insert newProject;

    
    BFS_Automated_Product_Score__c testScore = new BFS_Automated_Product_Score__c(Type__c = 'Custom Attribute', Account__c = testAcc.ID);
    insert testScore;
    
    List<Project_Product_Score__c> testScoreList = new List<Project_Product_Score__c>();
    Project_Product_Score__c testScoreRel1 = new Project_Product_Score__c(Project__c = newProject.ID, BFS_Automated_Product_Score__c = testScore.ID,
                                                                             Attachment_Section__c = 'Selection Criteria', AttachSegment__c = 'AA');
    testScoreList.add(testScoreRel1);
    Project_Product_Score__c testScoreRel2 = new Project_Product_Score__c(Project__c = newProject.ID, BFS_Automated_Product_Score__c = testScore.ID,
                                                                             Attachment_Section__c = 'Selection Criteria', AttachSegment__c = 'AA');
    testScoreList.add(testScoreRel2);
    Project_Product_Score__c testScoreRel3 = new Project_Product_Score__c(Project__c = newProject.ID, BFS_Automated_Product_Score__c = testScore.ID,
                                                                             Attachment_Section__c = 'Selection Criteria', AttachSegment__c = 'BB');
    testScoreList.add(testScoreRel3);
    Project_Product_Score__c testScoreRel4 = new Project_Product_Score__c(Project__c = newProject.ID, BFS_Automated_Product_Score__c = testScore.ID,
                                                                             Attachment_Section__c = 'Append', AttachSegment__c = 'AA');
    testScoreList.add(testScoreRel4);

    insert testScoreList;
    
    List<Id> cloneList = new List<Id>();
    cloneList.add(testScoreRel1.id);
    cloneList.add(testScoreRel2.id);
    BFS_Project_ProductScrUpdate_Page_Ctrlr.cloneScores(cloneList,null);

    BFS_Project_ProductScrUpdate_Page_Ctrlr.queryExistingScores(newProject.ID);
    
    //Testing reordering scores
    List<String> recordList = new List<String>();
    recordList.add(testScoreRel1.Id);
    recordList.add(testScoreRel2.Id);    
    BFS_Project_ProductScrUpdate_Page_Ctrlr.reorderRecords('row',testScoreRel1.id,'down',recordList);
    BFS_Project_ProductScrUpdate_Page_Ctrlr.reorderRecords('row',testScoreRel1.id,'up',recordList);
    
    //Testing reordering Segments
    List<Project_Product_Score__c> projectScoreRecord= [SELECT Id, BFS_Segment_Section__c, BFS_Attachment_Section__c FROM Project_Product_Score__c WHERE Id=:testScoreRel1.Id];
    BFS_Project_ProductScrUpdate_Page_Ctrlr.reorderRecords('Segment',projectScoreRecord[0].BFS_Segment_Section__c,'down',recordList);
    BFS_Project_ProductScrUpdate_Page_Ctrlr.reorderRecords('Segment',projectScoreRecord[0].BFS_Segment_Section__c,'up',recordList);
    
    //Testing reordering Attachments
    BFS_Project_ProductScrUpdate_Page_Ctrlr.reorderRecords('Attachment',projectScoreRecord[0].BFS_Attachment_Section__c,'down',recordList);
    //BFS_Project_ProductScrUpdate_Page_Ctrlr.reorderRecords('Attachment',projectScoreRecord[0].BFS_Attachment_Section__c,'up',recordList);

    List<String> scoresToAdd = new List<String>();
    String scoreToAddJSON = '{"Name":"AUTO EQUITY","BFSID":"AUTO_EQUITY_SCORE","Link":"/a830x0000008OIUAA2","Included":true,"Type":"SAS","AttachmentSection":"--NONE--","Segment":"--NONE--","SubcodeIE":"--NONE--"}';
    scoresToAdd.add(scoreToAddJSON);

    List<ID> IDsToRemove = new List<ID>();

    List<String> scoresToUpdate = new List<String>();
    String scoreToUpdate = '{"Name":"AUTO EQUITY","BFSID":"AUTO_EQUITY_SCORE","Included":true,"JunctionID":"' + testScoreRel1.ID + '","JunctionIDLink":"/' + testScoreRel1.ID + '","IncludeInBilling":false,"AttachmentSection":"Append","Type":"SAS","Segment":"--NONE--","SubcodeIE":"--NONE--"}';
    scoresToUpdate.add(scoreToUpdate);
   Test.startTest();
    BFS_Project_ProductScrUpdate_Page_Ctrlr.addScores(scoresToAdd, newProject.ID);
      BFS_Project_ProductScrUpdate_Page_Ctrlr.updateScores(scoresToUpdate, newProject.ID);
    BFS_Project_ProductScrUpdate_Page_Ctrlr.removeScores(IDsToRemove, newProject.ID);
      Test.stopTest();
  }

  @isTest static void settingPicklistValues() {
    BFS_Project_ProductScrUpdate_Page_Ctrlr.getAttachmentSectionValues();
    BFS_Project_ProductScrUpdate_Page_Ctrlr.getSegmentValues();
    BFS_Project_ProductScrUpdate_Page_Ctrlr.getSubcodeIEValues();
  }
  
}