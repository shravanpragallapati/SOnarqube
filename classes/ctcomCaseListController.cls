/**
 * @File Name          : ctcomCaseListController.cls
 * @Description        : 
 * @Author             : Manoj Gopu
 * @Group              : 
 * @Last Modified By   : Manoj Gopu
 * @Last Modified On   : 6/29/2020, 2:10:08 PM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    6/29/2020          Manoj Gopu             Initial Version
 *        7/12/2021          Sai Navya Yerrabelli   case:22086523 ApexSOQLInjection
**/
public with sharing class ctcomCaseListController {
   
    /*====================================================================================
    This method is used to get the cases based on the List view   
    ======================================================================================*/
    @AuraEnabled(cacheable=true)
    public static List<sObject> getRecords(String listView) {
         
         //Get the recordtypes from Custom metadata
         list<string> lstReTypes = ctcom_Community_Util.getRecordTypeDeveloperNames('Case');
         List<CTCOM_Community_Configuration__mdt> lstCtcom=[SELECT Id,MasterLabel,Value__c 
                                                            FROM CTCOM_Community_Configuration__mdt
                                                            WHERE MasterLabel=:listView ];       
         
        String queryFields =''; //Building Query dynamically
        if(lstCtcom.isEmpty()){
          queryFields='Id,Customer_Case_Number__c,User_Requestor__c,Subject,toLabel(Status),CreatedDate,Affected_ServiceProduct__c';
        }else{ 
            queryFields = lstCtcom[0].Value__c;
        }
        User currentUser = [SELECT id, ContactId FROM User WHERE id =: UserInfo.getUserId()];        
         String WhereClause='';
        if(listView=='All Open Cases'){ 
            WhereClause =' isClosed = false AND Recordtype.DeveloperName =:lstReTypes ';
        }else if(listView=='My Open Cases'){
            WhereClause = ' isClosed = false AND Recordtype.DeveloperName =:lstReTypes AND ( OwnerId = \'' + String.escapeSingleQuotes(UserInfo.getUserId())+ '\' ';//22086523
            if (currentUser.contactid != null)
            {
                WhereClause += ' OR ContactId = \'' + String.escapeSingleQuotes(currentUser.contactid) + '\'';//22086523
            }
            WhereClause += ')  ';
        }else if(listView=='All Closed Cases'){
            WhereClause =' isClosed = true AND Recordtype.DeveloperName =:lstReTypes ';
        }else if(listView=='My Closed Cases'){
            WhereClause = ' isClosed = true AND Recordtype.DeveloperName =:lstReTypes AND ( OwnerId = \'' +String.escapeSingleQuotes( UserInfo.getUserId())+ '\' ';//22086523
            if (currentUser.contactid != null)
            {
                WhereClause += ' OR ContactId = \'' + String.escapeSingleQuotes(currentUser.contactid) + '\'';//22086523
            }
            WhereClause += ')  ';
        }
        if(WhereClause != ''){
            WhereClause += '  AND CreatedDate>=LAST_N_MONTHS:24';
        } else{
            WhereClause += ' CreatedDate>=LAST_N_MONTHS:24';
        }
        List<sObject> sObjectRecords=getsObjectRecords('Case',
        queryFields,
        WhereClause,1000, 'CaseNumber','DESC'
        );

        return sObjectRecords;
    }
    
    /*====================================================================================
    This method is used to Query the Cases based on the above criteria  
    ======================================================================================*/
    public static List<sObject> getsObjectRecords(String ObjectName, String fieldNameSet, String whereClause, Integer LimitSize, String Orderby, String OrderDir) {
        
        list<string> lstReTypes = ctcom_Community_Util.getRecordTypeDeveloperNames('Case');
        OrderDir = String.isBlank(OrderDir) ? 'asc' : OrderDir;
        //String query = 'SELECT '+String.join(fieldNameSet, ',')+'  FROM '+ObjectName;
        String query = 'SELECT '+fieldNameSet+'  FROM '+ObjectName;
        if(String.isNotBlank(whereClause)) {
            query += ' WHERE '+whereClause;
        }
        
        query += ' ORDER BY '+Orderby+' '+OrderDir+' NULLS LAST';
        
        if(LimitSize != null && Integer.valueOf(LimitSize) > 0) {
            LimitSize = Integer.valueOf(LimitSize);
            query += ' Limit '+LimitSize;
        }
        System.debug('query'+Database.query(query));//22086523
        return Database.query(String.valueOf(query)); //22086523
        
    }
    
 /*====================================================================================
    This method is used to get the fieldtypes and this is used in LWC 
    ======================================================================================*/
     @AuraEnabled
    public static Map<String, String> getFieldTypes(String listView){
        Map<String, String> fieldTypeMap = new Map<String, String>();
        List<CTCOM_Community_Configuration__mdt> lstCtcom=[SELECT Id,MasterLabel,Value__c 
                                                            FROM CTCOM_Community_Configuration__mdt
                                                            WHERE MasterLabel=:listView ];
        String queryFields ='';
        if(lstCtcom.isEmpty()){
          queryFields='Id,Customer_Case_Number__c,User_Requestor__c,Subject,Status,CreatedDate,Affected_ServiceProduct__c';
        }else{ 
            queryFields = lstCtcom[0].Value__c.deleteWhitespace();
        }
  
        String type= 'Case';  // Say,this is my object
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType caseSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = caseSchema.getDescribe().fields.getMap();
        List<String> selectedFields=queryFields.split(',');
        for(String field : selectedFields){
			if(field.containsIgnoreCase('toLabel(')){
                field = field.substringBetween('toLabel(', ')');
            }
            Schema.DisplayType fieldType = fieldMap.get(field).getDescribe().getType();
            String fieldLabel = fieldMap.get(field).getDescribe().getLabel();
            fieldTypeMap.put(field,'{"Label":"'+String.valueOf(fieldLabel)+'","Type":"'+String.valueOf(fieldType)+'"}');
        }
        return fieldTypeMap;
    }

}