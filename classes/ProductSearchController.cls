/*
 * Copyright (C) 2014 TopCoder Inc., All Rights Reserved.
 */
  
/**
 * Product Search Controller
 * @author TCCODER
 * @version 1.0
 */ 
 /**==================================================================================================================================
 * Appirio, Inc
 * Name: ProductSearchController
 * Description: THIS CLASS WAS CREATED FROM A TOP CODER CHALLENGE
 *              Controller class for ProductSearch.page
 * Created Date: April 06, 2014
 * Created By: Nathalie Le Guay (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 * Apr 08th, 2014               Arpita Bose(Appirio)         T-269372: Added addError()in try-catch block
 * Apr 08th, 2014               Arpita Bose                  T-269840: Replaced API Name of Country_Product__c to Product_Country__c
 *                                                           and Region_Product__c to Product_Region__c
 * Apr 14th, 2014               Nathalie Le Guay             Adding "Type" as a required field
 * Apr 16th, 2014               Arpita Bose                  T-272258: Added method assignPricebook()
 * May 01st, 2014               Arpita Bose                  Updated catch(Exception) to catch(DMLException) to use getDMLException
 * May 14th, 2014               Nathalie Le Guay             Adding LIMIT 1000 to EntitySubscription query
 * May 16th, 2014               Nathalie Le Guay             I-115273 - Remove Product2 instantiation by using ProductWrapper to prevent Product2 EDIT access for Profiles
 * Jun 12th, 2014               Sadar Yacob                  Added Product Master Name to the Product Search
 * Aug 12th, 2014               Nathalie Le Guay             Change Control Board Action: Added oliTypes, selectedOliType in order to provide custom picklist values depending
 *                                                           on the Opp's Type value. Stored in Custom Labels Product_Search_Type_* and Product_Search_Order_Type_*
 * Oct 22th, 2014               Pallavi Sharma               T-327874 : Japan Product Search: Add new fields
 * Feb 26th, 2015               Paul Kissick                 Case #49531 - Hide inactive products from the search
 * Apr 21st, 2015               Paul Kissick                 Case #585773: Changed 'Description' to 'Product_Desc__c' and added Business_Line__c to search
 * Jun 26th, 2015               Arpita Bose                  T-413194: Added custom Labels
 * Sep 24th, 2015               Noopur                       I-181710: Added new custom labels for the Order Type picklist values.
 * Jan 05th, 2018               Malcolm Russell              DP Migration : W-009626 - Added Owner_s_Business_Unit__c to Opportunity Query
 * Feb 19th, 2018               James Wills                  IFRS15:Case 15572930: Added validation for IFRS15_Transac_2ary_Revenue_Subaccount__c.
 * Apr 11th, 2018               Malcolm Russell              DP Migration : Added support for DP Transactional Opportunities
 * Jun 06th, 2018               Malcolm Russell              Case 16151558 - Only show package codes that match Account Currency
 * Apr 28th, 2018               Herbert Oliveira             Case 18947316: Fix searchFilters method to return only active products
 * Ago 07th, 2019               Herbert Oliveira             Case 19399304: E3 CASE - Short-term Renewal process improvements -Tracking upsell     
 * Apr 24th, 2020               Sunil Kumar                  Case 20523480: Fixed SQL/Resource Injection Vulnerabilities                                                                                                                          
 * Jun 30th, 2020               Herbert Oliveira             Case 19919989: Make the order type Replacement available for opportunities with type New from existing  
 * Dec 29th, 2020               Dheekonda Ganesh             Case 21366853 - Transactional Opportunities Improvements - Added Transaction Sale Order type for Transactional Sale opportunities
 * Mar 22nd, 2021               Dheekonda Ganesh             Case 20797416 - Remove Upsell as order type option when Oppty is Renewal (SFDC)
 * Jul 05th, 2021               Rohit Aryan                  Case 22285528 - Default product business line
 ==========================================================================================================================================*/
global with sharing class ProductSearchController {
  
  //private static final Boolean DEBUG_MODE = true;
  
  /* standard set controller used to filter data */
    private ApexPages.StandardSetController setCon {get;set;}

    /* returns the current page set records*/
    public List<SelectableProduct> records{
      get{
        List<SelectableProduct> result = new List<SelectableProduct>();
        for(Product2 p : (List<Product2>)setCon.getRecords()){
          SelectableProduct sp = this.selectedProducts.get(p.Id);
          if(sp != null)
            result.add(sp);
          else
            result.add(new SelectableProduct(p,false,this));
        }
          return result;
      }
    }
    /* size of the result set */
    public Integer resultSize{
      get{
        return setCon.getResultSize();
      }
    }
    
    /* size of current page */
    public Integer pageSize{
      get{
        return setCon.getPageSize();
      }
    }
    
    public List<SelectOption> dummySelectList{
      get; set;
    }
    
    /* size of current page */
    public Integer pageNumber{
      get{
        return setCon.getPageNumber();
      }
    }
    
    /* new page size */
    public Integer newPageSize{get;set;}
    
    /* total number of pages */
    public Integer totalPages{
      get{
        return (Integer)Math.ceil((Double)resultSize / (Double)pageSize);
      }
    }
    
    /* sorting field */
    public String sortField{get;set;}
    
    /* filters followed products */
    public Boolean filterFollowedProducts{get;Set;}
    
    /* used to store the search filters */
    public ProductWrapper fakeProduct{get;Set;}
    
    /* country filter */
    public String countryFilter{get;Set;}
    
    /* region filter */
    public String regionFilter{get;Set;}
    
    /* countries list */
    public List<SelectOption> countriesList{get;Set;}
    
    /* regions list */
    public List<SelectOption> regionsList{get;Set;}
    
    /* family values list */
    public List<SelectOption> familyList{get;Set;}
    
    /* business unit values list */
    public List<SelectOption> businessUnitList{get;Set;}
    
    /* business line values list */
    public List<SelectOption> businessLineList{get;Set;} // PK Case #585773 - Added 
    
    /* selected products */
    public Map<ID,SelectableProduct> selectedProducts{get;Set;}

    /* maps values */
    public List<SelectableProduct> selectedProductsValues{
      get{
        List<SelectableProduct> result = this.selectedProducts.values();
        result.sort();
        return result;
      }
    }

    /* product packages for selected products */   
    public Map<ID,List<String>> productPackagesMap{get;set;}

    /* items selected? */
    public Boolean itemsSelected{
      get{
        return this.selectedProducts.size() > 0;
      }
    }
    
    /* given opportunity */
    public Opportunity opportunity{get;Set;}
    
    /* show step second step */
    public Boolean isSecondStep{get;Set;}
    
    /* items to be created */
    public List<SelectableProduct> lineItems{get;Set;}
    /* 
      utility class to handle product selection
      Has a link to the main controller to handle item selection 
    */
    
    /* Redirect page to opportunity record page */
    public Boolean redirectPageToOpportunity{get;set;}
    
    public class SelectableProduct implements Comparable{
      //product
      public Product2 product{get;Set;}
      //is selected?
      public Boolean selected{get;Set;}
      //opportunityLineItem
      public OpportunityLineItem lineItem{get;Set;}
      //main controller
      public ProductSearchController controller{get;Set;}
      
      public List<SelectOption> ProductVersions {get;set;}
      
      public List<SelectOption> oliTypes {get;set;}
      public String selectedOliType {get;set;}
      public String selectedProductVersion {get;set;}

      /*
        Constructor
        @p - product
        @selected - selected item
        @controller - main controller
      */
      public SelectableProduct(Product2 p, Boolean selected, ProductSearchController controller){
        this.product = p;
        this.controller = controller;
        this.selected = selected;
        this.lineItem = new OpportunityLineItem();
        this.oliTypes = new List<SelectOption>();
        system.debug('Type@@@@'+this.controller.opportunity.Type);
        if (String.isNotBlank(this.controller.opportunity.Type)) {  // PK: Case #49531 - Adding just in case vf errors are thrown.
            if (this.controller.opportunity.Type.equalsIgnoreCase(Label.New_From_New_System_Value)) {
              oliTypes.add(new SelectOption(Label.New_System_Value, Label.Product_Search_Order_Type_New));
              oliTypes.add(new SelectOption(Label.Paid_Trial_System_Value, Label.Product_Search_Order_Type_Paid_Trial));
              oliTypes.add(new SelectOption(Label.Paid_Dev_Tools_System_Value, Label.Product_Search_Order_Type_Paid_Dev_Tools));
            } else if (this.controller.opportunity.Type.equalsIgnoreCase(Label.New_From_Existing_System_Value)) {
              oliTypes.add(new SelectOption(Label.Cross_Sell_System_Value, Label.Product_Search_Order_Type_Cross_Sell));
              oliTypes.add(new SelectOption(Label.Up_Sell_System_Value, Label.Product_Search_Order_Type_Up_Sell));
              oliTypes.add(new SelectOption(Label.Replacement_System_Value, Label.Product_Search_Order_Type_Replacement)); //Case 19919989
              oliTypes.add(new SelectOption(Label.Paid_Trial_System_Value, Label.Product_Search_Order_Type_Paid_Trial));
              oliTypes.add(new SelectOption(Label.Paid_Dev_Tools_System_Value, Label.Product_Search_Order_Type_Paid_Dev_Tools));
            } else if (this.controller.opportunity.Type.equalsIgnoreCase(Label.Renewal_System_Value)) {
              oliTypes.add(new SelectOption(Label.Renewal_System_Value, Label.Product_Search_Order_Type_Renewal));
              oliTypes.add(new SelectOption(Label.Cross_Sell_System_Value, Label.Product_Search_Order_Type_Cross_Sell));
              //oliTypes.add(new SelectOption(Label.Up_Sell_System_Value, Label.Product_Search_Order_Type_Up_Sell));
              oliTypes.add(new SelectOption(Label.Downgrade_System_Value, Label.Product_Search_Order_Type_Downgrade));              
              oliTypes.add(new SelectOption(Label.Replacement_System_Value, Label.Product_Search_Order_Type_Replacement));
              oliTypes.add(new SelectOption(Label.Paid_Trial_System_Value, Label.Product_Search_Order_Type_Paid_Trial));
              oliTypes.add(new SelectOption(Label.Paid_Dev_Tools_System_Value, Label.Product_Search_Order_Type_Paid_Dev_Tools));
            } else if (this.controller.opportunity.Type.equalsIgnoreCase(Label.Change_System_Value)) {
              oliTypes.add(new SelectOption(Label.Up_Sell_System_Value, Label.Product_Search_Order_Type_Up_Sell));
              oliTypes.add(new SelectOption(Label.Downgrade_System_Value, Label.Product_Search_Order_Type_Downgrade));
              oliTypes.add(new SelectOption(Label.Replacement_System_Value, Label.Product_Search_Order_Type_Replacement));
              oliTypes.add(new SelectOption(Label.Removal_System_Value, Label.Product_Search_Order_Type_Removal));
              oliTypes.add(new SelectOption(Label.Paid_Trial_System_Value, Label.Product_Search_Order_Type_Paid_Trial));
              oliTypes.add(new SelectOption(Label.Paid_Dev_Tools_System_Value, Label.Product_Search_Order_Type_Paid_Dev_Tools));
            } else if (this.controller.opportunity.Type.equalsIgnoreCase(Label.Transactional_Sale_System_Value) ) {
              if(string.isNotBlank(this.controller.opportunity.Owner_s_Business_Unit__c) && this.controller.opportunity.Owner_s_Business_Unit__c.equalsIgnoreCase('APAC CS SEA')){
                  oliTypes.add(new SelectOption(Label.New_System_Value, Label.Product_Search_Order_Type_New));
                  oliTypes.add(new SelectOption(Label.Up_Sell_System_Value, Label.Product_Search_Order_Type_Up_Sell));
                  oliTypes.add(new SelectOption(Label.Cross_Sell_System_Value, Label.Product_Search_Order_Type_Cross_Sell));
                  oliTypes.add(new SelectOption(Label.Renewal_System_Value, Label.Product_Search_Order_Type_Renewal));
                  oliTypes.add(new SelectOption(Label.Downgrade_System_Value, Label.Product_Search_Order_Type_Downgrade));
              }else{
                  oliTypes.add(new SelectOption(Label.Transactional_Sale_System_Value, Label.Product_Search_Order_Type_Transactional_Sale));
              }
            } if(string.isNotBlank(this.controller.opportunity.Owner_s_Business_Unit__c) && this.controller.opportunity.Owner_s_Business_Unit__c.equalsIgnoreCase('NA MS Consumer insights & Targeting')){
                  oliTypes.add(new SelectOption(Label.No_Charge_System_Value, Label.Product_Search_Order_Type_No_Charge));
              }
            system.debug('oliTypes@@'+oliTypes);
        }
      }
      
      /* adds or removes a selected item */
      public void selectItem(){
        SelectableProduct p  = this.controller.selectedProducts.get(this.product.Id);
        if(this.selected){
          if(p == null){
            this.controller.selectedProducts.put(this.product.Id,this);
          }else{
            //nothing to do: item is already selected
          }
        }else{
          this.controller.selectedProducts.remove(this.product.Id);
        }
      }
      
      /*
        Removes an item from the selected list
      */
      public void removeSelected(){
        this.selected = false;
        this.selectItem();
      }
      
      /* Comparable interace */
      public Integer compareTo(Object compareTo) {
        if((compareTo instanceof SelectableProduct) == false) return 1;
          SelectableProduct compareToSP = (SelectableProduct)compareTo;
          return this.product.Name.compareTo(compareToSP.product.Name);       
      }
      
      /* postback when selecting a linte item on step 2*/
      public void selectLineItem(){}

      public void getProductPackageNames(){

        List<Product_Package__c> prodPackages = new List<Product_Package__c>();
        prodPackages = [SELECT Name, Is_Default__c FROM Product_Package__c where Product__c = :this.product.Id];
        if(prodPackages.size()>0){
          List<string> ppNameList = new List<string>();
          for(Product_Package__c pp : prodPackages){         
            if(pp.Is_Default__c==true){
              ppNameList.add(pp.Name);
            }
          }
          lineitem.Product_Features__c = string.join(ppNameList, ';');
        }
      }
    }
    
    /* maps product2 id with pricebookentry id (to create opportunity line items)*/
    private Map<ID,ID> productToPricebookEntry{get;set;} 
    
    /* current user info */
    public User currentUser{get;Set;}//IFRS15: Case 15572930 made public.

    /* constructor */
    public ProductSearchController(ApexPages.StandardController controller){
      opportunity = (Opportunity)controller.getRecord();
      System.debug('[ProductSearchController:**opportunity**]'+opportunity);
      this.selectedProducts = new Map<ID,SelectableProduct>();
      this.productPackagesMap = new Map<ID,List<String>>();
      this.countriesList = new List<SelectOption>();
      this.regionsList = new List<SelectOption>();
      this.familyList = new List<SelectOption>();
      this.businessUnitList = new List<SelectOption>();
      this.businessLineList = new List<SelectOption>(); // PK Case #585773 - Added
      this.redirectPageToOpportunity = false;
        
      if(opportunity == null || String.isBlank(opportunity.Id)){
        opportunity = null;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.PRODUCT_SEARCH_ERR_OPPTY_REQUIRED)); //T-413194
        return;
      }
      System.debug('----construct----');
      
      opportunity = [SELECT Id, CurrencyISOCode, Name, Pricebook2Id, Contract_Start_Date__c, Contract_End_Date__c, Type,Owner_s_Region__c, Owner_s_Business_Unit__c,Account.CurrencyIsoCode
                          FROM Opportunity
                          WHERE Id = :opportunity.Id];
      
      /*if(opportunity.Pricebook2Id == null){
        opportunity = null;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Opportunity has to be assigned to a Pricebook'));
        return;
      }*/
      
      this.currentUser = [Select Id, Region__c, Country__c, Business_Unit__c, Global_Business_Line__c From User Where Id = :UserInfo.getUserId()];
      this.fakeProduct = new ProductWrapper();
      if(currentUser.Business_Unit__c != null) { //22285528
        if(!currentUser.Business_Unit__c.contains('Data Quality')) {
          this.fakeProduct.globalBusinessLine = currentUser.Global_Business_Line__c;
        } else if (currentUser.Business_Unit__c.contains('Data Quality')) {
            this.fakeProduct.businessLine = 'Experian Data Quality';
        }
      } else {
          this.fakeProduct.globalBusinessLine = currentUser.Global_Business_Line__c;
      } //22285528
      
      this.newPageSize = 10; 
      this.filterFollowedProducts = false;
      this.sortField = 'Name ASC';
      this.regionFilter = '';
      this.countryFilter = '';
      this.isSecondStep = false;
      
      for(Region__c reg : [Select Id,Name From Region__c Order By Name]){
        this.regionsList.add(new SelectOption(reg.Id,reg.Name));
        if(currentUser.Region__c == reg.Name) { this.regionFilter = reg.Id; }
      }
      for(Country__c cnt : [Select Id,Name From Country__c Order By Name]){
        this.countriesList.add(new SelectOption(cnt.Id,cnt.Name));
        if(currentUser.Country__c == cnt.Name) { this.countryFilter = cnt.Id; }
      }
      for(String s : getPicklistValues('Product2', 'Family')){
        this.familyList.add(new SelectOption(s,s));
      }
      for(String s : getPicklistValues('Product2', 'Global_Business_Line__c')){
        this.businessUnitList.add(new SelectOption(s,s));
      }
      // PK Case #585773 - Added 
      for(String s : getPicklistValues('Product2', 'Business_Line__c')) {
        this.businessLineList.add(new SelectOption(s,s));
      }
      
      this.dummySelectList = new List<SelectOption>();
      this.dummySelectList.add(new SelectOption('--None--','--None--'));
      
      loadData();
    }
    
    /* go to first page */
    public void goToFirstPage(){
      this.setCon.first();
    }
    
    /* go to last page */
    public void goToLastPage(){
      this.setCon.last();
    }
    
    /* go to next page */
    public void goToNextPage(){
      this.setCon.next();
    }
    
    /* go to next 2 page */
    public void goToNext2Page(){
      goToNextPage();
      goToNextPage();
    }
    
    /* go to prev page */
    public void goToPrevPage(){
      this.setCon.previous();
    }
    
    /* go to prev 2 page */
    public void goToPrev2Page(){
      goToPrevPage();
      goToPrevPage();
    }
    
    
    
    /* sort the recordset */
    public void sortRecordset(){
      Integer currentPage = this.pageNumber;
      loadData();
      this.setCon.setPageNumber(currentPage);
    }
    
    /* toggle the "followed" products filter */
    public void toggleFollowedProducts(){
      this.filterFollowedProducts = !this.filterFollowedProducts;
      loadData();
    }
    
    /* suggests product name*/
    @RemoteAction
    global static List<AggregateResult> searchFilters(String searchTerm, String searchField) {
        //Case 20523480: Fixed SQL/Resource Injection Vulnerabilities
        return Database.query('SELECT '+String.escapeSingleQuotes(searchField)+' FROM Product2 '
              +' WHERE isActive = true AND '+String.escapeSingleQuotes(searchField)+' like \'%' + String.escapeSingleQuotes(searchTerm) + '%\' '
              +' GROUP BY '+String.escapeSingleQuotes(searchField)+' LIMIT 100');
    }
    
    /*
      Get all picklist values from a picklist field
    */
    public static List<String> getPicklistValues(String ObjectApi_name,String Field_name){ 
    List<String> lstPickvals=new List<String>();
      Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
      Sobject Object_name = targetType.newSObject();
      Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
      Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
      Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
      List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
      for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
          lstPickvals.add(a.getValue());//add the value  to our final list
      }
      lstPickvals.sort();
      return lstPickvals;
    }
    
    
    /*
      Reload the standard set controller with the new query
    */
    public void loadData(){
      //sorting
      String orderBy = this.sortField;
      if(orderBy.endsWith(' ASC')) 
        orderBy += ' NULLS LAST';
      else 
        orderBy += ' NULLS FIRST';
      
      String query = 'SELECT Id, Name, Product_Desc__c, IsActive, Types_of_Sale__c,DE_Product_Name__c FROM Product2 ';  // PK Case #585773: Replacing Description with Product_Desc__c
      List<String> andConditions = new List<String>();
      andConditions.add(' IsActive = true '); // PK Case #49531 - Hide inactive products
      String priceBookId = opportunity.Pricebook2Id;
      andConditions.add('Id IN (Select Product2Id From PricebookEntry Where Pricebook2Id = :priceBookId)');
      System.Debug('priceBookId = ' + priceBookId);  
      //filter name
      if(String.isBlank(this.fakeProduct.ProductName) == false){
        andConditions.add('Name LIKE \'%{!0}%\''.replace('{!0}',String.escapeSingleQuotes(this.fakeProduct.ProductName.unescapeHtml4())));
          system.debug('ProductName' +this.fakeProduct.ProductName.unescapeHtml4());
      }
      
      //filter group
      if(String.isBlank(this.fakeProduct.productGroup) == false){
        andConditions.add('Product_Group__c LIKE \'%{!0}%\''.replace('{!0}',String.escapeSingleQuotes(this.fakeProduct.productGroup.unescapeHtml4())));
          system.debug('productGroup' +this.fakeProduct.productGroup.unescapeHtml4());
      }
      
      //filter family
      if(String.isBlank(this.fakeProduct.productFamily) == false){
        andConditions.add('Family = \'{!0}\''.replace('{!0}',String.escapeSingleQuotes(this.fakeProduct.productFamily)));
      }
      
      
      //filter Product Master Name added 06/12/14
      
      if(String.isBlank(this.fakeProduct.productMasterName) == false)
      {
        andConditions.add('DE_Product_Name__c LIKE \'%{!0}%\''.replace('{!0}',String.escapeSingleQuotes(this.fakeProduct.productMasterName.unescapeHtml4())));
          system.debug('productMasterName' +this.fakeProduct.productMasterName.unescapeHtml4());
      }
      
      
      //filter country
      List<ID> noCountryOrRegionList;
      List<ID> countryAndRegionList;
      if(String.isBlank(this.countryFilter) == false && String.isBlank(this.regionFilter) == false){
        
        //checks exact  country/region matching
        Map<ID,Product2> prodWithCountriesAndRegions = new Map<ID,Product2>([Select Id,Name From Product2 
                           Where ID IN (Select Product__c From Product_Country__c Where Country__c = :this.countryFilter)]);
        countryAndRegionList = new List<ID>(prodWithCountriesAndRegions.keySet());
        //this is the list of all products that matches both selected country and region
        prodWithCountriesAndRegions = new Map<ID,Product2>([Select Id,Name From Product2 
                          Where ID IN (Select Product__c From Product_Region__c Where Region__c = :this.regionFilter)
                          and ID IN :countryAndRegionList]);
        countryAndRegionList = new List<ID>(prodWithCountriesAndRegions.keySet()); 
        
        String cond = '( (Id IN :countryAndRegionList)';
        System.Debug('countryAndRegionList = ' + countryAndRegionList);
        //checks no country/region products
        prodWithCountriesAndRegions = new Map<ID,Product2>([Select Id,Name From Product2 
                                              Where ID IN (Select Product__c From Product_Country__c)]);
        
        noCountryOrRegionList = new List<ID>(prodWithCountriesAndRegions.keySet());
        
        //this is the list of Product2 sobjects with at least one Country/Region junction record (we will negate it to get all the products
        //that don't have either one of them or both)
        noCountryOrRegionList = new List<ID>();
        for (Product2 prod : [Select Id,Name From Product2 
                                      Where ID IN (Select Product__c From Product_Region__c)
                                      and ID IN :noCountryOrRegionList]) {
          prodWithCountriesAndRegions.put(prod.ID, prod);
          noCountryOrRegionList.add(prod.ID);   
        }
        /*prodWithCountriesAndRegions = new Map<ID,Product2>([Select Id,Name From Product2 
                                      Where ID IN (Select Product__c From Product_Region__c)
                                      and ID IN :noCountryOrRegionList]);
        noCountryOrRegionList = new List<ID>(prodWithCountriesAndRegions.keySet()); 
        */
        if(noCountryOrRegionList.size()>0){
          cond+= 'OR (NOT(Id IN :noCountryOrRegionList))';
        }
        cond+=')';
        andConditions.add(cond);
      }
      
      //filter business unit
      if(String.isBlank(this.fakeProduct.globalBusinessLine) == false){
        andConditions.add('Global_Business_Line__c = \'{!0}\''.replace('{!0}',String.escapeSingleQuotes(this.fakeProduct.globalBusinessLine)));
      }
      
      //filter business line
      // PK Case #585773 - Added 
      if(String.isBlank(this.fakeProduct.businessLine) == false){
        andConditions.add('Business_Line__c = \'{!0}\''.replace('{!0}',String.escapeSingleQuotes(this.fakeProduct.businessLine)));
      }
      
      
      //filter followed products
      List<ID> prodSubSet;
      if(this.filterFollowedProducts){
        prodSubSet = new List<ID>();
        for(EntitySubscription es :  [Select ParentId From EntitySubscription Where SubscriberId = :UserInfo.getUserId() LIMIT 1000]){
          if(String.ValueOf(es.ParentId).startsWith('01t')==false) continue;
          prodSubSet.add(es.ParentId);
        }
        andConditions.add('Id IN :prodSubSet');
      }
      
      //aggregate conditions
      if(andConditions.size()>0){
        query += 'WHERE ('+String.join(andConditions,') AND (')+')';
      }
      
      query+=' Order By '+orderBy;
      System.debug('\n[ProductSearchController : loadData] : QUERY IS: \n '+ query);
      //this is for test pourposes (query don't compile but still want to see what's inside)
      //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,query));
      //query = 'SELECT Id, Name, Description, IsActive FROM Product2';
      this.setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query));
    this.setCon.setPageNumber(1);
    this.setCon.setPageSize(this.newPageSize);
    
    }
    
    /*
      Go to 2nd step: details on selected products
    */
    public void goSecondStep(){
      
      //prepares the next items
      this.lineItems = new List<SelectableProduct>();
      this.productToPricebookEntry = new Map<ID,ID>();
      
      List<Id> prod_List = new List<id>();
      boolean isAutoMotive = false;
      map<string,string> mapProductNames = new map<string,string>();        
      for(string strPrd:Label.AutomotivePortalproducts.split(';')){ 
          mapProductNames.put(strPrd,strPrd);   
      }
      set<Id> setProdIds = new set<Id>();
      for(SelectableProduct sp : this.selectedProductsValues){
            setProdIds.add(sp.product.id);
          //If logged in user NA Auto sales and added other products which are not mentioned in Label then need to throw an  error. 
         if(Userinfo.getprofileId() == Label.NA_Auto_Sales_Exec_Profile_Id && !mapProductNames.containsKey(sp.product.name)){   
            isAutoMotive = true;                            
         }
         prod_List.add(sp.product.id);
      }
      if(isAutoMotive == true){ 
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.AutomotivePortalproductsErrorMessage)); 
          return;       
      }
      Map<Id, List<SelectOption>> mapProductVersions = new Map<Id, List<SelectOption>>();
      for(Product_Version__c pv:[SELECT Id, Name, Product__c FROM Product_Version__c WHERE Product__c IN:setProdIds AND Is_Active__c = true]){
        if(!mapProductVersions.containsKey(pv.Product__c)){
            mapProductVersions.put(pv.Product__c, new List<SelectOption>{new SelectOption('','--None--')});
        }
        List<SelectOption> ProdVersions = mapProductVersions.get(pv.Product__c);
        ProdVersions.add(new SelectOption(pv.Name, pv.Name));
        mapProductVersions.put(pv.Product__c, ProdVersions);
      }
      this.isSecondStep = true;
      Map<Id, Billing_Product__c> bp_Map = new Map<Id, Billing_Product__c>([SELECT id, Product__c, Type_of_Sale__c, 
                                                                            IFRS15_Primary_Revenue_Subaccount__c,
                                                                            IFRS15_Secondary_Revenue_Subaccount__c 
                                                                            FROM Billing_Product__c
                                                                            WHERE Product__c IN :prod_List]);

      Map<String, Billing_Product__c> typeOfSale_To_Billing_Product_Map = new Map<String, Billing_Product__c>();
      
      for(Billing_Product__c bp : bp_Map.values()){
        typeOfSale_To_Billing_Product_Map.put(bp.Type_of_Sale__c, bp);
      }//IFRS15
      
      
      for(SelectableProduct sp : this.selectedProductsValues){
        this.productToPricebookEntry.put(sp.product.Id,null);
        String typeOfSale = sp.product.Types_of_Sale__c;
        typeOfSale = (typeOfSale == null) ? '':typeOfSale;
        List<String> tosSplit = typeOfSale.split('\\s?;\\s?');
        tosSplit.sort();
        for(String tos : tosSplit){
          SelectableProduct newSP = new SelectableProduct(sp.product,false,this);
          newSP.ProductVersions = new List<SelectOption>(new List<SelectOption>{new SelectOption('','--None--')});
          if(mapProductVersions.containsKey(sp.product.id)){
            newSP.ProductVersions = mapProductVersions.get(sp.product.id);
          }
          newSP.lineItem.Type_of_sale__c = tos;
          newSP.lineItem.Opportunity_Country__c = this.currentUser.Country__c;
          newSP.lineItem.Quantity = 1;
          newSP.lineItem.Upsell__c = 0;                        
          newSP.lineItem.OpportunityId = opportunity.Id;
          newSP.lineItem.Start_Date__c = opportunity.Contract_Start_Date__c;
          newSP.lineItem.End_Date__c = opportunity.Contract_End_Date__c;
          
          if(typeOfSale_to_Billing_Product_Map.get(tos)!=null){
            newSP.lineItem.IFRS15_Primary_Revenue_Subaccount__c   = typeOfSale_to_Billing_Product_Map.get(tos).IFRS15_Primary_Revenue_Subaccount__c;
            newSP.lineItem.IFRS15_Secondary_Revenue_Subaccount__c = typeOfSale_to_Billing_Product_Map.get(tos).IFRS15_Secondary_Revenue_Subaccount__c;
          }//IFRS15

          newSP.getProductPackageNames();
          
          this.lineItems.add(newSP);
        }
      }
      //sets the pricebooks
      for(PricebookEntry pbe : [Select Id, Product2Id From PricebookEntry 
                  where Pricebook2Id = : opportunity.Pricebook2Id 
                    and Product2Id IN :productToPricebookEntry.keySet()
                    and CurrencyISOCode =: opportunity.CurrencyISOCode]){
        this.productToPricebookEntry.put(pbe.Product2Id, pbe.Id);
      }
      for(SelectableProduct sp : this.lineItems){
        sp.lineItem.PriceBookEntryId = this.productToPricebookEntry.get(sp.product.Id);
      }
    }
    
    /*
      Go to 1st step: products selection
    */
    public PageReference goFirstStep(){
      this.isSecondStep = false;
      ApexPages.currentPage().setRedirect(true);
      return null;
    }
    
    /*
      Save items
    */
    public PageReference saveData(){
        
      List<OpportunityLineItem> insertList = new List<OpportunityLineItem>();
      
      Set<id> productpackageSet = new Set<id>();
      
      for(product_package__c pp : [select product__c from product_package__c]){    
        productpackageSet.add(pp.product__c);
      }
      
      Boolean selectedFound = false;
      Boolean errorFound = false;
      for(SelectableProduct sp : this.lineItems){
        if(!sp.selected) { continue; }
        
        selectedFound = true;
        sp.lineItem.Order_Type__c = sp.selectedOliType;
        sp.lineItem.Release__c = sp.selectedProductVersion;
        insertList.add(sp.lineItem);        
               
        List<String> errors = new List<String>();
        if(sp.lineItem.Quantity == null){
          errors.add(Label.Product_Search_Errors_Quantity);
        }
        if(sp.lineItem.UnitPrice == null){
          errors.add(Label.Product_Search_Errors_Unit_Price);
        }
        if(sp.lineItem.Start_Date__c == null){
          errors.add(Label.Product_Search_Errors_StartDate);
        }
        if(sp.lineItem.End_Date__c == null){
          errors.add(Label.Product_Search_Errors_EndDate);
        }
        if(String.isBlank(sp.lineItem.Type__c)){
          errors.add(Label.Product_Search_Errors_Type);
        }
        if(String.isBlank(sp.lineItem.Opportunity_Country__c)){
          errors.add(Label.Product_Search_Errors_Country);
        }
        if(string.isBlank(sp.lineItem.DP_Product_Package_Code__c) && productpackageSet.contains(sp.product.id) && sp.controller.opportunity.Owner_s_Business_Unit__c.equalsIgnoreCase('APAC CS SEA') ){
          errors.add('You must select a package code');
        }
        
        if(sp.ProductVersions!=null && sp.ProductVersions.size() > 1 && string.isBlank(sp.selectedProductVersion) &&
            (sp.controller.opportunity.Owner_s_Region__c == 'UK&I' || currentUser.Region__c == 'UK&I')){
            
            errors.add('Please select Product Version');
        }
        
        System.debug('Richard Test ' + errors);
        
        if(errors.size()>0){
          errorFound = true;
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.PRODUCT_SEARCH_ERR_MISSING_VALUE
                      +' '+String.join(errors,', ')+' '+ Label.PRODUCT_SEARCH_ERR_ON_PRODUCT + ' "'+sp.product.Name+'" '+ Label.PRODUCT_SEARCH_ERR_TYPE_OF_SALE +'"' //T-413194
                      +sp.lineItem.Type_of_sale__c+'"'));
          continue;                     
        }
        
        //IFRS15:Case 15572930
        if(sp.lineItem.Type_of_Sale__c=='Transactional' && sp.lineItem.IFRS15_Transac_2ary_Revenue_Subaccount__c==Null){
          errors.add('You must select a value for Secondary Revenue Subaccount for the Product: ' + sp.product.Name);
        }  
        
        if(sp.lineItem.Start_Date__c > sp.lineItem.End_Date__c){
          errorFound = true;
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.PRODUCT_SEARCH_ERR_END_DATE_GRTR_THN_START_DATE
                      + Label.PRODUCT_SEARCH_ERR_ON_PRODUCT +' "'+sp.product.Name+'"'+ Label.PRODUCT_SEARCH_ERR_TYPE_OF_SALE +' "' //T-413194
                      +sp.lineItem.Type_of_sale__c+'"'));
        }
          
        if(sp.lineItem.Order_Type__c == 'No Charge' && sp.lineItem.UnitPrice > 0){
          errorFound = true;
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.PRODUCT_SEARCH_ERR_SALESPRICE_MUST_BE_ZERO
                      +' '+ Label.PRODUCT_SEARCH_ERR_ON_PRODUCT +' "'+sp.product.Name+'" '+ Label.PRODUCT_SEARCH_ERR_ORDER_TYPE +' "'
                      +sp.lineItem.Order_Type__c+'"'));
        }
        
        if(sp.lineItem.Quantity < 1 || sp.lineItem.UnitPrice < 0){
          errorFound = true;
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.PRODUCT_SEARCH_ERR_QTY_N_SALESPRICE_MUST_BE_POSITIVE
                      + Label.PRODUCT_SEARCH_ERR_ON_PRODUCT +' "'+sp.product.Name+'"'+ Label.PRODUCT_SEARCH_ERR_TYPE_OF_SALE +' "' //T-413194
                      +sp.lineItem.Type_of_sale__c+'"'));
        }
      }
        
      if(insertList.size() >0){
        Integer count=0;
        for(Integer i = 0; i < insertList.size(); i++){
            if(insertList[i].Order_Type__c !='No Charge')
            {
            count++; 
            }
        }   
            If(count == 0){
                errorFound = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.PRODUCT_SEARCH_ERR_LINEITEM_MUST_BE_MORE_THAN_ONE
                  +' '+ Label.PRODUCT_SEARCH_ERR_ON_PRODUCT +' '+ Label.PRODUCT_SEARCH_ERR_ORDER_TYPE +' "'
                  +insertList[0].Order_Type__c+'"'));
            }       
        }  
      
      if(errorFound){ return null; }
      if(!errorFound && !selectedFound){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.PRODUCT_SEARCH_ERR_PLS_SELECT_ATLEAST_ONE_PROD));
        return null;
      }
      try{
        insert insertList;
        this.redirectPageToOpportunity = true;
        system.debug('HO Debug - redirectPage: ' + redirectPageToOpportunity);
      }catch(DMLException e){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getDMLMessage(0)));
        for (Integer i = 0; i < e.getNumDml(); i++) {
          insertList.get(0).addError(e.getDmlMessage(i));
        }
        return null;
      }
      //PageReference pg = new PageReference('/'+opportunity.Id);
      //pg.setRedirect(true);
      //return pg;
      return null;
    }
    

  //=========================================================================
  //T-272258: Add default pricebook to Opportunity
  //=========================================================================
  public void assignPriceBook() {
      System.debug('[ProductSearchController:assignPricebook][-pre-update->]'+opportunity.Pricebook2Id);
    try {
          if (opportunity.Pricebook2Id == null) {
            Pricebook2 priceBook = [ SELECT Id FROM Pricebook2 WHERE Name =: Constants.STANDARD_PRICE_BOOK limit 1];      
          opportunity.Pricebook2Id = priceBook.ID;
          update opportunity;
          //Re-querying opportnity to get populated updated field.
              opportunity = [SELECT Id, CurrencyISOCode, Name, Pricebook2Id, Contract_Start_Date__c, Contract_End_Date__c, Type, Owner_s_Region__c, Owner_s_Business_Unit__c,Account.CurrencyIsoCode
                                  FROM Opportunity
                                  WHERE Id = :opportunity.Id];
          }
    } catch (DMLException ex) {
      System.debug('\n[ProductSearchController: assignPricebook]: ['+ex.getMessage()+']]');
      apexLogHandler.createLogAndSave('ProductSearchController', 'assignPricebook', ex.getStackTraceString(), ex);
      for (Integer indx = 0; indx < ex.getNumDml(); indx++) {
          opportunity.addError(ex.getDMLMessage(indx));
       }
    }

    System.debug('[ProductSearchController:assignPricebook][-post-update->]'+opportunity.Pricebook2Id);
  }

  public Class ProductWrapper {
    public String productName {get;set;}
    public String productGroup{get;set;}
    public String productFamily{get;set;}
    public String globalBusinessLine{get;set;}
    public String productMasterName{get;set;}
    public String businessLine{get;set;}
  }
}