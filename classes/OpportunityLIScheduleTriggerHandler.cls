/* ============================================================================
 * Experian
 * Name             : OpportunityLIScheduleTriggerHandler
 * Description      : Handler class for OpportunityLineItemScheduleTrigger trigger
 * Created Date     : March 03rd 2021
 * Created By       : Herbert Oliveira
 * Test Class		: OpportunityLIScheduleTriggerHandler_Test
 * 
 * Date Modified        Modified By             Description of the update
 * May 26th 2021		Herbert Oliveira		Case 20364223: Allow users to set the renewal amount at schedule level
 * June 6th 2021        Sai Navya Yerrabelli    Case 22198811: To identify Opps with RevSchedules and SalesRevenueschedule that are non-zero 
 *                                              and updating fields in Opportunity Line Item
 ============================================================================== */
public class OpportunityLIScheduleTriggerHandler {
    
    public static Boolean isDataAdmin = IsDataAdmin__c.getInstance().IsDataAdmin__c;
    public static Map<Id,Opportunity> oppMap;
    public static Map<Id,OpportunityLineItem> oppProductMap;
    public static Map<Id,List<OpportunityLineItemSchedule>> oppProductToSchedulesMap;
    	
    //=========================================================================
    // Before Insert Call
    //=========================================================================    
    public static void beforeInsert(List<OpportunityLineItemSchedule> newList) { 
        if (!isDataAdmin) {
            //populateOppAndOppProductMaps(newList);
            //setRenewalAndNewBusinessAmount(newList);
        }
    }
    
    //=========================================================================
    // Before Update Call
    //=========================================================================    
    public static void beforeUpdate(List<OpportunityLineItemSchedule> newList, Map<Id,OpportunityLineItemSchedule> oldMap) {
        if (!isDataAdmin) {
            //setRevenueValueByRenewalAndNewBusinessAmounts(newList, oldMap); 
        }
    }
    
	//=========================================================================
    // Before Delete Call
    //=========================================================================    
    //public static void beforeDelete(Map<Id,OpportunityLineItemSchedule> oldMap) { }
    
    //=========================================================================
    // After Insert Call
    //=========================================================================    
    public static void afterInsert(List<OpportunityLineItemSchedule> newList) { 
        if (!isDataAdmin) {
        	updateOppAndProductMinimumRevenueScheduleDate(newList);
            updateIsNonZeroRevenueScheduleOppLineItem(newList, null);//22198811 
        }    	
    }
    
    //=========================================================================
    // After Update Call
    //=========================================================================    
    public static void afterUpdate(List<OpportunityLineItemSchedule> newList, Map<Id,OpportunityLineItemSchedule> oldMap) {
    	if (!isDataAdmin) {
            updateOppAndProductMinimumRevenueScheduleDate(newList);
            updateIsNonZeroRevenueScheduleOppLineItem(newList, oldMap);//22198811 
            //populateOppAndOppProductMaps(newList);
            //updateOppProductUpsellValue(newList);
        }
    }
    
    //=========================================================================
    // After Delete Call
    //=========================================================================    
    public static void afterDelete(Map<Id,OpportunityLineItemSchedule> oldMap) { 
    	if (!isDataAdmin) {
            updateOppAndProductMinimumRevenueScheduleDate(oldMap.values());
            updateIsNonZeroRevenueScheduleOppLineItemOnDelete(oldMap.values());
        }
    }   
    
    /*public static void populateOppAndOppProductMaps(List<OpportunityLineItemSchedule> newList) {
        if (oppMap == null || oppProductMap == null || oppProductToSchedulesMap == null) {
            oppMap = new Map<Id,Opportunity>();
            oppProductMap = new Map<Id,OpportunityLineItem>();
            oppProductToSchedulesMap = new Map<Id,List<OpportunityLineItemSchedule>>();
            Set<Id> oppProductIdSet = new Set<Id>();
            for (OpportunityLineItemSchedule oppProducSchedule : newList) {
            	oppProductIdSet.add(oppProducSchedule.OpportunityLineItemId);	    
            }
            for (OpportunityLineItem oppProduct : [SELECT Opportunity.Id, OpportunityId, Order_Type__c, Upsell__c, UnitPrice,
                                                   		(SELECT Id, Revenue, Renewal_Amount__c, New_Business_Amount__c
                                                         FROM OpportunityLineItemSchedules)
                                                   FROM OpportunityLineItem
                                                   WHERE Id IN :oppProductIdSet]) {
				oppProductMap.put(oppProduct.Id, oppProduct);
                oppProductToSchedulesMap.put(oppProduct.Id, new List<OpportunityLineItemSchedule>());
                for (OpportunityLineItemSchedule oppProductSchedule : oppProduct.OpportunityLineItemSchedules) {
                	oppProductToSchedulesMap.get(oppProduct.Id).add(oppProductSchedule);	                                           
                }                                       
                if (!oppMap.containsKey(oppProduct.OpportunityId)) {
					oppMap.put(oppProduct.OpportunityId, oppProduct.Opportunity);                                                           
                }
            }
        }    
    }*/
    
    //22198811 
    public static void updateIsNonZeroRevenueScheduleOppLineItem(List<OpportunityLineItemSchedule> newList, Map<Id,OpportunityLineItemSchedule> oldMap){
       
        Map<Id,Boolean> NonZeroRevenueScheduleOppMap = new Map<Id,Boolean>();
        for(OpportunityLineItemSchedule revSchedule:newList){
            if((oldMap== null || 
                (oldMap != null && revSchedule.Revenue != oldMap.get(revSchedule.Id).Revenue)) && 
               revSchedule.OpportunityId__c!=null){
                   if(revSchedule.Revenue>0){
                       NonZeroRevenueScheduleOppMap.put(revSchedule.OpportunityId__c, TRUE);
                   }else{
                       NonZeroRevenueScheduleOppMap.put(revSchedule.OpportunityId__c, FALSE);                       
                   }
               }
        }
        if(NonZeroRevenueScheduleOppMap.values().size() > 0){
            updateOpportunityLineItem(NonZeroRevenueScheduleOppMap, 'Is_Non_Zero_Revenue_Schedule__c');
        }
        
    }
    public static void updateIsNonZeroRevenueScheduleOppLineItemOnDelete(List<OpportunityLineItemSchedule> oldList){
        Map<Id,Boolean> NonZeroRevenueScheduleOppMap = new Map<Id,Boolean>();
        for(OpportunityLineItemSchedule revSchedule:oldList){
            if(revSchedule.OpportunityId__c!=null){
                NonZeroRevenueScheduleOppMap.put(revSchedule.OpportunityId__c, FALSE);   
            }
        }
        
        if(NonZeroRevenueScheduleOppMap.values().size() > 0){
            updateOpportunityLineItem(NonZeroRevenueScheduleOppMap, 'Is_Non_Zero_Revenue_Schedule__c');
        }
    }
    
    public static void updateOpportunityLineItem(Map<Id,Boolean> NonZeroRevenueScheduleOppMap, String fieldName){
        List<OpportunityLineItem> oppProductsList = new List<OpportunityLineItem>([Select Id,OpportunityId,Is_Non_Zero_Revenue_Schedule__c,Is_Non_Zero_Sales_Revenue_Schedule__c 
                                                                                   from OpportunityLineItem where OpportunityId IN: NonZeroRevenueScheduleOppMap.keyset()]);
        for(OpportunityLineItem oppLineItem : oppProductsList){
            if(NonZeroRevenueScheduleOppMap.get(oppLineItem.OpportunityId) != null)
                oppLineItem.put(fieldName, NonZeroRevenueScheduleOppMap.get(oppLineItem.OpportunityId));
        }
        if(oppProductsList.size()>0)
            update oppProductsList; 
    }    
    
    
    /*public static void setRenewalAndNewBusinessAmount(List<OpportunityLineItemSchedule> newList) {
        for (OpportunityLineItemSchedule oppProductSchedule : newList) {
            oppProductSchedule.Renewal_Amount__c = (oppProductMap.get(oppProductSchedule.OpportunityLineItemId).Order_Type__c == 'Renewal') 
                ? ((1-(oppProductMap.get(oppProductSchedule.OpportunityLineItemId).Upsell__c / oppProductMap.get(oppProductSchedule.OpportunityLineItemId).UnitPrice )) * oppProductSchedule.Revenue) : 0.00;
            oppProductSchedule.New_Business_Amount__c = oppProductSchedule.Revenue - oppProductSchedule.Renewal_Amount__c;
        }
    }*/
    
    /*public static void setRevenueValueByRenewalAndNewBusinessAmounts(List<OpportunityLineItemSchedule> newList, Map<Id,OpportunityLineItemSchedule> oldMap) {
        for (OpportunityLineItemSchedule oppProductSchedule : newList) {
            if (oppProductSchedule.Renewal_Amount__c != oldMap.get(oppProductSchedule.Id).Renewal_Amount__c || oppProductSchedule.New_Business_Amount__c != oldMap.get(oppProductSchedule.Id).New_Business_Amount__c) {
 				oppProductSchedule.Revenue = oppProductSchedule.Renewal_Amount__c + oppProductSchedule.New_Business_Amount__c; 	               
            }
        }
    }*/
    
    /*public static void updateOppProductUpsellValue(List<OpportunityLineItemSchedule> newList) {
        Set<Id> oppProductIdSet = new Set<Id>();
        Set<Id> oppIdSet = new Set<Id>();
        List<OpportunityLineItem> oppProductListToUpdate = new List<OpportunityLineItem>();
        for (OpportunityLineItemSchedule oppProductSchedule : newList) {
        	oppProductIdSet.add(oppProductSchedule.OpportunityLineItemId);	    
        } 
        for (Id oppProductId : oppProductIdSet) {
        	Decimal upsell = 0.00;
            oppIdSet.add(oppProductMap.get(oppProductId).OpportunityId);
            for (OpportunityLineItemSchedule oppProductSchedule : oppProductToSchedulesMap.get(oppProductId)) {
            	upsell += oppProductSchedule.New_Business_Amount__c;	    
            }
            oppProductListToUpdate.add(new OpportunityLineItem(Id=oppProductId, Upsell__c=upsell));
        }  
        
        try {
            
            OpportunityTriggerHandler.skipTriggerLogic = true;
            OpportunityLineItemTriggerHandler.skipTriggerLogic = true;
            
            update oppProductListToUpdate;
            OpportunityLineItemTriggerHandler.futureUpdateOpportunityTotals(oppIdSet);
            
            OpportunityTriggerHandler.skipTriggerLogic = false;
            OpportunityLineItemTriggerHandler.skipTriggerLogic = false; 
            
        } catch (Exception ex) {
            ApexLogHandler.createLogAndSave('OpportunityLIScheduleTriggerHandler','updateOppProductUpsellValue', ex.getMessage(), ex);
        }        

    }*/
    
    public static void updateOppAndProductMinimumRevenueScheduleDate(List<OpportunityLineItemSchedule> newList) {
    	
        Set<Id> oppIdSet = new Set<Id>();
        Set<Id> oppLineItemIdSet = new Set<Id>();
        
        Map<Id,Date> oppMinDateMap = new Map<Id,Date>();
        Map<Id,Date> oppProductMinDateMap = new Map<Id,Date>();
        
        List<Opportunity> oppToUpdateList = new List<Opportunity>();
        List<OpportunityLineItem> oppLineItemToUpdateList = new List<OpportunityLineItem>();
                
        for (OpportunityLineItemSchedule oppLineItemSchedule : newList) {
        	oppIdSet.add(oppLineItemSchedule.OpportunityId__c);
            oppLineItemIdSet.add(oppLineItemSchedule.OpportunityLineItemId);
        }
        
        for (Id oppId : oppIdSet) {
        	oppMinDateMap.put(oppId, null);    
        }
        
        for (Id oppLineItemId : oppLineItemIdSet) {
        	oppProductMinDateMap.put(oppLineItemId, null);    
        }
        
        AggregateResult[] groupedResults = [SELECT OpportunityLineItem.OpportunityId, OpportunityLineItemId, MIN(ScheduleDate)MinScheduleDate 
      									  	FROM OpportunityLineItemSchedule
                                            WHERE OpportunityLineItem.OpportunityId IN :oppIdSet
      										GROUP BY OpportunityLineItem.OpportunityId, OpportunityLineItemId];
        for (AggregateResult ar : groupedResults) {
        	Id oppId = (Id)ar.get('OpportunityId');
            Id oppLineItemId = (Id)ar.get('OpportunityLineItemId');
            Date minDate = (Date)ar.get('MinScheduleDate');
            
            oppProductMinDateMap.put(oppLineItemId, minDate);            
            
            if (oppMinDateMap.get(oppId) == null || oppMinDateMap.get(oppId) > minDate) {
                oppMinDateMap.put(oppId, minDate);
            } 
        } 
        
        for (Id oppId : oppIdSet) {
            oppToUpdateList.add(new Opportunity(Id = oppId, Minimum_Revenue_Schedule_Date__c = oppMinDateMap.get(oppId)));
        }
        
        for (Id oppLineItemId : oppLineItemIdSet) {
            oppLineItemToUpdateList.add(new OpportunityLineItem(Id = oppLineItemId, Minimum_Revenue_Schedule_Date__c = oppProductMinDateMap.get(oppLineItemId)));
        }
        
        try {            
            
            OpportunityTriggerHandler.skipTriggerLogic = true;
            OpportunityLineItemTriggerHandler.skipTriggerLogic = true;
            
            update oppToUpdateList;
            update oppLineItemToUpdateList;
            
            OpportunityTriggerHandler.skipTriggerLogic = false;
            OpportunityLineItemTriggerHandler.skipTriggerLogic = false;
            
        } catch (Exception ex) {
            ApexLogHandler.createLogAndSave('OpportunityLIScheduleTriggerHandler','updateOppAndProductMinimumRevenueScheduleDate', ex.getMessage(), ex);
        }
        
    }
    
}