/**=====================================================================
* Name: CTCOM_CaseController
* Description:
* Created Date: June 29th, 2020
* Created By: Dheekonda Ganesh
*
* Date Modified      Modified By                  Description of the update
*
=====================================================================*/
public with sharing class CTCOM_CaseController{
    @AuraEnabled(cacheable=true)
    public static casedetailswrapper getCaseDetails(string caseId) {
        Case cs = [select id, RecordType.DeveloperName,asset.Name, AssetId, Subcode__c from Case where Id=:caseId];
        map<string,string> mapAllowedRecType = new map<string,string>();
        casedetailswrapper cdw = new casedetailswrapper();
        cdw.rtDeveloperName = 'No Access';
        cdw.LWCTemplate = null;
        cdw.rtError = Label.ctcom_Access_Error_Message;
        cdw.caseAssetName = null;
        
        
        for( CTCOM_Support_Record_Types__mdt csrt : [select DeveloperName,LWC_Template__c from CTCOM_Support_Record_Types__mdt where DeveloperName=: cs.RecordType.DeveloperName]){
            
            cdw.rtDeveloperName = csrt.DeveloperName;
            cdw.LWCTemplate = csrt.LWC_Template__c;
            cdw.rtError = null;
            cdw.caseAssetName = cs.asset.Name;
            cdw.assetId = cs.AssetId;
            cdw.subCode = cs.Subcode__c;
        }
        
        return cdw;
    }
    @AuraEnabled(cacheable=true)
    public static list<caseCommentWrapper> getCaseComments(string caseId) {
        
        Case cs = [select Id, RecordType.DeveloperName,
                   (select id,subject,createddate from emailmessages)
                   from Case where Id=:caseId];
        system.debug('RecordType.DeveloperNameComme@@'+cs.RecordType.DeveloperName);
        list<CTCOM_Support_Record_Types__mdt> lstRT = new list<CTCOM_Support_Record_Types__mdt>();
        lstRT = [select DeveloperName,LWC_Template__c,Page_Layout__c from CTCOM_Support_Record_Types__mdt where DeveloperName =: cs.RecordType.DeveloperName];
        if(lstRT.isEmpty()){
            return new list<caseCommentWrapper>();
        }
        
        map<Id,CaseComment> mapCaseComments = new map<Id,CaseComment>([select Id, ParentId, CommentBody,CreatedBy.Name, CreatedBy.FirstName,CreatedBy.LastName,CreatedById, CreatedDate from CaseComment where ParentId=:caseId AND IsPublished = true order by CreatedDate DESC]);
        
        // set<Id> setCreatedById = new set<Id>();
        // for(CaseComment cCom:mapCaseComments.Values()){
        //     setCreatedById.add(cCom.CreatedById);
        // }
        // map<Id,User> mapUsers = new map<Id,User>([select id, IsPortalEnabled from User where Id IN:setCreatedById]);
        
        list<caseCommentWrapper> lstComments = new list<caseCommentWrapper>();
        for(CaseComment cCom:mapCaseComments.Values()){
            string creator = cCom.CreatedBy.FirstName+' '+cCom.CreatedBy.LastName;
            creator = creator == 'ITSM API User'?'Experian Internal User':creator;
            //if(mapUsers.containsKey(cCom.CreatedById) && mapUsers.get(cCom.CreatedById).IsPortalEnabled){
            //    cWrp.isPortalUser = true;
            // }
            caseCommentWrapper cWrp = new caseCommentWrapper(cCom.id, cCom.createdDate,cCom.commentbody,creator,true);
            lstComments.add(cWrp);
        }
        
        if(cs.emailmessages!=null){
            for(emailmessage em:cs.emailmessages){
                caseCommentWrapper cWrp = new caseCommentWrapper(em.id, em.createdDate,em.subject,null,false);
                lstComments.add(cWrp);
            }
        }
        lstComments.sort();
        return lstComments;
    }
    @AuraEnabled
    public static list<caseCommentWrapper> saveCaseComment(string caseId, string commentBody){
        system.debug('caseId@@@'+caseId+'commentBody@@@'+commentBody);
        CaseComment comm = new CaseComment();
        comm.ParentId = caseId;
        comm.IsPublished = true;
        comm.CommentBody = commentBody;
        insert comm;
        
        return getCaseComments(caseId);        
    }
    
    @AuraEnabled(cacheable=true)
    public static list<caseFileWrapper> getCaseFiles(Id caseId) {
        map<Id,Attachment> mapCaseAttach = new map<Id,Attachment>([select id, BodyLength from Attachment where ParentId=:caseId]);
        list<CombinedAttachment> lstComments = new list<CombinedAttachment>();
        Case cs = [select Id, RecordType.DeveloperName, 
                   (select id, Title, RecordType, CreatedDate,LastModifiedDate, CreatedBy.Name,CreatedBy.FirstName,CreatedBy.LastName,ContentSize from CombinedAttachments order by CreatedDate DESC)
                   from Case where Id=:caseId];
        
        system.debug('RecordType.DeveloperNameFiles@@'+cs.RecordType.DeveloperName);
        list<CTCOM_Support_Record_Types__mdt> lstRT = new list<CTCOM_Support_Record_Types__mdt>();
        lstRT = [select DeveloperName,LWC_Template__c,Page_Layout__c from CTCOM_Support_Record_Types__mdt where DeveloperName =: cs.RecordType.DeveloperName];
        if(lstRT.isEmpty()){
            return new list<caseFileWrapper>();
        }
        list<caseFileWrapper> lstFileWrap = new list<caseFileWrapper>();
        if(cs.CombinedAttachments!=null){
            
            for(CombinedAttachment cAtt:cs.CombinedAttachments){
                caseFileWrapper fWrap = new caseFileWrapper();
                fWrap.fileTitle = cAtt.Title;
                fWrap.fileCreator = cAtt.CreatedBy.FirstName+' '+cAtt.CreatedBy.LastName;
                fWrap.fileCreatedDate = cAtt.CreatedDate.format();
                
                if(cAtt.RecordType == 'Attachment' && mapCaseAttach.containsKey(cAtt.Id)){
                    fWrap.fileSize = mapCaseAttach.get(cAtt.Id).BodyLength+' bytes';                    
                    fWrap.fileDownloadURL = '/'+Label.ctcomCommunityName+'/servlet/servlet.FileDownload?file='+cAtt.Id;
                }else{
                    fWrap.fileSize = cAtt.ContentSize+' bytes';                    
                    fWrap.fileDownloadURL = '/'+Label.ctcomCommunityName+'/sfc/servlet.shepherd/document/download/'+cAtt.Id;
                }
                
                lstFileWrap.add(fWrap);
            }
            
        }
        
        
        return lstFileWrap;
    }
    
    
    @AuraEnabled(cacheable=true) 
    public static list<caseAssetListWrapper> getAssetList(string template) {
        
        list<caseAssetListWrapper> accountAssetList = new list<caseAssetListWrapper>();
        
        //Case 15245518
        if(template=='ctcomCaseCreateANDViewEDQ'){
            Set<Id> productId_Set = new Set<Id>();
            for (Asset accAsset : [SELECT Id, Name, AccountId, Product2.id
                                   FROM Asset
                                   WHERE Status__c = 'Live' AND Product2.Business_Line__c='Experian Data Quality'
                                   AND AccountId IN (
                                       SELECT AccountId 
                                       FROM User
                                       WHERE Id = :UserInfo.getUserId())
                                   ORDER BY Name ASC]){
                                       if(productId_Set == null|| !productId_Set.contains(accAsset.Product2.Id)){  
                                           caseAssetListWrapper assl = new caseAssetListWrapper();
                                           assl.value = accAsset.id;
                                           assl.label = accAsset.Name;                 
                                           accountAssetList.add(assl);
                                           productId_Set.add(accAsset.Product2.Id);
                                       }
                                   }
        } else {
            for (Asset accAsset : [SELECT Id, Name, AccountId
                                   FROM Asset
                                   WHERE Status__c = 'Live'
                                   AND AccountId IN (
                                       SELECT AccountId 
                                       FROM User
                                       WHERE Id = :UserInfo.getUserId())
                                   ORDER BY Name ASC]) {
                                       caseAssetListWrapper assl = new caseAssetListWrapper();
                                       assl.value = accAsset.id;
                                       assl.label = accAsset.Name;                 
                                       accountAssetList.add(assl);
                                   }
        }
        
        return accountAssetList;
    }
    
    @AuraEnabled(cacheable=true) 
    public static Id getAccountEntitlement() {
        Id entId;
        for (Entitlement ent : [SELECT Id FROM Entitlement
                                WHERE AccountId IN (
                                    SELECT AccountId 
                                    FROM User 
                                    WHERE Id = :UserInfo.getUserId()
                                )
                                AND AssetId = null
                                AND Status = 'Active'
                                ORDER BY CreatedDate DESC
                                LIMIT 1]) {
                                    entId = ent.Id;
                                }
        return entId;
    }
    
    
    @AuraEnabled(cacheable=true) 
    public static list<caseSubcodeWrapper> getSubcodes(String searchKey, String clonedSubCode) {
        
        list<caseSubcodeWrapper> subcodeList = new list<caseSubcodeWrapper>();
        
        List<User> curUser = [SELECT id, Contactid, Contact.Accountid FROM User WHERE id =: UserInfo.getUserId()];
        
        if (curUser.size() > 0 ) {
            if (curUser[0].Contact.Accountid != null){
                String escapedSearchKey = '';
                String query = 'SELECT id, Name, (SELECT id, Subscriber_Name__c, Subscriber_Code__c FROM Sub_Codes__r ';
                if(String.isNotBlank(searchKey)){
                    escapedSearchKey = String.escapeSingleQuotes(searchKey);
                    query += 'WHERE Subscriber_Name__c like \'%' + escapedSearchKey + '%\'' + ' OR Subscriber_Code__c like \'%' + escapedSearchKey + '%\'';
                }
                query += ' ORDER BY createddate, Subscriber_Code__c DESC LIMIT 20 ) FROM Account WHERE id =\'' + curUser[0].Contact.Accountid + '\'';
                List<Account> userAcc = Database.query(query);
                if(userAcc.size() > 0) {
                    for(Sub_Code__c sc : userAcc[0].Sub_Codes__r) {
                        subcodeList.add( new caseSubcodeWrapper(sc.id,sc.Subscriber_Code__c,sc.Subscriber_Name__c,false));
                    }
                }
            }
        }           
        if(String.isNotBlank(clonedSubCode)){
            List<String> clonedValues = clonedSubCode.split(';');
            for(Sub_Code__c sc : [SELECT Id, Subscriber_Name__c, Subscriber_Code__c FROM Sub_Code__c WHERE Subscriber_Code__c IN :clonedValues]){
                subcodeList.add(new caseSubcodeWrapper(sc.id,sc.Subscriber_Code__c,sc.Subscriber_Name__c,true));
            }
        }
        return subcodeList;
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(String searchKey, String accId, String caseId){
        try {
            String escapedSearchKey = string.escapeSingleQuotes(searchKey);
            String escapedAccId = string.escapeSingleQuotes(accId);
            List<String> memberIdList = new List<String>();
            for(CaseTeamMember ctm : [SELECT id, MemberId FROM CaseTeamMember WHERE ParentId =: string.escapeSingleQuotes(caseId)]){
                memberIdList.add(ctm.MemberId);
            }
            String query = 'SELECT id, name FROM Contact WHERE Status__c=\'Active\' AND Is_Community_User__c=TRUE AND Name LIKE \'%' + escapedSearchKey + '%\'  AND AccountId = \'' + escapedAccId + '\'';
            query += !memberIdList.isEmpty() ? ' AND id NOT IN: memberIdList' : '';
            system.debug('query '+ query);
            return Database.query(query);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<CaseTeamMember> getCaseTeamMembers(String caseId){
        try {
            String escapedCaseId = String.escapeSingleQuotes(caseId);
            return [SELECT id, Member.Name, TeamRoleId, TeamRole.Name FROM CaseTeamMember WHERE ParentId =: escapedCaseId AND TeamRole.Name='Collaborator'];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void saveCaseTeamMember(Map<String, String> caseTeamMemInfo){
        case_team_member__c ctm = new case_team_member__c();
        ctm.contact__c = caseTeamMemInfo.get('MemberId');
        ctm.case__c = caseTeamMemInfo.get('ParentId');
        insert ctm;        
    }

    @AuraEnabled
    public static void deleteCaseTeamMember(Map<String, String> caseTeamMemInfo){
        try {
            String contactId = caseTeamMemInfo.get('MemberId');
            String caseId = caseTeamMemInfo.get('ParentId');
            delete [SELECT Id FROM case_team_member__c WHERE contact__c = :contactId AND case__c = :caseId LIMIT 1]; 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class caseFileWrapper{
        @AuraEnabled public string fileTitle;
        @AuraEnabled public string fileCreator;
        @AuraEnabled public string fileCreatedDate;
        @AuraEnabled public string fileSize;
        @AuraEnabled public string fileDownloadURL;
    }
    
    public class caseCommentWrapper implements Comparable {
        @AuraEnabled public id commId;
        @AuraEnabled public datetime CreatedDate;
        @AuraEnabled public string CommentBody ;
        //@AuraEnabled public boolean isPortalUser;  
        @AuraEnabled public string commCreator;
        @AuraEnabled public boolean isComment;
        
        public caseCommentWrapper(id cid, datetime cdt, string cb, string cc, boolean ic)
        {
            commId = cid;
            createddate = cdt;
            commentbody = cb;
            //isPortalUser = ipu;  
            commCreator =cc;
            isComment = ic;
        }
        
        public Integer compareTo(Object objToCompare) {   
            caseCommentWrapper compareTo = (caseCommentWrapper)objToCompare;        
            if(createddate == compareTo.createddate) return 0;
            if(createddate < compareTo.createddate) return 1;
            return -1;
        }
        
    }
    
    public class caseAssetListWrapper{
        @AuraEnabled public string value;
        @AuraEnabled public string label;     
    }
    
    public class caseDetailsWrapper{
        @AuraEnabled public string rtDeveloperName;
        @AuraEnabled public string LWCTemplate;
        @AuraEnabled public string rtError;
        @AuraEnabled public string caseAssetName;
        @AuraEnabled public string assetId;
        @AuraEnabled public string subCode;
    }
    
    public class caseSubcodeWrapper {
        @AuraEnabled public string subcodeId ;
        @AuraEnabled public string subcodeCode ;
        @AuraEnabled public string subcodeName;
        @AuraEnabled public boolean selected  ;
        
        public caseSubcodeWrapper(id subid,string subc, string subn, boolean subSelected)
        {
            subcodeId = subid;
            subcodeCode = subc;
            subcodeName = subn;
            selected = subSelected;
        }
        
        
    }
}