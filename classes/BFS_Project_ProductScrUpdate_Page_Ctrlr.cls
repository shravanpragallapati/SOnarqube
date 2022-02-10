public class BFS_Project_ProductScrUpdate_Page_Ctrlr {
    @AuraEnabled
    public static void cloneScores(List<ID> IDsToClone, String recId) {
        String queryStr = 'SELECT ' 
            + String.join(new List<String>(Project_Product_Score__c.SObjectType.getDescribe().fields.getMap().keySet()), ',')
            + ',(SELECT ' 
            + String.join(new List<String>(Product_Score_Dictionary_List__c.SObjectType.getDescribe().fields.getMap().keySet()), ',')
            + ' FROM Product_Score_Dictionary_Lists__r) '
            + ' FROM Project_Product_Score__c WHERE ID IN: IDsToClone';

        List<Project_Product_Score__c> scoresToClone = Database.query(String.escapeSingleQuotes(queryStr)); //W-032476
        System.debug('scoresToClone'+scoresToClone);
        Map<ID, List<Product_Score_Dictionary_List__c>> scoreToNewDictListMap = new Map<ID, List<Product_Score_Dictionary_List__c>>();
        Map<ID, ID> oldIDToNewIDMap = new Map<ID, ID>();

        Set<ID> segmentIdSet = new Set<ID>();

        List<Project_Product_Score__c> scoresToInsert = new List<Project_Product_Score__c>();
        List<Product_Score_Dictionary_List__c> dictsToInsert = new List<Product_Score_Dictionary_List__c>();

        for (Project_Product_Score__c eachScore: scoresToClone) {
            Project_Product_Score__c clonedScore = eachScore.clone(false, true, false, false);
            clonedScore.clonedFrom__c = eachScore.ID;
            scoresToInsert.add(clonedScore);
            segmentIdSet.add(eachScore.BFS_Segment_Section__c);

            // If there are child dictionary lists, clone them and map them to the new cloned parent
            for(Product_Score_Dictionary_List__c eachDict: eachScore.Product_Score_Dictionary_Lists__r) {
                if (!scoreToNewDictListMap.containsKey(eachScore.ID)) {
                    scoreToNewDictListMap.put(eachScore.ID, new List<Product_Score_Dictionary_List__c>());
                }
                scoreToNewDictListMap.get(eachScore.ID).add(eachDict.clone(false, true, false, false));
            }
        }

        insert scoresToInsert;

        for (Project_Product_Score__c eachInsertedScore: scoresToInsert) {
            oldIDToNewIDMap.put(eachInsertedScore.clonedFrom__c, eachInsertedScore.ID);
        }

        for (Project_Product_Score__c eachInsertedScore: scoresToInsert) {
            if (scoreToNewDictListMap.containsKey(eachInsertedScore.clonedFrom__c)) {
                for (Product_Score_Dictionary_List__c eachDict: scoreToNewDictListMap.get(eachInsertedScore.clonedFrom__c)) {
                    //eachDict.Project_Product_Score__c = eachInsertedScore.ID;
                    eachDict.Project_Product_Score__c = eachInsertedScore.ID;
                    dictsToInsert.add(eachDict);
                }
            }
        }

        insert dictsToInsert;

        system.debug('segmentIDSet' + segmentIDSet);

        List<BFS_Segment_Section__c> segments = [Select Id, (Select Name, BFS_Automated_Product_Score__r.Name,BFS_Automated_Product_Score__r.BFS_ID__c From Project_Product_Scores__r ORDER BY Order__c ASC) 
            From BFS_Segment_Section__c 
            Where Id = :segmentIDSet AND Criteria_Code_Override__c = false];

        recalculateSegmentCriteria(segments);
    }

    @AuraEnabled
    public static List<productScoreWrapper> queryExistingScores(ID recordId)
    {
        List<Project_Product_Score__c> existingScores = [SELECT ID, Name, Alias__c, BFS_Automated_Product_Score__r.ID, BFS_Automated_Product_Score__r.SubType__c,BFS_Automated_Product_Score__r.BFS_ID__c, BFS_Automated_Product_Score__r.Name,
                dollar_per_each__c, dollar_per_M__c, Total_Extension_Calculation__c, Counts__c, Include_in_Billing_Worksheet__c, Qualifying_Criteria__c, Attachment_Section__c, Type__c, Subcode_I_E__c, Reject_Code__c,Billing_Code__c,Billing_Product_Description__c,//RJ add Billing_Code__c 
                Reject_Code_Description__c, AttachSegment__c, BFS_Attachment_Section__c, BFS_Attachment_Section__r.Order__c, BFS_Segment_Section__c, BFS_Segment_Section__r.Order__c, BFS_Segment_Section__r.Criteria_Code__c, 
                BFS_Segment_Section__r.Criteria_Code_Override__c,Order__c/*,Override_Billing_Code__c,Overwritten_Billing_Code__c*/
                FROM Project_Product_Score__c WHERE Project__c =: recordId ORDER BY BFS_Attachment_Section__r.Order__c,BFS_Segment_Section__r.Order__c,Order__c ASC LIMIT 10000];
        system.debug('Score found: '+existingScores.size());
        List<productScoreWrapper> wrapperList = new List<productScoreWrapper>();

        for (Project_Product_Score__c eachScore: existingScores)
        {
            productScoreWrapper scoreWrapper = new productScoreWrapper(eachScore, null);

            /*
            scoreWrapper.Name = eachScore.BFS_Automated_Product_Score__r.Name;
            scoreWrapper.BFSID = eachScore.BFS_Automated_Product_Score__r.BFS_ID__c;
            scoreWrapper.Included = false;
            scoreWrapper.Link = '/' + eachScore.BFS_Automated_Product_Score__r.ID;
            scoreWrapper.ID = eachScore.BFS_Automated_Product_Score__r.ID;

            scoreWrapper.JunctionID = eachScore.ID;
            scoreWrapper.DollarsPerEach = eachScore.dollar_per_each__c;
            scoreWrapper.DollarsPerMonth = eachScore.dollar_per_M__c;
            scoreWrapper.Counts = eachScore.Counts__c;
            scoreWrapper.IncludeInBilling = eachScore.Include_in_Billing_Worksheet__c;
            scoreWrapper.QualifyingCriteria = eachScore.Qualifying_Criteria__c;
            scoreWrapper.Type = eachScore.Type__c;

            if (eachScore.Attachment_Section__c != NULL)
            {
                scoreWrapper.AttachmentSection = eachScore.Attachment_Section__c;
            }
            else
            {
                scoreWrapper.AttachmentSection = '--None--';
            }
            */
            wrapperList.add(scoreWrapper);
        }

        return wrapperList;
    }

    @AuraEnabled
    public static List<productScoreWrapper> productScoresSearch(String searchField, String searchKey, String nameSearch, String projectId)
    {   
        
        String searchFields = String.escapeSingleQuotes(searchField);
        String searchKeys = String.escapeSingleQuotes(searchKey);
        String nameSearches = String.escapeSingleQuotes(nameSearch);
        String projectids = String.escapeSingleQuotes(projectId);
        
        if(searchFields == 'Name'){
            searchFields = 'BFS_Automated_Product_Score__r.Name';
        }
        System.debug('Received keys: '+searchFields+','+searchKeys);
        String excludeCustomScores = '';
        if(!(searchField == 'Type__c' && searchKey.startsWith('Custom')) ){
            excludeCustomScores = ' AND Type__c != \'Custom Attribute\'';
        }
        String queryString = 'SELECT ID, Name, Alias__c, BFS_Automated_Product_Score__r.ID, BFS_Automated_Product_Score__r.SubType__c,BFS_Automated_Product_Score__r.BFS_ID__c, BFS_Automated_Product_Score__r.Name,'+
                'dollar_per_each__c, dollar_per_M__c, Total_Extension_Calculation__c, Counts__c, Include_in_Billing_Worksheet__c, Qualifying_Criteria__c, Attachment_Section__c, Type__c, Subcode_I_E__c, Reject_Code__c,Billing_Code__c,Billing_Product_Description__c,'+
                'Reject_Code_Description__c, AttachSegment__c, BFS_Attachment_Section__c, BFS_Attachment_Section__r.Order__c, BFS_Segment_Section__c, BFS_Segment_Section__r.Order__c, BFS_Segment_Section__r.Criteria_Code__c,'+
                'BFS_Segment_Section__r.Criteria_Code_Override__c,Order__c '+
                'FROM Project_Product_Score__c WHERE Project__c =\''+ projectids+ '\' AND '+searchFields + ' LIKE \'%' + searchKeys + '%\'' + nameSearches + excludeCustomScores + ' Order by BFS_Automated_Product_Score__r.BFS_ID__c ASC' + ' LIMIT 10000' ;
        
        /*
        if(searchField == 'Type__c' && ((searchKey.startsWith('SAS') && searchKey.contains(';')) || (searchKey.startsWith('Custom Attribute') && searchKey.contains(';')))){
            String projId = searchKey.split(';')[1];
            List<Project__c> projectList = [SELECT TMS_Number__c FROM Project__c WHERE Id = :projId];

            List<BFS_Dictionary_TMS_Relationship__c> tmsList = [SELECT Id,BFS_Automated_Product_Score__c,Subcode_TMS__c 
                                                                  FROM BFS_Dictionary_TMS_Relationship__c
                                                                   WHERE Subcode_TMS__c = :projectList[0].TMS_Number__c];
            List<Id> autoProductScoreIdList = new List<id>();
            for(BFS_Dictionary_TMS_Relationship__c tmsRecord : tmsList) {
                autoProductScoreIdList.add(tmsRecord.BFS_Automated_Product_Score__c);
            } 

            queryString = 'SELECT ID, Name, Alias__c, BFS_Automated_Product_Score__r.ID, BFS_Automated_Product_Score__r.SubType__c,BFS_Automated_Product_Score__r.BFS_ID__c, BFS_Automated_Product_Score__r.Name,'+
                'dollar_per_each__c, dollar_per_M__c, Counts__c, Include_in_Billing_Worksheet__c, Qualifying_Criteria__c, Attachment_Section__c, Type__c, Subcode_I_E__c, Reject_Code__c,'+
                'Reject_Code_Description__c, AttachSegment__c, BFS_Attachment_Section__c, BFS_Attachment_Section__r.Order__c, BFS_Segment_Section__c, BFS_Segment_Section__r.Order__c, BFS_Segment_Section__r.Criteria_Code__c,'+
                'BFS_Segment_Section__r.Criteria_Code_Override__c,Order__c '+
                'FROM Project_Product_Score__c WHERE Project__c =\''+ projectId+ '\' AND '+ searchField + ' LIKE \'%' + searchKey.split(';')[0] + '%\' AND BFS_Automated_Product_Score__c IN:autoProductScoreIdList' + nameSearch +  excludeCustomScores + 'LIMIT 10000' ;

        }
        */

        system.debug('The query String: '+queryString);
        
        List<Project_Product_Score__c> allScores = Database.query(String.escapeSingleQuotes(queryString));
        system.debug('Found records: '+allScores.size());
        List<productScoreWrapper> wrapperList = new List<productScoreWrapper>();

        for (Project_Product_Score__c eachScore: allScores)
        {
            productScoreWrapper scoreWrapper = new productScoreWrapper(eachScore, null);
            wrapperList.add(scoreWrapper);
        }

        return wrapperList;
    }
    
    @AuraEnabled
    public static List<productScoreWrapper> reorderRecords(String objType, String recId, String dir, List<String> recordList){
        system.debug('Object Type: '+ objType);
        system.debug('Direction: '+ dir);
        String direction = (dir == 'up')?'ASC':'DESC';
        
        if(objType == 'Attachment'){
            List<BFS_Attachment_Section__c> updateList = new List<BFS_Attachment_Section__c>();
            BFS_Attachment_Section__c prevOrder;
            BFS_Attachment_Section__c clickedAttachOrder = [Select Id, Project__c, Order__c From BFS_Attachment_Section__c Where Id = :recId];
            String queryString = 'Select Id, Project__c, Order__c, (SELECT Id FROM Project_Product_Scores__r) From BFS_Attachment_Section__c Where Project__c = \''+String.escapeSingleQuotes(clickedAttachOrder.Project__c)+'\' Order By Order__c '+ direction;
            List<BFS_Attachment_Section__c> attachOrderList = Database.Query(queryString);
            system.debug('Attachment order list: '+ attachOrderList);
            for(BFS_Attachment_Section__c attachOrder: attachOrderList){
                if(!attachOrder.Project_Product_Scores__r.isEmpty()){
                    if(attachOrder.Id != clickedAttachOrder.Id){
                       system.debug('some record found');
                       prevOrder = attachOrder;
                    }else{
                       system.debug('same record found');
                       if(prevOrder != null){
                           System.debug('Orders before Swap: '+prevOrder.Order__c+','+attachOrder.Order__c);
                           Decimal tempOrder = attachOrder.Order__c;
                           attachOrder.Order__c = prevOrder.Order__c;
                           prevOrder.Order__c = tempOrder;
                           System.debug('Orders after Swap: '+prevOrder.Order__c+','+attachOrder.Order__c);
                           updateList.add(attachOrder);
                           updateList.add(prevOrder);
                       }
                       break;
                    }

                }
                
            }
            update updateList;
        }else if(objType == 'Segment'){
            List<BFS_Segment_Section__c> updateList = new List<BFS_Segment_Section__c>();
            BFS_Segment_Section__c prevOrder;
            BFS_Segment_Section__c clickedSegmentOrder = [Select Id, BFS_Attachment_Section__c, Order__c From BFS_Segment_Section__c Where Id = :recId];
            String queryString = 'Select Id, BFS_Attachment_Section__c, Order__c, (SELECT Id FROM Project_Product_Scores__r) From BFS_Segment_Section__c Where BFS_Attachment_Section__c = \''+String.escapeSingleQuotes(clickedSegmentOrder.BFS_Attachment_Section__c)+'\' Order By Order__c '+ direction;
            List<BFS_Segment_Section__c> segmentOrderList = Database.Query(queryString);
            System.debug('segmentOrderList'+segmentOrderList);
            for(BFS_Segment_Section__c segmentOrder: segmentOrderList){
                if(!segmentOrder.Project_Product_Scores__r.isEmpty()){
                    if(segmentOrder.Id != clickedSegmentOrder.Id){
                       //system.debug('some record found');
                       prevOrder = segmentOrder;
                    }else{
                        system.debug('same record found');
                        if(prevOrder != null){
                           //System.debug('Orders before Swap: '+prevOrder.Order__c+','+attachOrder.Order__c);
                           Decimal tempOrder = segmentOrder.Order__c;
                           segmentOrder.Order__c = prevOrder.Order__c;
                           prevOrder.Order__c = tempOrder;
                           //System.debug('Orders after Swap: '+prevOrder.Order__c+','+attachOrder.Order__c);
                           updateList.add(segmentOrder);
                           updateList.add(prevOrder);
                        }
                        break;
                    } 

                }
                
            }
            update updateList;

        }else if(objType == 'Row'){
            List<Project_Product_Score__c> updateList = new List<Project_Product_Score__c>();
            Project_Product_Score__c prevOrder;
            Project_Product_Score__c clickedRowOrder = [Select Id, BFS_Attachment_Section__c, BFS_Segment_Section__c, Order__c From Project_Product_Score__c Where Id = :recId];
            String queryString = 'Select Id, BFS_Attachment_Section__c, BFS_Segment_Section__c, Order__c From Project_Product_Score__c Where BFS_Attachment_Section__c = \''+String.escapeSingleQuotes(clickedRowOrder.BFS_Attachment_Section__c)+'\' AND BFS_Segment_Section__c = \''+String.escapeSingleQuotes(clickedRowOrder.BFS_Segment_Section__c) +'\' Order By Order__c '+ direction;
            List<Project_Product_Score__c> rowOrderList = Database.Query(queryString);

            for(Project_Product_Score__c rowOrder: rowOrderList){
               if(rowOrder.Id != clickedRowOrder.Id){
                   //system.debug('some record found');
                   prevOrder = rowOrder;
               }else{
                   system.debug('same record found');
                   if(prevOrder != null){
                       //System.debug('Orders before Swap: '+prevOrder.Order__c+','+attachOrder.Order__c);
                       Decimal tempOrder = rowOrder.Order__c;
                       rowOrder.Order__c = prevOrder.Order__c;
                       prevOrder.Order__c = tempOrder;
                       //System.debug('Orders after Swap: '+prevOrder.Order__c+','+attachOrder.Order__c);
                       updateList.add(rowOrder);
                       updateList.add(prevOrder);
                   }
                   break;
               } 
            }
            update updateList;

        }



        return refetchFilteredList(recordList);
    }
    
    @AuraEnabled
    public static List<productScoreWrapper> refetchFilteredList(List<String> recordList){
        List<Project_Product_Score__c> existingScores = [SELECT ID, Alias__c, BFS_Automated_Product_Score__r.ID, BFS_Automated_Product_Score__r.BFS_ID__c, BFS_Automated_Product_Score__r.Name,
                dollar_per_each__c, dollar_per_M__c, Total_Extension_Calculation__c, Counts__c, Include_in_Billing_Worksheet__c, Qualifying_Criteria__c, Attachment_Section__c, Type__c, Subcode_I_E__c, Reject_Code__c,Billing_Code__c,Billing_Product_Description__c,//RJ added 
                Reject_Code_Description__c, AttachSegment__c, BFS_Attachment_Section__c, BFS_Attachment_Section__r.Order__c, BFS_Segment_Section__c, BFS_Segment_Section__r.Order__c, Order__c
                FROM Project_Product_Score__c WHERE ID IN :recordList ORDER BY BFS_Attachment_Section__r.Order__c,BFS_Segment_Section__r.Order__c,Order__c ASC LIMIT 10000];
        //system.debug('retrieved records'+existingScores);
        system.debug('existingScores[' + existingScores.size() + ']=' + existingScores);  
        List<productScoreWrapper> wrapperList = new List<productScoreWrapper>();

        for (Project_Product_Score__c eachScore: existingScores)
        {
            productScoreWrapper scoreWrapper = new productScoreWrapper(eachScore, null);
            wrapperList.add(scoreWrapper);
        }
        
        return wrapperList;
    }

    /*
    @AuraEnabled
    public static List<productScoreWrapper> updateAttachmentOrder(List<String> OrderUpdate, List<String> recordList){
        List<BFS_Attachment_Section__c> listToUpdate = new List<BFS_Attachment_Section__c>();
        
        for(String eachRecordJSON: OrderUpdate){
            Map<String,Object> eachScore = (Map<String,Object>)JSON.deserializeUntyped(eachRecordJSON);
            if((String)eachScore.get('rowId') != '' && (String)eachScore.get('rowId') != null){
                BFS_Attachment_Section__c newOrder = new BFS_Attachment_Section__c();
                newOrder.Id = (String)eachScore.get('rowId');
                newOrder.Order__c = (Integer)eachScore.get('order');
                listToUpdate.add(newOrder);
            }
        }
        
        if(!listToUpdate.isEmpty()){
            update listToUpdate;
        }
        
        //Refetch filtered list of records using the recordList
        system.debug('used IDs'+recordList);
        List<Project_Product_Score__c> existingScores = [SELECT ID, Alias__c, BFS_Automated_Product_Score__r.ID, BFS_Automated_Product_Score__r.BFS_ID__c, BFS_Automated_Product_Score__r.Name,
                dollar_per_each__c, dollar_per_M__c, Counts__c, Include_in_Billing_Worksheet__c, Qualifying_Criteria__c, Attachment_Section__c, Type__c, Subcode_I_E__c, Reject_Code__c,
                Reject_Code_Description__c, AttachSegment__c, BFS_Attachment_Section__c, BFS_Attachment_Section__r.Order__c, BFS_Segment_Section__c, BFS_Segment_Section__r.Order__c, Order__c
                FROM Project_Product_Score__c WHERE ID IN :recordList ORDER BY Order_Formula__c ASC LIMIT 10000];
        system.debug('retrieved records'+existingScores);       
        List<productScoreWrapper> wrapperList = new List<productScoreWrapper>();

        for (Project_Product_Score__c eachScore: existingScores)
        {
            productScoreWrapper scoreWrapper = new productScoreWrapper(eachScore, null);
            wrapperList.add(scoreWrapper);
        }

        return wrapperList;
    }
    */
    /*
    @AuraEnabled
    public static List<productScoreWrapper> updateSegmentOrder(List<String> OrderUpdate, List<String> recordList){
        List<BFS_Segment_Section__c> listToUpdate = new List<BFS_Segment_Section__c>();
        
        for(String eachRecordJSON: OrderUpdate){
            Map<String,Object> eachScore = (Map<String,Object>)JSON.deserializeUntyped(eachRecordJSON);
            if((String)eachScore.get('rowId') != '' && (String)eachScore.get('rowId') != null){
                BFS_Segment_Section__c newOrder = new BFS_Segment_Section__c();
                newOrder.Id = (String)eachScore.get('rowId');
                newOrder.Order__c = (Integer)eachScore.get('order');
                listToUpdate.add(newOrder);
            }
        }
        
        if(!listToUpdate.isEmpty()){
            update listToUpdate;
        }
        
        
        //Refetch filtered list of records using the recordList
        system.debug('used IDs'+recordList);
        List<Project_Product_Score__c> existingScores = [SELECT ID, Alias__c, BFS_Automated_Product_Score__r.ID, BFS_Automated_Product_Score__r.BFS_ID__c, BFS_Automated_Product_Score__r.Name,
                dollar_per_each__c, dollar_per_M__c, Counts__c, Include_in_Billing_Worksheet__c, Qualifying_Criteria__c, Attachment_Section__c, Type__c, Subcode_I_E__c, Reject_Code__c,
                Reject_Code_Description__c, AttachSegment__c, BFS_Attachment_Section__c, BFS_Attachment_Section__r.Order__c, BFS_Segment_Section__c, BFS_Segment_Section__r.Order__c, Order__c
                FROM Project_Product_Score__c WHERE ID IN :recordList ORDER BY Order_Formula__c ASC LIMIT 10000];
        system.debug('retrieved records'+existingScores);       
        List<productScoreWrapper> wrapperList = new List<productScoreWrapper>();

        for (Project_Product_Score__c eachScore: existingScores)
        {
            productScoreWrapper scoreWrapper = new productScoreWrapper(eachScore, null);
            wrapperList.add(scoreWrapper);
        }

        return wrapperList;
    }
    */
    /*
    @AuraEnabled
    public static List<productScoreWrapper> updateRowOrder(List<String> OrderUpdate, List<String> recordList){
        List<Project_Product_Score__c> listToUpdate = new List<Project_Product_Score__c>();
        
        for(String eachRecordJSON: OrderUpdate){
            Map<String,Object> eachScore = (Map<String,Object>)JSON.deserializeUntyped(eachRecordJSON);
            if((String)eachScore.get('rowId') != '' && (String)eachScore.get('rowId') != null){
                Project_Product_Score__c newOrder = new Project_Product_Score__c();
                newOrder.Id = (String)eachScore.get('rowId');
                newOrder.Order__c = (Integer)eachScore.get('order');
                listToUpdate.add(newOrder);
            }
        }
        
        if(!listToUpdate.isEmpty()){
            update listToUpdate;
        }
        
        
        //Refetch filtered list of records using the recordList
        system.debug('used IDs'+recordList);
        List<Project_Product_Score__c> existingScores = [SELECT ID, Alias__c, BFS_Automated_Product_Score__r.ID, BFS_Automated_Product_Score__r.BFS_ID__c, BFS_Automated_Product_Score__r.Name,
                dollar_per_each__c, dollar_per_M__c, Counts__c, Include_in_Billing_Worksheet__c, Qualifying_Criteria__c, Attachment_Section__c, Type__c, Subcode_I_E__c, Reject_Code__c,
                Reject_Code_Description__c, AttachSegment__c, BFS_Attachment_Section__c, BFS_Attachment_Section__r.Order__c, BFS_Segment_Section__c, BFS_Segment_Section__r.Order__c, Order__c
                FROM Project_Product_Score__c WHERE ID IN :recordList ORDER BY Order_Formula__c ASC LIMIT 10000];
        system.debug('retrieved records'+existingScores);       
        List<productScoreWrapper> wrapperList = new List<productScoreWrapper>();

        for (Project_Product_Score__c eachScore: existingScores)
        {
            productScoreWrapper scoreWrapper = new productScoreWrapper(eachScore, null);
            wrapperList.add(scoreWrapper);
        }

        return wrapperList;
    }
    */
    @AuraEnabled
    public static void removeScores(List<ID> IDsToRemove, ID recordId)
    {
        List<Project_Product_Score__c> existingScores = [SELECT ID, BFS_Automated_Product_Score__r.ID, BFS_Automated_Product_Score__r.BFS_ID__c, BFS_Automated_Product_Score__r.Name FROM Project_Product_Score__c WHERE Project__c =: recordId LIMIT 10000];
        Set<ID> IDsToRemoveSet = new Set<ID>(IDsToRemove);
        List<Project_Product_Score__c> listToRemove = new List<Project_Product_Score__c>();

        for (Project_Product_Score__c eachScore: existingScores)
        {
            if (IDsToRemoveSet.contains(eachScore.ID))
            {
                listToRemove.add(eachScore);
            }
        }

        delete listToRemove;

        List<BFS_Segment_Section__c> segments = [Select Id, (Select Name, BFS_Automated_Product_Score__r.Name,BFS_Automated_Product_Score__r.BFS_ID__c From Project_Product_Scores__r ORDER BY Order__c ASC) 
            From BFS_Segment_Section__c 
            Where Project__c = :recordId];

        BFS_Project_ProductScrUpdate_Page_Ctrlr.recalculateSegmentCriteria(segments);
    }

    @AuraEnabled
    public static void addScores(List<String> scoresToAdd, ID recordId)
    {
        system.debug(scoresToAdd);
        List<Project_Product_Score__c> listToAdd = new List<Project_Product_Score__c>();

        for (String eachScoreJSON: scoresToAdd)
        {
            Map<String,Object> eachScore = (Map<String,Object>)JSON.deserializeUntyped(eachScoreJSON);
        
            Project_Product_Score__c newScore = new Project_Product_Score__c();
            newScore.BFS_Automated_Product_Score__c = (String)eachScore.get('ID');
            newScore.Project__c = recordId;
            //newScore.Alias__c = (String)eachScore.get('Type');
            newScore.Qualifying_Criteria__c = (String)eachScore.get('QualifyingCriteria');

            //I-1668, CP: More fields to add from bottom table
            if ((String)eachScore.get('Segment') == '--NONE--')
            {
                newScore.Segment__c = null;
            }
            else
            {
                newScore.Segment__c = (String)eachScore.get('Segment');
            }

            if ((String)eachScore.get('SubcodeIE') == '--NONE--')
            {
                newScore.Subcode_I_E__c = null;
            }
            else
            {
                newScore.Subcode_I_E__c = (String)eachScore.get('SubcodeIE');
            }
            newScore.Reject_Code__c = (String)eachScore.get('RejectCode');
            newScore.Reject_Code_Description__c = (String)eachScore.get('RejectCodeDescription');
            // I-1688, CP: END

            if ((String)eachScore.get('AttachmentSection') == '--NONE--')
            {
                newScore.Attachment_Section__c = null;
            }
            else
            {
                newScore.Attachment_Section__c = (String)eachScore.get('AttachmentSection');
            }
            
            listToAdd.add(newScore);
        }

        insert listToAdd;
    }

    @AuraEnabled
    public static void updateScores(List<String> scoresToUpdate, ID projID)
    {
        system.debug('scoresToUpdate' + scoresToUpdate);
        List<Project_Product_Score__c> listToUpdate = new List<Project_Product_Score__c>();
        Set<ID> segmentIDSet = new Set<ID>();

        for (String eachScoreJSON: scoresToUpdate)
        {
            Map<String,Object> eachScore = (Map<String,Object>)JSON.deserializeUntyped(eachScoreJSON);
            if((String)eachScore.get('JunctionID') != '' && (String)eachScore.get('JunctionID')!= null) {
                Project_Product_Score__c newScore = new Project_Product_Score__c();
                newScore.ID = (String)eachScore.get('JunctionID');
                //newScore.dollar_per_each__c = (Double)eachScore.get('DollarsPerEach');
                //newScore.dollar_per_M__c = (Double)eachScore.get('DollarsPerMonth');
                //newScore.Total_Extension_Calculation__c = (Double)eachScore.get('TotalExtension');
                //newScore.Counts__c = (Double)eachScore.get('Counts');
                newScore.Include_in_Billing_Worksheet__c = (Boolean)eachScore.get('IncludeInBilling');
                newScore.Qualifying_Criteria__c = (String)eachScore.get('QualifyingCriteria');
                //newScore.Alias__c = (String)eachScore.get('Alias');
                

                Map<String, Object> junctionMap = (Map<String, Object>) eachScore.get('junction');

                if (junctionMap != null) {
                    newScore.Counts__c = (Double)junctionMap.get('Counts__c');
                    newScore.dollar_per_each__c = (Double)junctionMap.get('dollar_per_each__c');
                    newScore.dollar_per_M__c = (Double)junctionMap.get('dollar_per_M__c'); 
                    newScore.Total_Extension_Calculation__c = (Double)junctionMap.get('Total_Extension_Calculation__c');
                    newScore.Alias__c = (String)junctionMap.get('Alias__c'); //RJ Updated for case 
                }

                /*newScore.Override_Billing_Code__c = (Boolean)eachScore.get('OverrideBillingCode');
                newScore.Overwritten_Billing_Code__c = (String)eachScore.get('OverwrittenBillingCode');*/

                if ((String)eachScore.get('AttachmentSection') == '--NONE--')
                {
                    newScore.Attachment_Section__c = null;
                }
                else
                {
                    newScore.Attachment_Section__c = (String)eachScore.get('AttachmentSection');
                }
                
                // 1/29/18, CP, BA needs to see more fields for updating scores
                if ((String)eachScore.get('Segment') == '--NONE--')
                {
                    newScore.AttachSegment__c = null;
                }
                else
                {
                    newScore.AttachSegment__c = (String)eachScore.get('Segment');
                }

                if ((String)eachScore.get('SubcodeIE') == '--NONE--')
                {
                    newScore.Subcode_I_E__c = null;
                }
                else
                {
                    newScore.Subcode_I_E__c = (String)eachScore.get('SubcodeIE');
                }

                newScore.Reject_Code__c = (String)eachScore.get('RejectCode');
                newScore.Reject_Code_Description__c = (String)eachScore.get('RejectCodeDescription');
                // 1/29/18, CP: END

                // 5/14/18: Put all segment IDs into set
                segmentIDSet.add((String)eachScore.get('SegmentOrderId'));

                listToUpdate.add(newScore); 
            }
        }

        system.debug(listToUpdate);
        update listToUpdate;

        // 5/14/18: Recalculate rated/reject segments if override is false
        List<BFS_Segment_Section__c> segments = [Select Id, (Select Name, BFS_Automated_Product_Score__r.Name,BFS_Automated_Product_Score__r.BFS_ID__c From Project_Product_Scores__r ORDER BY Order__c ASC) 
            From BFS_Segment_Section__c 
            Where Id = :segmentIDSet AND Criteria_Code_Override__c = false AND (BFS_Attachment_Section__r.Name = 'Reject Segment' OR BFS_Attachment_Section__r.Name = 'Rated Segment')];

        recalculateSegmentCriteria(segments);
    }

    // 5/11/18, CP - Query the segment record to pass to the helper function
    @AuraEnabled
    public static string recalculateSegmentFromComponent(ID recordId) {
        List<BFS_Segment_Section__c> segments = [Select Id, (Select Name, BFS_Automated_Product_Score__r.Name, BFS_Automated_Product_Score__r.BFS_ID__c From Project_Product_Scores__r ORDER BY Order__c ASC) From BFS_Segment_Section__c Where Id = :recordId];

        return recalculateSegmentCriteria(segments);
    }

    // 5/11/18, CP- New requirement, need to look thru all scores under a segment and calculate a default criteria string based on score names
    // Return the new calcCriteria so we can display on component without refreshing it
    public static string recalculateSegmentCriteria(List<BFS_Segment_Section__c> segments) {
        // Query for all segments under this project, and its child scores
        //List<BFS_Segment_Section__c> segments = [Select Id, (Select Name, BFS_Automated_Product_Score__r.Name From Project_Product_Scores__r) From BFS_Segment_Section__c Where Id = :recordIds];

        system.debug('charlie segments');
        system.debug(segments);
        for (BFS_Segment_Section__c eachSegment: segments) {
            // Construct criteria string for each segment
            String calcCriteria = '';
            system.debug('eachSegment.Project_Product_Scores__r.size()' + eachSegment.Project_Product_Scores__r.size());
            for(Project_Product_Score__c pps : eachSegment.Project_Product_Scores__r) {
                // if (pps.BFS_Automated_Product_Score__r.Name == null) {
                //     calcCriteria += '[' + pps.Name + '] AND ';  
                // }
                // else {
                //     calcCriteria += '[' + pps.BFS_Automated_Product_Score__r.Name + '] AND ';  
                // }
                calcCriteria += pps.BFS_Automated_Product_Score__r.BFS_ID__c + ' AND ';  
            }

            calcCriteria = calcCriteria.removeEnd(' AND ');

            // Update segment with new criteria string
            // Reset the overwrite flag on recalculate
            eachSegment.Criteria_Code__c = calcCriteria;
            eachSegment.Criteria_Code_Override__c = false;
        }
    
        update segments;

        if (segments.size() > 0 )
        return segments[0].Criteria_Code__c;
        else {
                return null;
        }
    }

    // 5/11/18, CP - New requirement, allow user to overwrite criteria string
    @AuraEnabled
    public static void overwriteCrit(String recordId, String newCriteriaString) {
        // Query the segment so we can find the old criteria string
        BFS_Segment_Section__c segSection = [SELECT ID, Name, Criteria_Code__c, Criteria_Code_Override__c FROM BFS_Segment_Section__c WHERE ID =: recordId];

        if (segSection.Criteria_Code__c == null || (segSection.Criteria_Code__c.trim().tolowercase() != newCriteriaString.trim().tolowercase())) {
            segSection.Criteria_Code_Override__c = true;
            segSection.Criteria_Code__c = newCriteriaString;

            update segSection;
        }
    }

    @AuraEnabled
    public static List<String> getAttachmentSectionValues()
    {
        Schema.DescribeFieldResult fResult = Project_Product_Score__c.Attachment_Section__c.getDescribe();
        List<Schema.PicklistEntry> ple = fResult.getPicklistValues();

        List<String> values = new List<String>();

        values.add('--NONE--');

        for (Schema.PicklistEntry f: ple)
        {
            values.add(f.getValue());
        }

        return values;
    }

    //I-1668, CP: Need more picklist values
    @AuraEnabled
    public static List<String> getSegmentValues()
    {
        Schema.DescribeFieldResult fResult = Project_Product_Score__c.Segment__c.getDescribe();
        List<Schema.PicklistEntry> ple = fResult.getPicklistValues();

        List<String> values = new List<String>();

        values.add('--NONE--');

        for (Schema.PicklistEntry f: ple)
        {
            values.add(f.getValue());
        }

        return values;
    }
    //6/27/18, CP: Query for Project to get basic Project Summary info
    @AuraEnabled
    public static Project__c getProject(ID projID) {
        Project__c thisProject = [SELECT ID,Project_Reference__c,Account__r.Name,Type__c,Sub_Type__c,Project_Sub_Type__c FROM Project__c WHERE ID =: projID];

        return thisProject;
    }
    @AuraEnabled
    public static List<String> getSubcodeIEValues()
    {
        Schema.DescribeFieldResult fResult = Project_Product_Score__c.Subcode_I_E__c.getDescribe();
        List<Schema.PicklistEntry> ple = fResult.getPicklistValues();

        List<String> values = new List<String>();

        values.add('--NONE--');

        for (Schema.PicklistEntry f: ple)
        {
            values.add(f.getValue());
        }

        return values;
    }
    //I-1668, CP: END

    /****Wrapper Classes***/
    public class productScoreWrapper{
        @AuraEnabled
        public Project_Product_Score__c junction {get;set;}
        @AuraEnabled
        public BFS_Automated_Product_Score__c score {get;set;}
        @AuraEnabled
        public Boolean Included {get;set;}

        /*
        @AuraEnabled
        public String ID {get; set;}
        @AuraEnabled
        public String Link {get; set;}
        @AuraEnabled
        public Boolean Included {get;set;}
        @AuraEnabled
        public String Name {get; set;}
        @AuraEnabled
        public String BFSID {get; set;}
        @AuraEnabled
        public String Type {get; set;}
        
        @AuraEnabled
        public String AttachmentSection {get; set;}
        @AuraEnabled
        public String JunctionID {get; set;}
        @AuraEnabled
        public Double DollarsPerEach {get; set;}
        @AuraEnabled
        public Double DollarsPerMonth {get; set;}
        @AuraEnabled
        public Double Counts {get; set;}
        @AuraEnabled
        public Boolean IncludeInBilling {get; set;}
        @AuraEnabled
        public String QualifyingCriteria {get; set;}
       
        */
        public productScoreWrapper(Project_Product_Score__c thisJunction, BFS_Automated_Product_Score__c thisScore){
            junction = thisJunction;
            score = thisScore;
            Included = false;
        }
    }
}