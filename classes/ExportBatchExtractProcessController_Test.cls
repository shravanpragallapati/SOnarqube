/******************************************************************************
 * Name: ExportBatchExtractProcessController_Test.cls
 * Description: Test class for ExportBatchExtractProcessController.cls
 * Created Date: Nov 4th, 2014
 * Created By: Richard Joseph 
 * 
 * Date Modified        Modified By             Description 
 * Sep 8th, 2015        Paul Kissick            I-179463: Duplicate Management Failures
 * Jan 7th, 2018        Malcolm Russell         DP Migration Project
 * Nov 3rd, 2018        Mauricio Murillo        Increased code coverage
 ******************************************************************************/
@isTest
private class ExportBatchExtractProcessController_Test {
  
  enum exportFileTypes {RPMFile, SummitFile, RoyaltiesFile,PartnerFile,CustomerFile,DPFile,DPCustomerFile,PMM,APACSummitFile,EBATransFile,EBACustomerFile,EBATransFileNew,EBATransCreditFile} 
  
  private static testmethod void testExportBatchExtractProcessUS(){
    // create test data
    Test_Utils tu = new Test_Utils();
    
    // NLG - Creating this trigger setting so that the webservice in UserTriggerHandler doesn't run
    TriggerSettings__c triggerSetting = new TriggerSettings__c();
    triggerSetting.Name = 'UserTrigger';
    triggerSetting.isActive__c = false;
    insert triggerSetting;  
    
    User currentUser = new User();
    currentUser.Id = UserInfo.getUserId();
    currentUser.Region__c = 'UK&I';
    currentUser.Global_Business_Line__c = 'Marketing Services';
    currentUser.Business_Line__c = 'APAC Marketing Services';
    currentUser.Office_Location__c = 'Amsterdam';
    currentUser.Department__c = 5;
    currentUser.Payroll__c = 100;
    currentUser.Business_Unit__c = 'APAC MS Data Quality';
    update currentUser; 
    
    triggerSetting.IsActive__c = true;
    update triggerSetting;

    Account testAcc = Test_Utils.insertAccount();

    Contact con = new Contact (FirstName = 'Larry', LastName = 'Ellison',
                                AccountId = testAcc.Id, Email = 'larrye@email.com');
    insert con;

    Opportunity testOpp = Test_Utils.insertOpportunity(testAcc.Id);
    
    Address__c addrs1 = Test_Utils.insertAddress(true);
    
    Opportunity_Contact_Address__c opConAdrs = new Opportunity_Contact_Address__c();
    opConAdrs.Contact__c = con.Id;
    opConAdrs.Opportunity__c = testOpp.Id;
    opConAdrs.Address__c = addrs1.Id;
    opConAdrs.Role__c = Constants.OPPTY_CONTACT_ROLE_PURCHASE_LEDGER;
    insert opConAdrs;
     
    Export_Batch__c testBatch= new Export_Batch__c (Name='TestClass Batch');
    insert  testBatch;
          
    Order__c testOrder1 = Test_Utils.insertOrder(false, testAcc.Id, con.Id, testOpp.Id);
    testOrder1.Owner_BU_on_Order_Create_Date__c = 'EDQ';
    testOrder1.OwnerId = currentUser.Id;
    
    testOrder1.Finance_Invoice_Export_Batch__c=testBatch.id;

    Order__c testOrder2 = Test_Utils.insertOrder (false, testAcc.Id, con.Id, testOpp.Id );
    testOrder2.Owner_BU_on_Order_Create_Date__c = 'EDQ';
    testOrder2.OwnerId = currentUser.Id;
    testOrder2.Finance_Invoice_Export_Batch__c=testBatch.id;

    Order__c testOrder3 = Test_Utils.insertOrder (false, testAcc.Id, con.Id, testOpp.Id );
    testOrder3.Owner_BU_on_Order_Create_Date__c = 'EDQ';
    testOrder3.OwnerId = currentUser.Id;
    testOrder3.Finance_Invoice_Export_Batch__c=testBatch.id;
    testOrder3.Close_Date__c = system.today();

    Order__c testOrder4 = Test_Utils.insertOrder (false, testAcc.Id, con.Id, testOpp.Id );
    testOrder4.Owner_BU_on_Order_Create_Date__c = 'EDQ';
    testOrder4.OwnerId = currentUser.Id;
    testOrder4.Finance_Invoice_Export_Batch__c=testBatch.id;
    
    Product2 product = new Product2(Name = 'TestClass_test_Prod1');
    product.Global_Business_Line__c = 'Experian Data Quality';
    product.ProductCode='ADD0T';
    insert product;
        
    // Pricebook2 standard = [Select Id,IsActive From Pricebook2 Where IsStandard = true limit 1];
    // if (!standard.isActive) {
    //   standard.IsActive = true;
    //   update standard;
    // }
    
    List<Order__c> edqOrders = new List<Order__c>();
    edqOrders.add(testOrder1);
    edqOrders.add(testOrder2);
    edqOrders.add(testOrder3);
    edqOrders.add(testOrder4);
    insert edqOrders;
        
    Billing_Product__c billProd = Test_Utils.insertBillingProduct();
    billProd.IFRS15_Secondary_Revenue_Subaccount_Code__c='REV52300';
    update billProd;
      
    List<Order_Line_Item__c> ordLnList = new list<Order_Line_Item__c>();
    // create Order Line Item
    Order_Line_Item__c ordrli1 = Test_Utils.insertOrderLineItems(false, testOrder1.Id, billProd.Id);
    ordrli1.CurrencyIsoCode = Constants.CURRENCY_USD;    
    ordrli1.Product__c=product.id;
    ordrli1.Total__c=1500;
    ordrLi1.EDQ_Memo_Line__c='NADD0T05';
    ordLnList.add(ordrli1);
    Order_Line_Item__c ordrli2 = Test_Utils.insertOrderLineItems(false, testOrder2.Id, billProd.Id);
    ordrli2.CurrencyIsoCode = Constants.CURRENCY_USD;
    ordrli2.Product__c=product.id;
    ordrli2.Partner_Amount__c= 1100;
    ordrli2.Total__c=2500;
    ordrLi2.EDQ_Memo_Line__c='NADD0T05';
    ordLnList.add(ordrli2);
    Order_Line_Item__c ordrli3 = Test_Utils.insertOrderLineItems(false, testOrder3.Id, billProd.Id);
    ordrli3.CurrencyIsoCode = Constants.CURRENCY_USD;
    ordrli3.Product__c=product.id;
    ordrli3.Total__c=1500;
    ordrLi3.EDQ_Memo_Line__c='NADD0T05';
    ordLnList.add(ordrli3);
    Order_Line_Item__c ordrli4 = Test_Utils.insertOrderLineItems(false, testOrder4.Id, billProd.Id);
    ordrli4.CurrencyIsoCode = Constants.CURRENCY_USD;
    ordrli4.Product__c=product.id;
    ordrli4.Total__c=1500;
    ordrLi4.EDQ_Memo_Line__c='NADD0T05';
    ordLnList.add(ordrli4);
      
    insert ordLnList;
      
    Royalty__c royalty1 = new Royalty__c(Name = 'test royalty #1', Line_Item_Reference_Number__c='1234',Order_Line_Item__c=ordrli3.id);
    insert royalty1;    
        
    Royalty__c royalty2 = new Royalty__c(Name = 'test royalty #2', Line_Item_Reference_Number__c='1234',Order_Line_Item__c=ordrli2.id);
    insert royalty2; 

    // start test
    Test.startTest();
    
    ExportBatchExtractProcessController testExportBatchController = new ExportBatchExtractProcessController();
    
    ApexPages.currentPage().getParameters().put('BatchID',testBatch.id );
    ApexPages.currentPage().getParameters().put('ExportFile',exportFileTypes.CustomerFile.name() );
    testExportBatchController.exportFileProcess();
    testExportBatchController.getfileName();
    
    ApexPages.currentPage().getParameters().put('BatchID',testBatch.id );
    ApexPages.currentPage().getParameters().put('ExportFile',exportFileTypes.PartnerFile.name() );
    testExportBatchController.exportFileProcess();
    testExportBatchController.getfileName();
    
    ApexPages.currentPage().getParameters().put('BatchID',testBatch.id );
    ApexPages.currentPage().getParameters().put('ExportFile',exportFileTypes.RoyaltiesFile.name() );
    testExportBatchController.exportFileProcess();
    testExportBatchController.getfileName();
    
    ApexPages.currentPage().getParameters().put('BatchID',testBatch.id );
    ApexPages.currentPage().getParameters().put('ExportFile',exportFileTypes.SummitFile.name() );
    testExportBatchController.exportFileProcess();
    testExportBatchController.getfileName();
    
    ApexPages.currentPage().getParameters().put('BatchID',testBatch.id );
    ApexPages.currentPage().getParameters().put('ExportFile',exportFileTypes.RPMFile.name() );
    testExportBatchController.exportFileProcess();
    testExportBatchController.getfileName();
    
    ApexPages.currentPage().getParameters().put('BatchID',testBatch.id );
    ApexPages.currentPage().getParameters().put('ExportFile',exportFileTypes.PMM.name() );
    testExportBatchController.exportFileProcess();
    testExportBatchController.getfileName();
    
    ApexPages.currentPage().getParameters().put('BatchID',testBatch.id );
    ApexPages.currentPage().getParameters().put('ExportFile',exportFileTypes.APACSummitFile.name() );
    testExportBatchController.exportFileProcess();
    testExportBatchController.getfileName();

    Test.stopTest();
    
  }
  
  
  private static testmethod void testExportBatchExtractProcessAPAC(){
    // create test data
    Test_Utils tu = new Test_Utils();
    
    // NLG - Creating this trigger setting so that the webservice in UserTriggerHandler doesn't run
    TriggerSettings__c triggerSetting = new TriggerSettings__c();
    triggerSetting.Name = 'UserTrigger';
    triggerSetting.isActive__c = false;
    insert triggerSetting;  
    
    User currentUser = new User();
    currentUser.Id = UserInfo.getUserId();
    currentUser.Region__c = 'APAC';
    currentUser.Global_Business_Line__c = 'Marketing Services';
    currentUser.Business_Line__c = 'APAC Marketing Services';
    currentUser.Office_Location__c = 'Amsterdam';
    currentUser.Department__c = 5;
    currentUser.Payroll__c = 100;
    currentUser.Business_Unit__c = 'APAC MS Data Quality';
    update currentUser; 
    
    triggerSetting.IsActive__c = true;
    update triggerSetting;

    Account testAcc = Test_Utils.insertAccount();

    Contact con = new Contact (FirstName = 'Larry', LastName = 'Ellison',
                                AccountId = testAcc.Id, Email = 'larrye@email.com');
    insert con;

    Opportunity testOpp = Test_Utils.insertOpportunity(testAcc.Id);
    
    Address__c addrs1 = Test_Utils.insertAddress(true);
    
    Opportunity_Contact_Address__c opConAdrs = new Opportunity_Contact_Address__c();
    opConAdrs.Contact__c = con.Id;
    opConAdrs.Opportunity__c = testOpp.Id;
    opConAdrs.Address__c = addrs1.Id;
    opConAdrs.Role__c = Constants.OPPTY_CONTACT_ROLE_PURCHASE_LEDGER;
    insert opConAdrs;
     
    Export_Batch__c testBatch= new Export_Batch__c (Name='TestClass Batch');
    insert  testBatch;
          
    Order__c testOrder1 = Test_Utils.insertOrder(false, testAcc.Id, con.Id, testOpp.Id);
    testOrder1.Owner_BU_on_Order_Create_Date__c = 'EDQ';
    testOrder1.OwnerId = currentUser.Id;
    
    testOrder1.Finance_Invoice_Export_Batch__c=testBatch.id;

    Order__c testOrder2 = Test_Utils.insertOrder (false, testAcc.Id, con.Id, testOpp.Id );
    testOrder2.Owner_BU_on_Order_Create_Date__c = 'EDQ';
    testOrder2.OwnerId = currentUser.Id;
    testOrder2.Finance_Invoice_Export_Batch__c=testBatch.id;

    Order__c testOrder3 = Test_Utils.insertOrder (false, testAcc.Id, con.Id, testOpp.Id );
    testOrder3.Owner_BU_on_Order_Create_Date__c = 'EDQ';
    testOrder3.OwnerId = currentUser.Id;
    testOrder3.Finance_Invoice_Export_Batch__c=testBatch.id;
    testOrder3.Close_Date__c = system.today();

    Order__c testOrder4 = Test_Utils.insertOrder (false, testAcc.Id, con.Id, testOpp.Id );
    testOrder4.Owner_BU_on_Order_Create_Date__c = 'EDQ';
    testOrder4.OwnerId = currentUser.Id;
    testOrder4.Finance_Invoice_Export_Batch__c=testBatch.id;
    
    Product2 product = new Product2(Name = 'TestClass_test_Prod1');
    product.Global_Business_Line__c = 'Experian Data Quality';
    product.ProductCode='ADD0T';
    insert product;
        
    // Pricebook2 standard = [Select Id,IsActive From Pricebook2 Where IsStandard = true limit 1];
    // if (!standard.isActive) {
    //   standard.IsActive = true;
    //   update standard;
    // }
    
    List<Order__c> edqOrders = new List<Order__c>();
    edqOrders.add(testOrder1);
    edqOrders.add(testOrder2);
    edqOrders.add(testOrder3);
    edqOrders.add(testOrder4);
    insert edqOrders;
        
    Billing_Product__c billProd = Test_Utils.insertBillingProduct();
    billProd.IFRS15_Secondary_Revenue_Subaccount_Code__c='REV52300';
    update billProd;
      
    List<Order_Line_Item__c> ordLnList = new list<Order_Line_Item__c>();
    // create Order Line Item
    Order_Line_Item__c ordrli1 = Test_Utils.insertOrderLineItems(false, testOrder1.Id, billProd.Id);
    ordrli1.CurrencyIsoCode = Constants.CURRENCY_USD;    
    ordrli1.Product__c=product.id;
    ordrli1.Total__c=1500;
    ordrLi1.EDQ_Memo_Line__c='NADD0T05';
    ordLnList.add(ordrli1);
    Order_Line_Item__c ordrli2 = Test_Utils.insertOrderLineItems(false, testOrder2.Id, billProd.Id);
    ordrli2.CurrencyIsoCode = Constants.CURRENCY_USD;
    ordrli2.Product__c=product.id;
    ordrli2.Partner_Amount__c= 1100;
    ordrli2.Total__c=2500;
    ordrLi2.EDQ_Memo_Line__c='NADD0T05';
    ordLnList.add(ordrli2);
    Order_Line_Item__c ordrli3 = Test_Utils.insertOrderLineItems(false, testOrder3.Id, billProd.Id);
    ordrli3.CurrencyIsoCode = Constants.CURRENCY_USD;
    ordrli3.Product__c=product.id;
    ordrli3.Total__c=1500;
    ordrLi3.EDQ_Memo_Line__c='NADD0T05';
    ordLnList.add(ordrli3);
    Order_Line_Item__c ordrli4 = Test_Utils.insertOrderLineItems(false, testOrder4.Id, billProd.Id);
    ordrli4.CurrencyIsoCode = Constants.CURRENCY_USD;
    ordrli4.Product__c=product.id;
    ordrli4.Total__c=1500;
    ordrLi4.EDQ_Memo_Line__c='NADD0T05';
    ordLnList.add(ordrli4);
      
    insert ordLnList;
      
    Royalty__c royalty1 = new Royalty__c(Name = 'test royalty #1', Line_Item_Reference_Number__c='1234',Order_Line_Item__c=ordrli3.id);
    insert royalty1;    
        
    Royalty__c royalty2 = new Royalty__c(Name = 'test royalty #2', Line_Item_Reference_Number__c='1234',Order_Line_Item__c=ordrli2.id);
    insert royalty2; 

    // start test
    Test.startTest();
    
    ExportBatchExtractProcessController testExportBatchController = new ExportBatchExtractProcessController();
    
    ApexPages.currentPage().getParameters().put('BatchID',testBatch.id );
    ApexPages.currentPage().getParameters().put('ExportFile',exportFileTypes.CustomerFile.name() );
    testExportBatchController.exportFileProcess();
    testExportBatchController.getfileName();
    
    ApexPages.currentPage().getParameters().put('BatchID',testBatch.id );
    ApexPages.currentPage().getParameters().put('ExportFile',exportFileTypes.PartnerFile.name() );
    testExportBatchController.exportFileProcess();
    testExportBatchController.getfileName();
    
    ApexPages.currentPage().getParameters().put('BatchID',testBatch.id );
    ApexPages.currentPage().getParameters().put('ExportFile',exportFileTypes.RoyaltiesFile.name() );
    testExportBatchController.exportFileProcess();
    testExportBatchController.getfileName();
    
    ApexPages.currentPage().getParameters().put('BatchID',testBatch.id );
    ApexPages.currentPage().getParameters().put('ExportFile',exportFileTypes.SummitFile.name() );
    testExportBatchController.exportFileProcess();
    testExportBatchController.getfileName();
    
    ApexPages.currentPage().getParameters().put('BatchID',testBatch.id );
    ApexPages.currentPage().getParameters().put('ExportFile',exportFileTypes.RPMFile.name() );
    testExportBatchController.exportFileProcess();
    testExportBatchController.getfileName();
    
    ApexPages.currentPage().getParameters().put('BatchID',testBatch.id );
    ApexPages.currentPage().getParameters().put('ExportFile',exportFileTypes.DPFile.name() );
    testExportBatchController.exportFileProcess();
    testExportBatchController.getfileName();
    
    ApexPages.currentPage().getParameters().put('BatchID',testBatch.id );
    ApexPages.currentPage().getParameters().put('ExportFile',exportFileTypes.DPCustomerFile.name() );
    testExportBatchController.exportFileProcess();
    testExportBatchController.getfileName();

    Test.stopTest();
    
    
  }
  
  static testMethod void testGetOperatingUnitValue() {
    User u1 = Test_utils.createUser('Standard User');
    u1.Country__c = 'United States of America';
    insert u1;
    system.runAs(u1) {
      ExportBatchExtractProcessController c = new ExportBatchExtractProcessController();
      system.assertEquals('', c.operatingUnitName, 'OperatingUnitName should be empty.');
      c.getOperatingUnitValue();
      system.assertNotEquals('', c.operatingUnitName, 'OperatingUnitName should not be empty.');
    }
    u1.Country__c = 'United Kingdom';
    update u1;
    system.runAs(u1) {
      ExportBatchExtractProcessController c = new ExportBatchExtractProcessController();
      system.assertEquals('', c.operatingUnitName, 'OperatingUnitName should be empty.');
      c.getOperatingUnitValue();
      system.assertNotEquals('', c.operatingUnitName, 'OperatingUnitName should not be empty.');
    }
    u1.Country__c = 'France';
    update u1;
    system.runAs(u1) {
      ExportBatchExtractProcessController c = new ExportBatchExtractProcessController();
      system.assertEquals('', c.operatingUnitName, 'OperatingUnitName should be empty.');
      c.getOperatingUnitValue();
      system.assertNotEquals('', c.operatingUnitName, 'OperatingUnitName should not be empty.');
    }
    u1.Country__c = 'New Zealand';
    update u1;
    system.runAs(u1) {
      ExportBatchExtractProcessController c = new ExportBatchExtractProcessController();
      system.assertEquals('', c.operatingUnitName, 'OperatingUnitName should be empty.');
      c.getOperatingUnitValue();
      system.assertNotEquals('', c.operatingUnitName, 'OperatingUnitName should not be empty.');
    }
    u1.Country__c = 'Singapore';
    update u1;
    system.runAs(u1) {
      ExportBatchExtractProcessController c = new ExportBatchExtractProcessController();
      system.assertEquals('', c.operatingUnitName, 'OperatingUnitName should be empty.');
      c.getOperatingUnitValue();
      system.assertNotEquals('', c.operatingUnitName, 'OperatingUnitName should not be empty.');
    }
    u1.Country__c = 'Australia';
    update u1;
    system.runAs(u1) {
      ExportBatchExtractProcessController c = new ExportBatchExtractProcessController();
      system.assertEquals('', c.operatingUnitName, 'OperatingUnitName should be empty.');
      c.getOperatingUnitValue();
      system.assertNotEquals('', c.operatingUnitName, 'OperatingUnitName should not be empty.');
    }
    u1.Country__c = 'Netherlands';
    update u1;
    system.runAs(u1) {
      ExportBatchExtractProcessController c = new ExportBatchExtractProcessController();
      system.assertEquals('', c.operatingUnitName, 'OperatingUnitName should be empty.');
      c.getOperatingUnitValue();
      system.assertNotEquals('', c.operatingUnitName, 'OperatingUnitName should not be empty.');
    }
    
  }
  
  static testMethod void testGetfileName() {
    User u1 = Test_utils.createUser('Standard User');
    u1.Country__c = 'United States of America';
    insert u1;
    system.runAs(u1) {
      ExportBatchExtractProcessController c = new ExportBatchExtractProcessController();
      system.assertEquals('', c.operatingUnitName, 'OperatingUnitName should be empty.');
      ApexPages.currentPage().getParameters().put('ExportFile',exportFileTypes.CustomerFile.name() );
      String exportName = c.getfileName();
      system.assertNotEquals('', c.operatingUnitName, 'OperatingUnitName should not be empty.');
      system.assertNotEquals('', exportName);
    }
    u1.Country__c = 'United Kingdom';
    update u1;
    system.runAs(u1) {
      ExportBatchExtractProcessController c = new ExportBatchExtractProcessController();
      system.assertEquals('', c.operatingUnitName, 'OperatingUnitName should be empty.');
      ApexPages.currentPage().getParameters().put('ExportFile',exportFileTypes.PartnerFile.name() );
      String exportName = c.getfileName();
      system.assertNotEquals('', c.operatingUnitName, 'OperatingUnitName should not be empty.');
      system.assertNotEquals('', exportName);
    }
    u1.Country__c = 'France';
    update u1;
    system.runAs(u1) {
      ExportBatchExtractProcessController c = new ExportBatchExtractProcessController();
      system.assertEquals('', c.operatingUnitName, 'OperatingUnitName should be empty.');
      ApexPages.currentPage().getParameters().put('ExportFile',exportFileTypes.RoyaltiesFile.name() );
      String exportName = c.getfileName();
      system.assertNotEquals('', c.operatingUnitName, 'OperatingUnitName should not be empty.');
      system.assertNotEquals('', exportName);
    }
    u1.Country__c = 'New Zealand';
    update u1;
    system.runAs(u1) {
      ExportBatchExtractProcessController c = new ExportBatchExtractProcessController();
      system.assertEquals('', c.operatingUnitName, 'OperatingUnitName should be empty.');
      ApexPages.currentPage().getParameters().put('ExportFile',exportFileTypes.SummitFile.name() );
      String exportName = c.getfileName();
      system.assertNotEquals('', c.operatingUnitName, 'OperatingUnitName should not be empty.');
      system.assertNotEquals('', exportName);
    }
    u1.Country__c = 'Singapore';
    update u1;
    system.runAs(u1) {
      ExportBatchExtractProcessController c = new ExportBatchExtractProcessController();
      system.assertEquals('', c.operatingUnitName, 'OperatingUnitName should be empty.');
      ApexPages.currentPage().getParameters().put('ExportFile',exportFileTypes.RPMFile.name() );
      String exportName = c.getfileName();
      system.assertNotEquals('', c.operatingUnitName, 'OperatingUnitName should not be empty.');
      system.assertNotEquals('', exportName);
    }
    u1.Country__c = 'Australia';
    update u1;
    system.runAs(u1) {
      ExportBatchExtractProcessController c = new ExportBatchExtractProcessController();
      system.assertEquals('', c.operatingUnitName, 'OperatingUnitName should be empty.');
      ApexPages.currentPage().getParameters().put('ExportFile',exportFileTypes.RPMFile.name() );
      String exportName = c.getfileName();
      system.assertNotEquals('', c.operatingUnitName, 'OperatingUnitName should not be empty.');
      system.assertNotEquals('', exportName);
    }
    u1.Country__c = 'Netherlands';
    update u1;
    system.runAs(u1) {
      ExportBatchExtractProcessController c = new ExportBatchExtractProcessController();
      system.assertEquals('', c.operatingUnitName, 'OperatingUnitName should be empty.');
      ApexPages.currentPage().getParameters().put('ExportFile',exportFileTypes.RPMFile.name() );
      String exportName = c.getfileName();
      system.assertNotEquals('', c.operatingUnitName, 'OperatingUnitName should not be empty.');
      system.assertNotEquals('', exportName);
    }
    
  }
  
  private static testmethod void testExportBatchExtractProcessAPAC_PPMFormat(){
    // create test data
    Test_Utils tu = new Test_Utils();
    
    // NLG - Creating this trigger setting so that the webservice in UserTriggerHandler doesn't run
    TriggerSettings__c triggerSetting = new TriggerSettings__c();
    triggerSetting.Name = 'UserTrigger';
    triggerSetting.isActive__c = false;
    insert triggerSetting;  
    
    User currentUser = new User();
    currentUser.Id = UserInfo.getUserId();
    currentUser.Region__c = 'APAC';
    currentUser.Global_Business_Line__c = 'Marketing Services';
    currentUser.Business_Line__c = 'APAC Marketing Services';
    currentUser.Office_Location__c = 'Amsterdam';
    currentUser.Department__c = 5;
    currentUser.Payroll__c = 100;
    currentUser.Business_Unit__c = 'APAC MS Data Quality';
    update currentUser; 
    
    triggerSetting.IsActive__c = true;
    update triggerSetting;

    Account testAcc = Test_Utils.insertAccount();

    Contact con = new Contact (FirstName = 'Larry', LastName = 'Ellison',
                                AccountId = testAcc.Id, Email = 'larrye@email.com');
    insert con;

    Opportunity testOpp = Test_Utils.insertOpportunity(testAcc.Id);
    
    Address__c addrs1 = Test_Utils.insertAddress(true);
    
    Opportunity_Contact_Address__c opConAdrs = new Opportunity_Contact_Address__c();
    opConAdrs.Contact__c = con.Id;
    opConAdrs.Opportunity__c = testOpp.Id;
    opConAdrs.Address__c = addrs1.Id;
    opConAdrs.Role__c = Constants.OPPTY_CONTACT_ROLE_PURCHASE_LEDGER;
    insert opConAdrs;
     
    Export_Batch__c testBatch= new Export_Batch__c (Name='TestClass Batch');
    insert  testBatch;
          
    Order__c testOrder1 = Test_Utils.insertOrder(false, testAcc.Id, con.Id, testOpp.Id);
    testOrder1.Owner_BU_on_Order_Create_Date__c = 'EDQ';
    testOrder1.OwnerId = currentUser.Id;
    
    testOrder1.Finance_Invoice_Export_Batch__c=testBatch.id;

    Order__c testOrder2 = Test_Utils.insertOrder (false, testAcc.Id, con.Id, testOpp.Id );
    testOrder2.Owner_BU_on_Order_Create_Date__c = 'EDQ';
    testOrder2.OwnerId = currentUser.Id;
    testOrder2.Finance_Invoice_Export_Batch__c=testBatch.id;

    Order__c testOrder3 = Test_Utils.insertOrder (false, testAcc.Id, con.Id, testOpp.Id );
    testOrder3.Owner_BU_on_Order_Create_Date__c = 'EDQ';
    testOrder3.OwnerId = currentUser.Id;
    testOrder3.Finance_Invoice_Export_Batch__c=testBatch.id;
    testOrder3.Close_Date__c = system.today();

    Order__c testOrder4 = Test_Utils.insertOrder (false, testAcc.Id, con.Id, testOpp.Id );
    testOrder4.Owner_BU_on_Order_Create_Date__c = 'EDQ';
    testOrder4.OwnerId = currentUser.Id;
    testOrder4.Finance_Invoice_Export_Batch__c=testBatch.id;
    
    Product2 product = new Product2(Name = 'TestClass_test_Prod1');
    product.Global_Business_Line__c = 'Experian Data Quality';
    product.ProductCode='ADD0T';
    insert product;
        
    // Pricebook2 standard = [Select Id,IsActive From Pricebook2 Where IsStandard = true limit 1];
    // if (!standard.isActive) {
    //   standard.IsActive = true;
    //   update standard;
    // }
    
    List<Order__c> edqOrders = new List<Order__c>();
    edqOrders.add(testOrder1);
    edqOrders.add(testOrder2);
    edqOrders.add(testOrder3);
    edqOrders.add(testOrder4);
    insert edqOrders;
        
    Billing_Product__c billProd = Test_Utils.insertBillingProduct();
    billProd.IFRS15_Secondary_Revenue_Subaccount_Code__c='REV52300';
    update billProd;
      
    List<Order_Line_Item__c> ordLnList = new list<Order_Line_Item__c>();
    // create Order Line Item
    Order_Line_Item__c ordrli1 = Test_Utils.insertOrderLineItems(false, testOrder1.Id, billProd.Id);
    ordrli1.CurrencyIsoCode = Constants.CURRENCY_USD;    
    ordrli1.Product__c=product.id;
    ordrli1.Total__c=1500;
    ordrLi1.EDQ_Memo_Line__c='NADD0T05';
    ordLnList.add(ordrli1);
    Order_Line_Item__c ordrli2 = Test_Utils.insertOrderLineItems(false, testOrder2.Id, billProd.Id);
    ordrli2.CurrencyIsoCode = Constants.CURRENCY_USD;
    ordrli2.Product__c=product.id;
    ordrli2.Partner_Amount__c= 1100;
    ordrli2.Total__c=2500;
    ordrLi2.EDQ_Memo_Line__c='NADD0T05';
    ordLnList.add(ordrli2);
    Order_Line_Item__c ordrli3 = Test_Utils.insertOrderLineItems(false, testOrder3.Id, billProd.Id);
    ordrli3.CurrencyIsoCode = Constants.CURRENCY_USD;
    ordrli3.Product__c=product.id;
    ordrli3.Total__c=1500;
    ordrLi3.EDQ_Memo_Line__c='NADD0T05';
    ordLnList.add(ordrli3);
    Order_Line_Item__c ordrli4 = Test_Utils.insertOrderLineItems(false, testOrder4.Id, billProd.Id);
    ordrli4.CurrencyIsoCode = Constants.CURRENCY_USD;
    ordrli4.Product__c=product.id;
    ordrli4.Total__c=1500;
    ordrLi4.EDQ_Memo_Line__c='NADD0T05';
    ordLnList.add(ordrli4);
      
    insert ordLnList;
      
    Royalty__c royalty1 = new Royalty__c(Name = 'test royalty #1', Line_Item_Reference_Number__c='1234',Order_Line_Item__c=ordrli3.id);
    insert royalty1;    
        
    Royalty__c royalty2 = new Royalty__c(Name = 'test royalty #2', Line_Item_Reference_Number__c='1234',Order_Line_Item__c=ordrli2.id);
    insert royalty2; 

    // start test
    Test.startTest();
    
    ExportBatchExtractProcessController testExportBatchController = new ExportBatchExtractProcessController();
    
    ApexPages.currentPage().getParameters().put('BatchID',testBatch.id );
    ApexPages.currentPage().getParameters().put('ExportFile',exportFileTypes.CustomerFile.name() );
    ApexPages.currentPage().getParameters().put('Format','PMM');    
    testExportBatchController.exportFileProcess();
    testExportBatchController.getfileName();
    
    ApexPages.currentPage().getParameters().put('BatchID',testBatch.id );
    ApexPages.currentPage().getParameters().put('ExportFile',exportFileTypes.PartnerFile.name() );
    ApexPages.currentPage().getParameters().put('Format','PMM');    
    testExportBatchController.exportFileProcess();
    testExportBatchController.getfileName();
    
    ApexPages.currentPage().getParameters().put('BatchID',testBatch.id );
    ApexPages.currentPage().getParameters().put('ExportFile',exportFileTypes.RoyaltiesFile.name() );
    ApexPages.currentPage().getParameters().put('Format','PMM');    
    testExportBatchController.exportFileProcess();
    testExportBatchController.getfileName();
    
    ApexPages.currentPage().getParameters().put('BatchID',testBatch.id );
    ApexPages.currentPage().getParameters().put('ExportFile',exportFileTypes.SummitFile.name() );
    ApexPages.currentPage().getParameters().put('Format','PMM');    
    testExportBatchController.exportFileProcess();
    testExportBatchController.getfileName();
    
    ApexPages.currentPage().getParameters().put('BatchID',testBatch.id );
    ApexPages.currentPage().getParameters().put('ExportFile',exportFileTypes.RPMFile.name() );
    ApexPages.currentPage().getParameters().put('Format','PMM');    
    testExportBatchController.exportFileProcess();
    testExportBatchController.getfileName();
    
    ApexPages.currentPage().getParameters().put('BatchID',testBatch.id );
    ApexPages.currentPage().getParameters().put('ExportFile',exportFileTypes.DPFile.name() );
    ApexPages.currentPage().getParameters().put('Format','PMM');    
    testExportBatchController.exportFileProcess();
    testExportBatchController.getfileName();
    
    ApexPages.currentPage().getParameters().put('BatchID',testBatch.id );
    ApexPages.currentPage().getParameters().put('ExportFile',exportFileTypes.DPCustomerFile.name() );
    ApexPages.currentPage().getParameters().put('Format','PMM');    
    testExportBatchController.exportFileProcess();
    testExportBatchController.getfileName();
    
    ApexPages.currentPage().getParameters().put('BatchID',testBatch.id );
    ApexPages.currentPage().getParameters().put('ExportFile',exportFileTypes.EBACustomerFile.name() );
    ApexPages.currentPage().getParameters().put('Format','EBA');    
    testExportBatchController.exportFileProcess();
    testExportBatchController.getfileName();
    
    ApexPages.currentPage().getParameters().put('BatchID',testBatch.id );
    ApexPages.currentPage().getParameters().put('ExportFile',exportFileTypes.EBATransFile.name() );
    ApexPages.currentPage().getParameters().put('Format','EBA');    
    testExportBatchController.exportFileProcess();
    testExportBatchController.getfileName();

    ApexPages.currentPage().getParameters().put('BatchID',testBatch.id );
    ApexPages.currentPage().getParameters().put('ExportFile',exportFileTypes.EBATransFileNew.name() );
    ApexPages.currentPage().getParameters().put('Format','EBA');    
    testExportBatchController.exportFileProcess();
    testExportBatchController.getfileName();



    ApexPages.currentPage().getParameters().put('BatchID',testBatch.id );
    ApexPages.currentPage().getParameters().put('ExportFile',exportFileTypes.EBATransCreditFile.name() );
    ApexPages.currentPage().getParameters().put('Format','EBA');    
    testExportBatchController.exportFileProcess();
    testExportBatchController.getfileName();


    Test.stopTest();
    
    
  }  
  
  @testSetup
  private static void prepareData() {
    
    Report_Extract_Templates__c reportExtractTemplateRec = new Report_Extract_Templates__c(
      Name = 'Oracle Customer File', 
      Col1__c = 'Billing_Account__c',
      Col2__c = 'Account__r.Experian_ID__c',
      Col3__c = 'Transform--OperatingUnit',
      Col5__c = 'Account__r.Company_Registration__c',
      Col10__c = 'Transform--CustomerSiteReferenceNumber',
      Col12__c = 'Transform--CountryCode',
      Col13__c = 'Billing_Address__r.Address_1__c',
      Col14__c = 'Billing_Address__r.Address_2__c',
      Col17__c = 'Billing_Address__r.City__c',
      Col18__c = 'Transform--StateCode',
      Col19__c = 'Billing_Address__r.Postcode__c',
      Col20__c = 'Billing_Address__r.Province__c',
      Col21__c = 'Billing_Address__r.County__c',
      Col22__c = 'Transform-USExperianID',
      Col84__c = 'Account__r.VBM_Code__c',
      Col87__c = 'Account__r.Is_Partner__c',
    // COL48__C='Transform--NAEDQAcctRules',
    // COL49__C='Transform--NAEDQAcctStartDate',
    // COL50__C='Transform--NAEDQDefGLCode',
    // COL30__C='Order__r.Status__c',
      Col88__c = 'EOF'
    );
    insert reportExtractTemplateRec;
    Report_Extract_Templates__c repTmp1 = new Report_Extract_Templates__c(
      Name = 'MemoLnTypeOfSaleI',
      Col1__c = 'Per Day',
      Col2__c = 'Session',
      Col3__c = 'Server Charge',
      Col4__c = 'External Clicks - post pay',
      Col5__c = 'Service Charge',
      Col6__c = 'Day',
      Col7__c = 'Setup Fee - Day',
      Col8__c = 'Per Record',
      Col9__c = 'EOF'
    // COL48__C='Transform--NAEDQAcctRules',
    // COL49__C='Transform--NAEDQAcctStartDate',
    // COL50__C='Transform--NAEDQDefGLCode'
    // COL10__C='Order__r.Status__c'
    );
    insert repTmp1;
    Report_Extract_Templates__c repTmp2 = new Report_Extract_Templates__c(
      Name = 'MemoLnTypeOfSaleL',
      Col1__c = 'Annual License',
      Col2__c = 'External Clicks',
      Col3__c = 'Per Seat',
      Col4__c = 'Bulk Processing',
      Col5__c = 'Internal Click',
      Col6__c = 'EOF'
    // COL48__C='Transform--NAEDQAcctRules',
    // COL49__C='Transform--NAEDQAcctStartDate',
    // COL50__C='Transform--NAEDQDefGLCode'
    // COL10__C='Order__r.Status__c'
    );
    insert repTmp2;
    
    Report_Extract_Templates__c repTmp3 = new Report_Extract_Templates__c(
      Name = 'Oracle Partner File',
      Col1__c = 'Transform--MemoLn',
      Col2__c = 'Order__r.Partner__r.Name',
      Col3__c = 'Order__r.Close_Date__c',
      Col4__c = 'Order__r.Close_Date__c',
      Col6__c = 'Id',
      Col7__c = 'Order__r.Account__r.Experian_ID__c',
      Col8__c = 'Order__r.Account__r.Name',
      Col10__c = 'Order__r.CurrencyIsoCode',
      Col11__c = 'Partner_Amount__c',
      Col16__c = 'Start_Date__c',
      COL48__C='Transform--NAEDQAcctRules',
      COL49__C='Transform--NAEDQAcctStartDate',
      COL50__C='Transform--NAEDQDefGLCode',
      COL20__C='Order__r.Status__c',
      Col17__c = 'EOF'
    );
    insert repTmp3;
    
    Report_Extract_Templates__c repTmp4 = new Report_Extract_Templates__c(
      Name = 'Oracle Royalties File',
      Col1__c = 'Transform--MemoLn',
      Col2__c = 'Royalty_Type__c',
      Col3__c = 'Order_line_item__r.Order__r.Close_Date__c',
      Col4__c = 'Order_line_item__r.Order__r.Close_Date__c',
      Col6__c = 'Order_Line_Item__r.Id',
      Col7__c = 'Order_line_item__r.Order__r.Account__r.Experian_ID__c',
      Col8__c = 'Order_line_item__r.Order__r.Account__r.Name',
      Col9__c = 'DT--TODAY',
      Col10__c = 'Order_line_Item__r.Order__r.CurrencyIsoCode',
      Col11__c = 'Amount__c',
      COL48__C='Transform--NAEDQAcctRules',
      COL49__C='Transform--NAEDQAcctStartDate',
      COL50__C='Transform--NAEDQDefGLCode',
      COL20__C='Order_line_item__r.Order__r.Status__c',
      Col17__c = 'EOF'
    );
    insert repTmp4;
    Report_Extract_Templates__c repTmp5 = new Report_Extract_Templates__c(
            Name = 'Oracle Transaction (Summit) File',
            Col10__c = 'HC--EDQ',
            Col12__c = 'Transform--Trans',
            Col13__c = 'GQ--Order',
            Col14__c = 'CRM_Product_Name__c',
            Col15__c = 'HC--1',
            Col16__c = 'Transform--MemoLn',
            Col17__c = 'Sales_Price__c',
            Col18__c = 'HC--F',
            Col19__c = 'Sales_Price__c',
            Col1__c  = 'HC--QAS',
            Col20__c = 'Delivery_Method__c',
            Col21__c = 'Order__r.Shipping_Address_Id__c',
            Col25__c = 'HC--0',   
            Col29__c = 'HC--Accounts Payable',          
            Col2__c  = 'Order__r.Status__c',
            Col30__c = 'Transform--Email',
            Col31__c = 'Transform--ContactEmail',
            Col32__c = 'Order__r.Owner_Employee_Num__c',
            Col36__c = 'HC--1370',
            Col37__c = 'HC--US',
            Col38__c = 'HC--370',
            Col39__c = 'HC--000000.21001000.00000000.00000000.0000',
            Col3__c  = 'Order__r.Order_Number__c',
            Col48__c = 'Transform--NAEDQAcctRules',
            Col49__c = 'Transform--NAEDQAcctStartDate',
            Col4__c  = 'Order__r.Account__r.Name',
            Col50__c = 'Order__r.Shipping_Address__r.Address_1__c',
            Col53__c = 'Order__r.Shipping_Address__r.Address_2__c',
            Col54__c = 'Order__r.Shipping_Address__r.City__c',
            Col55__c = 'Order__r.Shipping_Address__r.PostCode__c',
            Col56__c = 'Order__r.Shipping_Address__r.Country__c',
            Col57__c = 'Transform--NAEDQDefGLCode',
            Col5__c  = 'Order__r.Account__r.Experian_ID__c',
            Col80__c = 'EOF',
            Col7__c  = 'Order__r.Order_Number__c',
            Col8__c  = 'Order__r.PO_Number__c',
            Col9__c  = 'Order__r.Close_Date__c',
            Col60__c='Transform--StartDate',
            Col61__c='Transform--EndDate',
            Col62__c='Sales_Price__c',
            Col63__c='Transform--TotalAmount',
             Col64__c='Transform--APACInvoicingRule'
    );
    
    Report_Extract_Templates__c repTmp6 = new Report_Extract_Templates__c(
            Name = 'Oracle Trans (Summit) NON US',
            Col10__c = 'HC--EDQ',
            Col11__c = 'Order__r.CurrencyIsoCode',
            Col12__c = 'Transform--Trans',
            Col13__c = 'GQ--Order',
            Col14__c = 'CRM_Product_Name__c',
            Col15__c = 'HC--1',
            Col16__c = 'Transform--MemoLn',
            Col17__c = 'Sales_Price__c',
            Col19__c = 'Sales_Price__c',
            Col1__c  = 'HC--QAS',
            Col20__c = 'Delivery_Method__c',
            Col22__c = 'Order__r.Account__r.Name',
            Col23__c = 'Order__r.Shipping_Contact__r.FirstName',
            Col24__c = 'Order__r.Shipping_Contact__r.LastName',
            Col25__c = 'Order__r.Shipping_Address__r.Address_1__c',
            Col26__c = 'Order__r.Shipping_Address__r.Address_2__c',
            Col29__c = 'Order__r.Shipping_Address__r.City__c',          
            Col2__c = 'Order__r.Status__c',
            Col30__c = 'Order__r.Shipping_Address__r.PostCode__c',
            Col31__c = 'Order__r.Shipping_Address__r.Country__c',
            Col32__c = 'Order__r.Owner_Employee_Num__c',
            Col35__c = 'HC--0',
            Col39__c = 'HC--Accounts Payable',
            Col3__c  = 'Order__r.Order_Number__c',
            Col4__c  = 'Order__r.Account__r.Name',
            Col5__c  = 'Order__r.Account__r.Experian_ID__c',
            Col62__c = 'EOF',
            Col6__c = 'Order__r.Order_Number__c',
            Col7__c = 'Transform--CustomerSiteReferenceNumber',
            Col8__c = 'Transform--OptyOrderPOValue',
            Col9__c = 'Transform--CloseDate'
     );
    
    insert repTmp5;
    insert repTmp6;
    
    
    Report_Extract_Templates__c repTmp7 = new Report_Extract_Templates__c(
      Name = 'RPM File',
      Col13__c = 'Order__r.Billing_Address__r.Address_1__c',
            Col19__c = 'Order__r.Billing_Address__r.Postcode__c',
            Col2__c = 'HC--SFDC',
            Col31__c = 'Order__r.Owner.Name',
            Col33__c = 'HC--0',
            Col35__c = 'HC--67',
            Col39__c = 'Order__r.PO_Number__c',
            Col44__c = 'HC--1',
            Col46__c = 'Sales_Price__c',
            Col48__c = 'HC--1',
            Col4__c = 'HC--N',
            Col51__c = 'Order__r.CurrencyIsoCode',
            Col55__c = 'DT--TODAY',
            Col6__c = 'DT--TODAY',
            Col12__c = 'HC--67',
            Col14__c = 'Order__r.Billing_Address__r.Address_2__c',
            Col16__c = 'Order__r.Billing_Address__r.City__c',
            Col18__c = 'Transform--CountryCode',
            Col1__c = 'SQ--',
            Col21__c = 'HC--Accounts Payable',
            Col27__c = 'DT--TODAY',
            Col32__c = 'HC--0',
            Col34__c = 'Order__r.Billing_Contact__r.Name',
            Col36__c = 'Product__r.Description',
            Col38__c = 'CRM_Product_Name__c',
            Col41__c = 'Order__r.Order_Number__c',
            Col45__c = 'Sales_Price__c',
            Col47__c = 'HC--1',
            Col56__c = 'EOF',
            Col5__c = 'Order__r.Order_Number__c',
            Col8__c = 'Order__r.Billing_Account__c',
            Col9__c = 'Transform--ProductBU',
            //COL58__C='Transform--NAEDQAcctRules',
            //COL59__C='Transform--NAEDQAcctStartDate',
            //COL60__C='Transform--NAEDQDefGLCode',
            //COL10__C='Order__r.Status__c'
            Col89__c = 'EOF'
        );
        insert repTmp7;
        
        Report_Extract_Templates__c repTmp8 = new Report_Extract_Templates__c(
      Name = 'RPM HDRTLR',
      Col1__c = 'HC--HDR/TLR',
            Col2__c = 'SEQ',
            Col3__c = '1484',
            Col4__c = 'DT--TODAY',
            Col5__c = 'RunningSeq--433',
            // COL48__C='Transform--NAEDQAcctRules',
            // COL49__C='Transform--NAEDQAcctStartDate',
            // COL50__C='Transform--NAEDQDefGLCode'
            // COL10__C='Order__r.Status__c'
            Col89__c = 'EOF'
      );
      insert repTmp8;
      
      Report_Extract_Templates__c repTmp9 = new Report_Extract_Templates__c(
      Name = 'DP File',
            Col19__c = 'HC--30 DAYS',
            //Col24__c = 'product__r.name',
            Col26__c = 'Quantity__c',
            Col28__c = 'HC--LINE',
            Col2__c = 'HC--SG EAP OU',
            Col4__c = 'Transform--DPUniqueRef',
            Col59__c = 'Transform--OwnerName',
            Col60__c = 'EOF',
            Col6__c = 'HC--SG DPI Auto Inv',
            Col14__c='Order__r.CurrencyIsoCode',
            Col1__c='HC--DP Auto Inv',
            Col21__c='Transform--DPCustomerID',
            Col23__c='DP_Product_Package_Code__c',
            Col27__c='Total__c',
            Col29__c='Transform--VATTaxCode',
            Col58__c='order__r.Owner_Employee_Num__c',
            Col5__c='HC--INVOICE',
            Col7__c='Transform--CloseDate',
            //Col8__c='Transform--EndDate',
            Col87__c='Transform--APACInvoicingRule',
           // Col88__c='Transform--StartDate',
             Col89__c = 'EOF'
             //COL48__C='Transform--NAEDQAcctRules'
             //COL49__C='Transform--NAEDQAcctStartDate',
             //COL50__C='Transform--NAEDQDefGLCode',
             //COL10__C='Order__r.Status__c'
      );
      insert repTmp9;
      
      Report_Extract_Templates__c repTmp10 = new Report_Extract_Templates__c(
      Name = 'DP Customer File',
            Col10__c = 'Transform--DPCustomerID',
            Col12__c = 'Transform--CountryCode',
            Col13__c = 'order__r.Billing_Address_1__c',
            Col14__c = 'order__r.Billing_Address_2__c',
            Col17__c = 'order__r.Billing_City__c',
            Col18__c = 'order__r.Billing_State__c',
            Col19__c = 'order__r.Billing_PostCode_Zip__c',
            Col1__c  = 'order__r.billing_contact__r.account.name',
            Col22__c = 'HC--Y',
            Col26__c = 'Transform--VATTaxCode',
            Col2__c  = 'Transform--DPCustomerID',
            Col3__c  = 'HC--SG EAP OU',
            Col41__c = 'order__r.billing_contact__r.email',
            Col43__c = 'order__r.billing_contact__r.lastname',
            Col44__c = 'order__r.billing_contact__r.firstname',
            Col47__c = 'HC--BILL TO',
            Col50__c = 'order__r.billing_contact__r.Phone',
            Col52__c = 'HC--PHONE',
            Col54__c = 'order__r.billing_contact__r.email',
            Col55__c = 'HC--SG-DP-Standard',
            Col56__c = 'HC--Asyraf',
            Col57__c = 'HC--30 NET',
            Col58__c = 'HC--Y',
            Col60__c = 'HC--SG EAP Monthly',
            Col62__c = 'HC--Y',
            Col88__c = 'HC--Y',
            Col8__c = 'HC--SG-DP-Standard',
            Col9__c = 'HC--DPI',
            //COL48__C='Transform--NAEDQAcctRules',
            //COL49__C='Transform--NAEDQAcctStartDate',
            //COL70__C='Transform--NAEDQDefGLCode',
            //COL11__C='Order__r.Status__c',
            Col89__c = 'EOF'
       );
       insert repTmp10;    
       
    Report_Extract_Templates__c repTmp11 = new Report_Extract_Templates__c(
        Name = 'APACPMM',
        Col10__c = 'Transform--PMM',
        Col11__c = 'Order__r.CurrencyIsoCode',
        Col12__c = 'Transform--Trans',
        Col13__c = 'GQ--Order',
        Col14__c = 'Product__r.Name',
        Col15__c = 'HC--1',
        Col16__c = 'Transform--PDCode',
        Col17__c = 'Sales_Price__c',
        Col19__c = 'Sales_Price__c',
        Col1__c = 'Transform--PMM',
        Col20__c = 'Delivery_Method__c',    
        Col22__c = 'Order__r.Account__r.Name',
        Col23__c = 'Order__r.Billing_Contact__r.FirstName',
        Col24__c = 'Order__r.Billing_Contact__r.LastName',
        Col25__c = 'Order__r.Billing_Address__r.Address_1__c',
        Col26__c = 'Order__r.Billing_Address__r.Address_2__c',  
        Col29__c = 'Order__r.Billing_Address__r.City__c',
        Col2__c = 'Order__r.Status__c',
        Col30__c = 'Order__r.Billing_Address__r.PostCode__c',
        Col31__c = 'Order__r.Billing_Address__r.Country__c',    
        Col35__c = 'HC--0', 
        Col39__c = 'HC--Accounts Payable',
        Col3__c = 'Order__r.Opportunity__r.Oppty_ID_18_chars__c',
        Col40__c = 'Order__r.Opportunity__r.Oppty_ID_18_chars__c',
        Col41__c = 'HC--In advance',
        Col42__c = 'Transform--OracleAccountingRules',
        Col43__c = 'Start_Date__c',
        Col44__c = 'End_Date__c',
        Col4__c = 'Order__r.Account__r.Name',   
        Col5__c = 'Order__r.Account__r.Experian_ID__c', 
        Col62__c = 'EOF',
        Col6__c = 'Order__r.Opportunity__r.Oppty_ID_18_chars__c',
        Col7__c = 'Transform--CustomerSiteReferenceNumber',
        Col8__c = 'Order__r.PO_Number__c',
        Col9__c = 'Order__r.Invoice_Delivery_Date__c'
       );
       insert repTmp11;    
       
      Report_Extract_Templates__c repTmp12 = new Report_Extract_Templates__c(
      NAME='EBA Customer',
        COL11__C='Transform--EBA_Cust_Site_Ref',
        COL12__C='Order__r.Billing_Account__c',
        COL13__C='Transform--CountryCode',
        COL14__C='order__r.Billing_Address__r.Address_1__c',
        COL15__C='order__r.Billing_Address__r.Address_2__c',
        COL18__C='order__r.Billing_Address__r.City__c',
        COL19__C='Transform--StateCode',
        COL1__C='Order__r.Billing_Account__c',
        COL20__C='order__r.Billing_Address__r.Postcode__c',
        COL22__C='order__r.Billing_Address__r.Country__c',
        COL27__C='HC--STANDARD UK VAT',
        COL2__C='Transform--EBA_Cust_Head_Ref',
        COL35__C='Transform--OwnerName',
        COL38__C='order__r.owner.Phone',
        COL3__C='Transform--EBA_Insert_Update',
        COL40__C='HC--Phone',
        COL42__C='order__r.owner.email',
        COL44__C='order__r.Billing_Contact__r.FirstName',
        COL45__C='order__r.Billing_Contact__r.LastName',
        COL46__C='order__r.Billing_Contact__r.Salutation',
        COL47__C='order__r.Billing_Contact__r.Title',
        COL4__C='HC--EXP_UK_ELI_OU',
        COL51__C='order__r.Billing_Contact__r.phone',
        COL54__C='order__r.Account__r.Website',
        COL55__C='order__r.Billing_Contact__r.email',
        COL58__C='HC--30 NET',
        COL64__C='Transform--EBA_Payment_Receipt',
        COL6__C='Order__r.account__r.Company_Registration__c', 
        COL88__C='EOF'

       );
       insert repTmp12;  
       
       Report_Extract_Templates__c repTmp13 = new Report_Extract_Templates__c(
      NAME='EBA Trans',
        COL13__C='order__r.PO_Number__c',
        COL15__C='Order__r.CurrencyIsoCode',
        COL16__C='Transform--EBA_Cust_Head_Ref',
        COL17__C='Transform--EBA_Payment_Receipt',
        COL18__C='Transform--EBA_Payment_Terms',
        COL1__C='HC--UK RSK AUTO TRX',
        COL20__C='Transform--EBA_Cust_Site_Ref',
        COL21__C='SQ--Order',
        COL22__C='product__r.Description',
        COL23__C='EBA_MemoLine__c',
        COL24__C='HC--Each',
        COL25__C='HC--1',
        COL26__C='Sales_Price__c',
        COL27__C='HC--LINE',
        COL28__C='Transform--EBA_Tax_Code',
        COL2__C='HC--EXP_UK_ELI_OU',
        COL4__C='Transform--EBA_Trans_Header_Ref',
        COL5__C='HC--Invoice',
        COL62__C='EOF',
        COL6__C='Transform--EBA_Trans_Type',
        COL7__C='Transform--EBA_Transaction_Date',
        COL8__C='DT--TODAY',
         
        COL10__C='Order__r.Status__c',
        COL88__c='Transform--EBA_Tax_RevSch',
        Col89__c = 'EOF'
       );
       insert repTmp13;      

       Report_Extract_Templates__c repTmp14 = new Report_Extract_Templates__c(
        Name='EBA Trans New',
        Col10__c = 'Order__r.Billing_Country__c',
        Col11__c = 'Order__r.Billing_PostCode_Zip__c',
        Col12__c = 'Order__r.Billing_Contact__r.Email',
        Col13__c = 'Order__r.Billing_Contact__r.Phone',
        Col14__c = 'Order__r.Account__r.Company_Registration__c',
        Col15__c = 'Order__r.Account__r.SIC',
        Col16__c = 'Order__r.Account__c',
        Col17__c = 'Order__r.Id',
        Col18__c = 'Order__r.Close_Date__c',
        Col19__c = 'Order__r.Contract_Start_Date__c',
        Col1__c = 'Account_Name__c',
        Col20__c = 'Contract_Term__c',
        Col21__c = 'Installments_Splits__c',
        Col22__c = 'Order__r.Total__c',
        Col23__c = 'Order__r.Payment_Method__c',
        Col24__c = 'Order__r.Opportunity__c',
        Col25__c = 'CRM_Product_Name__c',
        Col26__c = 'Part_Number__c',    
        Col28__c = 'Order__r.Contract_End_Date__c',
        Col29__c = 'Order__r.PO_Number__c',
        Col2__c = 'Order__r.Billing_Contact__r.Salutation',
        Col30__c = 'Order__r.Owner.name',
        Col31__c = 'DT--TODAY',
        Col35__c = 'EOF',
        Col3__c = 'Order__r.Billing_Contact__r.FirstName',  
        Col4__c = 'Order__r.Billing_Contact__r.LastName',
        Col5__c = 'Order__r.Billing_Address_1__c',  
        Col6__c = 'Order__r.Billing_Address_2__c',  
        Col7__c = 'Order__r.Billing_City__c',   
        Col8__c = 'Order__r.Billing_State__c',
        Col9__c = 'Order__r.Billing_Address__r.Province__c'
         );
         insert repTmp14;     

         Report_Extract_Templates__c repTmp15 = new Report_Extract_Templates__c(
          Name = 'EBA Trans Credits',
          Col10__c= 'Order_Line_Item__r.Order__r.Billing_Country__c',
          Col11__c= 'Order_Line_Item__r.Order__r.Billing_PostCode_Zip__c',
          Col12__c= 'Order_Line_Item__r.Order__r.Billing_Contact__r.Email',
          Col13__c= 'Order_Line_Item__r.Order__r.Billing_Contact__r.Phone',
          Col14__c= 'Order_Line_Item__r.Order__r.Account__r.Company_Registration__c',
          Col15__c= 'Order_Line_Item__r.Order__r.Account__r.SIC',
          Col16__c= 'Order_Line_Item__r.Order__r.Account__r.Id',
          Col17__c= 'Order_Line_Item__r.Order__r.Id',
          Col18__c= 'Order_Line_Item__r.Order__r.Close_Date__c',
          Col19__c= 'Order_Line_Item__r.Order__r.Contract_Start_Date__c',
          Col1__c= 'Order_Line_Item__r.Account_Name__c',
          Col20__c= 'Order_Line_Item__r.Contract_Term__c',
          Col21__c= 'Order_Line_Item__r.Installments_Splits__c',
          Col22__c= 'Amount__c',
          Col23__c= 'Order_Line_Item__r.Order__r.Payment_Method__c',
          Col24__c= 'Order_Line_Item__r.Order__r.Opportunity__c',
          Col25__c= 'Order_Line_Item__r.CRM_Product_Name__c',
          Col26__c= 'Name',
          Col28__c= 'Order_Line_Item__r.Order__r.Contract_End_Date__c',
          Col29__c= 'Order_Line_Item__r.Order__r.PO_Number__c',
          Col2__c= 'Order_Line_Item__r.Order__r.Billing_Contact__r.Salutation',
          Col30__c= 'Is_Cancelled__c',
          Col31__c= 'Reason__c',
          Col32__c= 'DT--TODAY',
          Col33__c= 'EOF',
          Col3__c= 'Order_Line_Item__r.Order__r.Billing_Contact__r.FirstName',  
          Col4__c= 'Order_Line_Item__r.Order__r.Billing_Contact__r.LastName',
          Col5__c= 'Order_Line_Item__r.Order__r.Billing_Address_1__c',
          Col6__c= 'Order_Line_Item__r.Order__r.Billing_Address_2__c',  
          Col7__c= 'Order_Line_Item__r.Order__r.Billing_City__c',   
          Col8__c= 'Order_Line_Item__r.Order__r.Billing_State__c',
          Col9__c= 'Order_Line_Item__r.Order__r.Billing_Address__r.Province__c'
           );
           insert repTmp15;
  }
  

}