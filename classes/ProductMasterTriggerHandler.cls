/**=====================================================================
 * Name: ProductMasterTriggerHandler
 * Description: Handler for Product_Master__c Trigger
 * Created Date: Oct 13th 2014
 * Created By: Richard
 *
 * Business Case- To Sync Product Master details to Salesforce product2 and CPQ product objects.
 *  Change log
 * Modified on      Modified by           Modified Description
 * March 10th 2015  Richard Joseph        To include Discover_Experian_Name__c and Include_in_Discover_Experian__c
 *                                        Fields to Sync to Products. Case # 584066
 *                                        Including CSDA fields CSDA_Product_Group__c,CSDA_Product_Org__c,CSDA_Product_Suite__c
 * May 13th, 2015   Richard Joseph        Use Product_Name__c  to map in Products
 * Sep 30th, 2015   Naresh kr Ojha        T-437165: Update Product Master to Product2 trigger for Serasa BU Split fields
 * Oct 12th, 2015   Paul Kissick          Case #01183772 - Brazil_Internal_product_code__c missed from reflection to Product2
 * Oct 09,   2017   Esteban Castro        Case #13644238 - Send Drmid to CPQ Product_Master and ExperianProductDetail
 * Feb. 26th, 2018  James Wills           IFRS15: Case 15497987 - Transfer Segment and Subsegment values from Product Master to Product.
 * Apr. 13th, 2018  James Wills           Case 15521722: Add mapping for Chart_of_Accounts_Global_Product__c and Chart_of_Accounts_Global_Product Code__c fields.
 * May 22nd, 2018   James Wills           Case 16238068: Add mapping for Segment_Global_Line__c and Segment_Business_Line__c.
 * Jul   05, 2019   Esteban Castro        Case 19190762 - Types of Sale not populating on product / Batch instead of future
 * Mar 4th 2020     Malcolm Russell       Case 02426983- Auto create pricebook entries on insert of Product2 Record
 * Apr 16th 2020    Mauricio Murillo      Case 02437131- Removed restriction to create products when life cycle is Beta
 * May 13th 2020    Esteban Castro        Case: 20541942 ~ Salesforce to CPQ Product API for Product Catalog R&D
 * July 12th 2021   Dheekonda Ganesh      Work W-033624 - 22112413 - Global - Product life cycle request
 * July 8th 2021    Shweta Bhuria         Case: 20883362 ~ Added Method-recordFieldHistory to capture field history
=====================================================================*/
public class ProductMasterTriggerHandler {

  public static boolean aSyncRRecursiveRUN = false;
  private static CPQ_Settings__c CPQSetting = CPQ_Settings__c.getInstance('CPQ'); // EC: 19190762

  //===========================================================================
  // After Insert
  //===========================================================================
  public static void afterInsert(Map<ID, Product_Master__c> newMap) {
    createProducts(newMap.values());
  }

  //===========================================================================
  //After Update
  //===========================================================================
  public static void afterUpdate(Map<ID, Product_Master__c> newMap, Map<ID, Product_Master__c> oldMap) {

    if(!aSyncRRecursiveRUN) {
      Map<Id,Id> existingProductMasterProductMap = new map<id,id>();
      List<Product_Master__c> toCreateProductMasterList =new List<Product_Master__c>();
      List<Product_Master__c> toUpdateProductMasterList =new List<Product_Master__c>();

      List<Product2> existingProductList = new List<Product2>([
        SELECT Id, Product_Master__c, Product_Master__r.Id
        FROM Product2
        WHERE Product_Master__c IN :newMap.keySet()
      ]);
      for(Product2 productRec : existingProductList) {
        existingProductMasterProductMap.put(productRec.Product_Master__r.Id, productRec.Id );
      }

      for(Product_Master__c productMasterRec : newmap.values()) {
        if (productMasterRec.Product_life_cycle__c != 'Development' /*02437131 && productMasterRec.Product_life_cycle__c != 'Beta'*/) {
        //&& productMasterRec.Product_life_cycle__c!= oldMap.get(productMasterRec.id).Product_life_cycle__c)
          if(existingProductMasterProductMap.containsKey(productMasterRec.id)) {
            toUpdateProductMasterList.add(productMasterRec);
          }
          else {
            toCreateProductMasterList.add(productMasterRec);
          }
        }
        //else If(productMasterRec.Product_life_cycle__c != 'Development' && productMasterRec.Product_life_cycle__c != 'Beta' && existingProductMasterProductMap.containsKey(productMasterRec.id)
        //&& productMasterRec.CpqTableEntryId__c == oldMap.get(productMasterRec.id).CpqTableEntryId__c
        //)
        //       toUpdateProductMasterList.add(productMasterRec);
      }

      updateCPQProducts(newMap, oldMap);// EC:: Case: 20541942 ~ Salesforce to CPQ Product API for Product Catalog R&D

      if (toCreateProductMasterList.size() > 0) {
        aSyncRRecursiveRUN= true;
        createProducts(toCreateProductMasterList);
      }
      if (toUpdateProductMasterList.size() > 0 && !aSyncRRecursiveRUN) {
        aSyncRRecursiveRUN= true;
        updateProducts( toUpdateProductMasterList , existingProductMasterProductMap);
      }
    }
    
  }

  //Create Products in both SFDC and CPQ
  private static void createProducts(List<Product_Master__c> newproductMasterList ) {
    List<Product2> productList = new List<Product2>();
    List<Id> pmIds = new List<Id>();
    
    Database.DMLOptions dmlOptions = new Database.DMLOptions();
    dmlOptions.allowFieldTruncation = true;
    
    for(Product_Master__c productMasterRec : newproductMasterList) {
      if(productMasterRec.Product_life_cycle__c != 'Development' /*02437131 && productMasterRec.Product_life_cycle__c != 'Beta'*/) {
        Product2 newProductRec = mapProductFields(productMasterRec);
        newProductRec.setOptions(dmlOptions);
        productList.add(newProductRec);
        pmIds.add(productMasterRec.Id);
      }
    }
    if (productList.size() > 0) {
      insert productList;
      productRelatedListMapping(productList);
      
      ID standardPB = [select id from PriceBook2 where IsStandard=true limit 1].id;
      list<CurrencyType> activeCurr = new list<CurrencyType>([select id,IsoCode from CurrencyType]);
      list<pricebookEntry> insertPBEList = new list<pricebookEntry>();
      
      for(product2 p : productList){
        for (CurrencyType c : activeCurr){
          insertPBEList.add(new pricebookEntry(PriceBook2Id=standardPB, product2Id=p.Id,CurrencyIsoCode=c.IsoCode,isActive=p.isActive, unitPrice=0));
        }
      }
      
      insert insertPBEList;
    }
    
    // EC: W-029973
    if ((Limits.getLimitFutureCalls() - Limits.getFutureCalls()) > 1) {
      SFDCToCPQProductMasterSyncServiceClass.callCPQProductMasterAsync(pmIds);
    }
  }
  
  //Updates/Creates Products in both SFDC and CPQ
  private static void updateProducts(List<Product_Master__c> newproductMasterList, Map<Id,Id> existingProductMasterProductMap ) {
    List<Product2> productList = new List<Product2>();
    List<Id> pmIds = new List<Id>();
    Database.DMLOptions dmlOptions = new Database.DMLOptions();
    dmlOptions.allowFieldTruncation = true;
    for(Product_Master__c productMasterRec : newproductMasterList){
      if(productMasterRec.Product_life_cycle__c != 'Development' /*02437131 && productMasterRec.Product_life_cycle__c != 'Beta'*/) {
        Product2 exstingProduct = new Product2 ();
        exstingProduct =mapProductFields(productMasterRec);
        exstingProduct.id=existingProductMasterProductMap.get(productMasterRec.id);
        exstingProduct.setOptions(dmlOptions);
        productList.add(exstingProduct );
        pmIds.add(productMasterRec.Id);
      }
    }
    if (productList.size()>0) {
      upsert productList;
      productRelatedListMapping(productList);
    }
    if ((Limits.getLimitFutureCalls() - Limits.getFutureCalls()) > 1) {
      SFDCToCPQProductMasterSyncServiceClass.callCPQProductMasterAsync(pmIds);
    }
  }

  /**
    Update CPQ Products when values in product master change
   */
  private static void updateCPQProducts(Map<ID, Product_Master__c> newMap, Map<ID, Product_Master__c> oldMap){
    if(!IsDataAdmin__c.getInstance().IsDataAdmin__c){ // only if it's not dataAdmin
      List<Id> lpmid = new List<Id>();
      for(Product_Master__c pm : newMap.values()){
        Product_Master__c tmpPrd = oldMap.get(pm.Id);
        if( // whenever name or description has changed in product master
          tmpPrd != null && (
            tmpPrd.Product_Name__c != pm.Product_Name__c ||
            tmpPrd.Product_description__c != pm.Product_description__c
          )
        ){
          lpmid.add(pm.Id);
        }
      }

      if(!lpmid.isEmpty()){ // running integration to CPQ Product
        String cronID = Database.executeBatch(new SFDCtoCPQProductIntegration([
          SELECT System_Id__c, External_Id__c, Architecture_Type__c, Region__c, Active__c,Start_Date__c, End_Date__c, Integration_Feedback__c,
          Product_Master__r.Segment_Global_Line__c, Product_Master__r.DRMID__c,
          Product_Master__r.Product_Name__c, Product_Master__r.Product_description__c,
          Parent_Template__r.System_Id__c
          FROM CPQ_Product__c
          WHERE Product_Master__c = :lpmid
        ]), 50);
      }
    }
  }

  //Map other relatedlist objects to Product.
  private static void productRelatedListMapping(List<Product2> productList){
    map<id,id> productMasterProductIdMap = new map<id,id>();
    for (Product2 productRec:productList) {
      if(productRec.Product_Master__c != null) {
        productMasterProductIdMap.put(productRec.Product_Master__c,productRec.id );
      }
    }
    if(productMasterProductIdMap.size()> 0) {
      List<Billing_Product__c> newBillingProductList = new List<Billing_Product__c>([
        SELECT Id, Product__c, Product_Master__r.Id
        FROM Billing_Product__c
        WHERE Product_Master__c IN :productMasterProductIdMap.keyset()
      ]);
      for(Billing_Product__c newBillingProductRec:newBillingProductList) {
        newBillingProductRec.Product__c = productMasterProductIdMap.get(newBillingProductRec.Product_Master__r.id);
      }
      update newBillingProductList;
      List<Product_Country__c> newproductCountryList = new List<Product_Country__c>([
        SELECT Id, Product__c, Product_Master__r.Id
        FROM Product_Country__c
        WHERE Product_Master__c IN :productMasterProductIdMap.keyset()
      ]);
      for(Product_Country__c newproductCountryRec :newproductCountryList ) {
        newproductCountryRec.Product__c =productMasterProductIdMap.get(newproductCountryRec.Product_Master__r.id);
      }

      update newproductCountryList;

      List<Product_Region__c> newproductRegionList = new List<Product_Region__c>([
        SELECT Id, Product__c, Product_Master__r.Id
        FROM Product_Region__c
        WHERE Product_Master__c IN :productMasterProductIdMap.keyset()
      ]);

      for(Product_Region__c newproductRegionRec :newproductRegionList ){
        newproductRegionRec.Product__c = productMasterProductIdMap.get(newproductRegionRec.Product_Master__r.id);
      }
      update newproductRegionList;
    }
  }


  //Map Products Field
  private static Product2 mapProductFields(Product_Master__c productMasterRecord) {
    Product2 newProductRec = new Product2();
    //Changed by RJ- to Map custom Product name -Product_Name__c to Product.Name
    //newProductRec.name = productMasterRecord.Name;
    newProductRec.name= productMasterRecord.Product_Name__c;
    newProductRec.DE_Product_Name__c = productMasterRecord.Product_master_name__c;
    //This is added for I-139119 - The Description field is mapped wrongly to standard field
    //newProductRec.Description=productMasterRecord.Product_Description__c; 
    newProductRec.Product_Desc__c=productMasterRecord.Product_Description__c;
    newProductRec.Types_of_Sale__c= productMasterRecord.Type_of_sale__c;
    newProductRec.Simple_or_complex__c = productMasterRecord.Simple_or_complex__c;
    newProductRec.Capability__c = productMasterRecord.Capability__c;
    newProductRec.Family= productMasterRecord.Product_Family__c;
    newProductRec.Product_Group__c = productMasterRecord.Product_Group__c;
    newProductRec.Global_Business_Line__c = productMasterRecord.Product_Global_Business_Line__c;
    newProductRec.Business_Line__c= productMasterRecord.Line_of_business__c;
    newProductRec.Industry__c = productMasterRecord.Unique_industries_served__c;
    newProductRec.Sector__c= productMasterRecord.Sector__c;


    if(productMasterRecord.Active__c) {
      newProductRec.isActive= true;
    } else {
      newProductRec.isActive= false;
    }

    //Added to enable RevenueSchedule.
    newProductRec.CanUseRevenueSchedule=true;
    newProductRec.Customer_Journey__c= productMasterRecord.Customer_Journey__c;
    newProductRec.Asset_type__c= productMasterRecord.Asset_type__c;
    //This is added for I-139119 - The Description field is mapped wrongly to standard field
    //newProductRec.Chart_of_Accounts_Product_Description__c= productMasterRecord.Chart_of_Accounts_Product_Description__c;
    newProductRec.Description=productMasterRecord.Chart_of_Accounts_Product_Description__c;
    newProductRec.FUSE_product_page_URL__c= productMasterRecord.FUSE_product_page_URL__c;
    newProductRec.Provides_insight_into__c= productMasterRecord.Provides_insight_into__c;
    newProductRec.Product_Master__c= productMasterRecord.id;
    newProductRec.PD_Code__c =productMasterRecord.Chart_of_Accounts_Subanaysis_PD_code__c;
    newProductRec.Lifecycle__c = productMasterRecord.Product_life_cycle__c;
    //RJ - Case # 584066 - To include Discover_Experian_Name__c and Include_in_Discover_Experian__c in Product Sync
    newProductRec.Discover_Experian_Name__c = productMasterRecord.Discover_Experian_Name__c;
    newProductRec.Include_in_Discover_Experian__c  = productMasterRecord.Include_in_Discover_Experian__c;
    //CSDA fields
    newProductRec.CSDA_Product_Group__c  = productMasterRecord.CSDA_Product_Group__c;
    newProductRec.CSDA_Product_Org__c  = productMasterRecord.CSDA_Product_Org__c;
    newProductRec.CSDA_Product_Suite__c  = productMasterRecord.CSDA_Product_Suite__c;

    //Serasa fields
    newProductRec.Serasa_BI_Split__c  = productMasterRecord.Serasa_BI_Split__c;
    newProductRec.Serasa_CI_Split__c  = productMasterRecord.Serasa_CI_Split__c;
    newProductRec.Serasa_DA_Split__c  = productMasterRecord.Serasa_DA_Split__c;
    newProductRec.Serasa_ECS_Split__c  = productMasterRecord.Serasa_ECS_Split__c;
    newProductRec.Serasa_ID_Split__c  = productMasterRecord.Serasa_ID_Split__c;
    newProductRec.Serasa_MS_Split__c  = productMasterRecord.Serasa_MS_Split__c;
    newProductRec.Serasa_Targeting_Split__c  = productMasterRecord.Serasa_Targeting_Split__c;
    newProductRec.Brazil_Internal_product_code__c = productMasterRecord.Brazil_Internal_product_code__c;  // PK Case #01183772

    //IFRS15 Case 15449529
    newProductRec.DRM_Hierarchy_Segment__c    = productMasterRecord.DRM_Hierarchy_Segment__c;
    newProductRec.DRM_Hierarchy_Subsegment__c = productMasterRecord.DRM_Hierarchy_Subsegment__c;
    //IFRS15 Case 15449529

    //Case 15521722
    newProductRec.Chart_of_Accounts_Global_Product__c      = productMasterRecord.Chart_of_Accounts_Global_Product__c;
    newProductRec.Chart_of_Accounts_Global_Product_Code__c = productMasterRecord.Chart_of_Accounts_Global_Product_Code__c;
    //Case 15521722

    //Case 16238068
    newProductRec.Segment_Global_Line__c   = productMasterRecord.Segment_Global_Line__c;
    newProductRec.Segment_Business_Line__c = productMasterRecord.Segment_Business_Line__c;
    //Case 16238068

    return newProductRec;
  }
    
    public static void recordFieldHistory(map<id,Product_Master__c> productMasterNewMap, map<Id,Product_Master__c> productMasterOldMap){
        List<Schema.FieldSetMember> fieldsTotrack = SObjectType.Product_Master__c.FieldSets.Product_Master_Custom_Field_tracking.getFields();
        List<Audit_Trail__c> auditTrailList = new List<Audit_trail__c>();
        Map<String,String> fieldApiNameAndLabelMap = createFieldApiNameAndLabelMap(constants.PRODUCT_MASTER_OBJECT_API_NAME);
        
        for(Product_Master__c pm:productMasterNewMap.values()){
            for(Schema.FieldSetMember fieldSetMember:fieldsTotrack){
                Product_Master__c prodMaster = pm;
                Product_Master__c oldProdMaster = productMasterOldMap.get(pm.Id);
                if(prodMaster.get(fieldSetMember.getFieldPath()) != oldProdMaster.get(fieldSetMember.getFieldPath())){
                    Audit_Trail__c audit = new Audit_Trail__c();
                    string fieldApiName = fieldSetMember.getFieldPath();
                    audit.Object_Name__c = constants.PRODUCT_MASTER_OBJECT_API_NAME; 
                    audit.Old_Value__c = String.valueof(oldProdMaster.get(fieldApiName));
                    audit.New_Value__c = String.valueof(prodMaster.get(fieldApiName));
                    audit.Last_Modified_Date__c = datetime.now();
                    audit.Last_Modified_By__c = prodMaster.LastModifiedById;
                    audit.Record_Id__c = String.valueof(oldProdMaster.Id);
                    audit.Product_Master__c = String.valueof(oldProdMaster.Id);
                    system.debug(fieldApiNameAndLabelMap.get(fieldApiName));
                    if(fieldApiNameAndLabelMap != null && fieldApiNameAndLabelMap.containsKey(fieldApiName.toLowerCase())){
                        audit.Field_Name__c = fieldApiNameAndLabelMap.get(fieldApiName.toLowerCase());
                    }
                    else{
                        audit.Field_Name__c = fieldApiName;
                    }
                    
                    auditTrailList.add(audit);
                }
            }    
        }
        if (auditTrailList.size() > 0) {
            try {
                insert auditTrailList;
            } catch (DMLException ex) {
                ApexLogHandler.createLogAndSave('ProductMasterTriggerHandler','recordFieldHistory', ex.getStackTraceString(), ex);
                for (Integer i = 0; i < ex.getNumDml(); i++) {
                    productMasterNewMap.values().get(0).addError(ex.getDmlMessage(i));
                }
            }
        }
    }
    
    public static Map<string,string> createFieldApiNameAndLabelMap(string objectApiName){
        Map<String,String> fieldApiLabelMap = new Map<string,string>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType PMSchema = schemaMap.get(objectApiName);
        Map<String, Schema.SObjectField> fieldMap = PMSchema.getDescribe().fields.getMap(); 
        for (String fieldName: fieldMap.keySet()) {
            fieldApiLabelMap.put(fieldName.toLowerCase(),fieldMap.get(fieldName).getDescribe().getLabel());
        }
        return fieldApiLabelMap;
    }
        
    
}