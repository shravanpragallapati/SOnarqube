/**=========================================================================================
 * Name           : ProductMasterTriggerHandler_Test
 * Description    : Unit test coverage for ProductMasterTriggerHandler.cls
 * Created Date   : Oct 22th, 2014
 * Created By     : Pallavi Sharma (Appirio)
 *
 * Date Modified                Modified By                  Description of the update
 * 7th, March 2017              James Wills                  DRM:W-006536 Added section to test automated creation and deletion of Product_Region__c records.
 * Apr 16th 2020                Mauricio Murillo             Case 02437131- Removed restriction to create products when life cycle is Beta*
 *==============================================================================================*/
@isTest
private class ProductMasterTriggerHandler_Test {

  static User usr;
  static CPQ_Settings__c testCPQSetting;
  static{
    testCPQSetting = CPQ_Settings__c.getInstance('CPQ');
     if(testCPQSetting == null){
     testCPQSetting= new CPQ_Settings__c ();
         testCPQSetting.Name = 'CPQ';
         testCPQSetting.Company_Code__c= 'Experian';
         testCPQSetting.CPQ_API_Access_Word__c = 'Accessword';
         testCPQSetting.CPQ_API_Endpoint__c= 'https://test.webcomcpq.com/';
         testCPQSetting.CPQ_API_UserName__c= 'TestUser#Experian';
         testCPQSetting.Integration_Batchable_Time_Wait__c= 2;
         testCPQSetting.CPQ_API_Host__c = 'rssandbox.webcomcpq.com';
         Insert testCPQSetting;
     }else{
         testCPQSetting.Integration_Batchable_Time_Wait__c= 2;
         update testCPQSetting;
     }

    usr = Test_Utils.createUser(Constants.PROFILE_SYS_ADMIN);
    usr.Business_Unit__c = Constants.USER_GBL_CREDIT_SERVICES;
    usr.Country__c = null;
    usr.Region__c = null;
    insert usr;
  }

  static testMethod void unit_test() {

    System.runAs( usr ) {
      Test.startTest();
      Product_Master__c productMaster = Test_Utils.createProductMaster(false);
      productMaster.Product_life_cycle__c = 'Development';
      insert productMaster;
            
      Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        
        // Run an update DML on the Pricebook2 record
        // This is the weird workaround that enables IsStandard to become true
        // on the PricebookEntry record
        update standardPricebook;

      system.assert([SELECT Id FROM Product2 WHERE Product_Master__c =: productMaster.Id] != null);

      //Country__c country = Test_Utils.createCountry(true);
      //Region__c region   = Test_Utils.createRegion(true);
      //country.Region__c  = region.id;
      //update country;

      Region__c region1          = new Region__c(Name='North America');
      Region__c region2          = new Region__c(Name='UK&I');
      List<Region__c> regionList = new List<Region__c>{region1,region2};
      insert regionList;

      Country__c country1 = new Country__c(Name='United States',  Region__c = regionList[0].id );
      Country__c country2 = new Country__c(Name='Canada',         Region__c = regionList[0].id );
      Country__c country3 = new Country__c(Name='United Kingdom', Region__c = regionList[1].id);
      Country__c country4 = new Country__c(Name='Ireland',        Region__c = regionList[1].id);
      List<Country__c> countryList = new List<Country__c>{country1, country2, country3, country4};
      insert countryList;


      Billing_Product__c billingProduct = Test_Utils.createBillingProduct(false);
      billingProduct.Product_Master__c = productMaster.Id;
      insert billingProduct;


      //DRM:W-006536
      ProductMasterUpdateHelper.isRecursive=false;
      Product_Country__c productCountry = Test_Utils.createProductCountry(false, countryList[0].id);
      productCountry.Product_Master__c = productMaster.Id;
      insert productCountry;
      System.assert([SELECT id FROM Product_Region__c WHERE Region__r.Name = 'North America'].isEmpty()==false, 'Product_Region__c for North America has not been created.'
      + [SELECT id, Region__r.Name FROM Product_Region__c LIMIT 1].Region__r.Name);

      ProductMasterUpdateHelper.isRecursive=false;
      Product_Country__c productCountry2 = Test_Utils.createProductCountry(false, countryList[1].id);
      productCountry2.Product_Master__c = productMaster.Id;
      insert productCountry2;
      //Assertion fails if seeAllData is set to true
      //System.assert([SELECT id FROM Product_Region__c WHERE Product_Master__c = :productMaster.id AND Region__r.Name = 'North America'].size()==1, 'Two Product_Region__c records created for North America.');

      ProductMasterUpdateHelper.isRecursive=false;
      Product_Country__c productCountry3 = Test_Utils.createProductCountry(false, countryList[2].id);
      productCountry3.Product_Master__c = productMaster.Id;
      insert productCountry3;
      System.assert([SELECT id FROM Product_Region__c WHERE Product_Master__c = :productMaster.id AND Region__r.Name = 'UK&I'].isEmpty()==false, 'Product_Region__c for UK&I has not been created.');

      ProductMasterUpdateHelper.isRecursive=false;
      delete productCountry2;
      System.assert([SELECT id FROM Product_Region__c WHERE Product_Master__c = :productMaster.id AND Region__r.Name = 'North America'].isEmpty()==false, 'Product_Region__c for North America has been deleted.');

      ProductMasterUpdateHelper.isRecursive=false;
      delete productCountry3;
      System.assert([SELECT id FROM Product_Region__c WHERE Product_Master__c = :productMaster.id AND Region__r.Name = 'UK&I'].isEmpty()==true, 'Product_Region__c for UK&I has not been deleted.');

      //DRM:W-006536

      //DRM:W-006536 Commented out as this is now generated automatically
      //Product_Region__c productRegion = Test_Utils.createProductRegion(false, region.Id);
      //productRegion.Product_Master__c = productMaster.Id;
      //insert productRegion;
      //DRM:W-006536

      ProductMasterUpdateHelper.isRecursive=false;
      productMaster.Product_life_cycle__c = 'Sell';
      productMaster.CpqTableEntryId__c='aaa';
      productMaster.Product_Name__c = 'test';
      productMaster.Name = 'test';
      productMaster.Drmid__c = 'DRMID_1';
      productMaster.CPQ_Sync_Product_Detail__c=true;
      update productMaster;

      ProductMasterUpdateHelper.isRecursive=false;
      Billing_Product__c billingProduct1 = Test_Utils.createBillingProduct(false);
      billingProduct1.Product_Master__c = productMaster.Id;
      insert billingProduct1;
      ProductMasterUpdateHelper.isRecursive=false;
      Product_Country__c productCountry1 = Test_Utils.createProductCountry(false, countryList[0].Id);
      productCountry1.Product_Master__c = productMaster.Id;
      insert productCountry1;
      ProductMasterUpdateHelper.isRecursive=false;
      Product_Region__c productRegion1 = Test_Utils.createProductRegion(false, regionList[0].Id);
      productRegion1.Product_Master__c = productMaster.Id;
      insert productRegion1;
      ProductMasterUpdateHelper.isRecursive=false;
      update productCountry1;
      ProductMasterUpdateHelper.isRecursive=false;
      update productRegion1;
      ProductMasterUpdateHelper.isRecursive=false;
      billingProduct1.name = 'Test';
      update billingProduct1;
      ProductMasterUpdateHelper.isRecursive=false;
      productMaster.Product_life_cycle__c = 'Renewal only';
      update productMaster;

      system.assert([SELECT Id, Product__c FROM Billing_Product__c WHERE ID =: billingProduct.Id].Product__c != null);

      system.assert([SELECT Id, Product__c FROM Product_Country__c WHERE ID =: productCountry.Id].Product__c != null);

      //system.assert([SELECT Id, Product__c FROM Product_Region__c WHERE ID =: productRegion.Id].Product__c != null);//DRM:W-006536

      system.assert([SELECT Id, Product__c FROM Product_Region__c WHERE Product_Master__c =: productMaster.id LIMIT 1].Product__c != null);

      delete billingProduct; // W-031040

      Test.stopTest();
    }
  }


}