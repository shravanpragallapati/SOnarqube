/* ============================================================================
* Experian
* Name             : SalesRevenueScheduleTriggerHandler
* Description      : Handler class for SalesRevenueScheduleTriggerHandler
* Created Date     : June 6th 2021
* Created By       : Sai Navya Yerrabelli
* 
* 
* Date Modified        Modified By             Description of the update
* June 6th 2021        Sai Navya Yerrabelli    Case 22198811: To identify Opps with RevSchedules and SalesRevenueschedule that are non-zero 
*                                              and updating fields in Opportunity Line Item
* 
============================================================================================*/
public class SalesRevenueScheduleTriggerHandler {
    public static void afterInsert (List<Sales_Revenue_Schedule__c> newList) {
        updateNonZeroFlag(newList, null);
    }
    public static void afterupdate (List<Sales_Revenue_Schedule__c> newList, Map<Id,Sales_Revenue_Schedule__c> oldMap) {
        updateNonZeroFlag(newList, oldMap);
    }
    public static void afterDelete (List<Sales_Revenue_Schedule__c> oldList) {
        updateNonZeroFlagOnDelete(oldList);
    }
    
    
    public static void updateNonZeroFlag(List<Sales_Revenue_Schedule__c> newList, Map<Id,Sales_Revenue_Schedule__c> oldMap){
        Map<Id,Boolean> NonZeroSalesRevenueScheduleOppMap = new Map<Id,Boolean>();
        for(Sales_Revenue_Schedule__c revSchedule : newList){
            if((oldMap== null || 
                (oldMap != null && revSchedule.Revenue__c != oldMap.get(revSchedule.Id).Revenue__c)) && 
               revSchedule.Opportunity__c!=null){
                   if(revSchedule.Revenue__c > 0){
                       NonZeroSalesRevenueScheduleOppMap.put(revSchedule.Opportunity__c, TRUE);
                   }else{
                       NonZeroSalesRevenueScheduleOppMap.put(revSchedule.Opportunity__c, FALSE);                       
                   }
               }
        }
        if(NonZeroSalesRevenueScheduleOppMap.values().size() > 0){
            OpportunityLIScheduleTriggerHandler.updateOpportunityLineItem(NonZeroSalesRevenueScheduleOppMap, 'Is_Non_Zero_Sales_Revenue_Schedule__c');
        }
    }
    public static void updateNonZeroFlagOnDelete(List<Sales_Revenue_Schedule__c> oldList){
        Map<Id,Boolean> NonZeroSalesRevenueScheduleOppMap = new Map<Id,Boolean>();
        for(Sales_Revenue_Schedule__c revSchedule:oldList){
            if(revSchedule.Opportunity__c!=null){
                NonZeroSalesRevenueScheduleOppMap.put(revSchedule.Opportunity__c, FALSE);   
            }
        }
        
        if(NonZeroSalesRevenueScheduleOppMap.values().size() > 0){
            OpportunityLIScheduleTriggerHandler.updateOpportunityLineItem(NonZeroSalesRevenueScheduleOppMap, 'Is_Non_Zero_Sales_Revenue_Schedule__c');
        }
    }
}