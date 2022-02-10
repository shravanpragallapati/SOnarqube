/**=====================================================================
* Experian
* Name: EmailHandler_GCSSErrorLog
* Description: Email handler to create GCSS specific cases for error logs
* Created Date: 7 March 2016
* Created By: Paul Kissick
*
* Date Modified       Modified By                    Description of the update
* Mar 16th, 2016      Paul Kissick                   Case 01906209 : Adding support for type to change to GCSS
* Jul 14th, 2021      Navya                          22362765 - Set up Automation for Cert Renewal 60 days prior to Cert Expiration
=====================================================================*/
global class EmailHandler_GCSSErrorLog implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        try {    
            Case c = new Case();
            
            String gcssType = '';
            String apexLogId = '';
            Pattern gcssTypePatt = Pattern.compile('(GCS|GCSS).*Support');
            
            List<Schema.PicklistEntry> caseTypePLE = Case.Type.getDescribe().getPicklistValues();
            for(Schema.PicklistEntry f : caseTypePLE) {
                String typeVal = f.getValue();
                if (gcssTypePatt.matcher(typeVal).matches()) {
                    gcssType = typeVal;
                }
            }
            //22362765 - Checking if subject contains certification warning
            if(email.subject.contains('{') && email.subject.contains('}')){    
                apexLogId = email.subject.substring(email.subject.lastIndexOf('{')+1,email.subject.lastIndexOf('}'));
                if(!String.isBlank(apexLogId)){
                    c.Apex_Log__c = apexLogId;
                }    
            }         
            c.Origin = 'Email';
            c.OwnerId = Experian_Global__c.getInstance().GCS_Queue_ID__c;
            c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Salesforce.com Support').getRecordTypeId();
            c.Status = 'Open';
            c.Priority = 'Medium';
            c.Type = gcssType;
            c.Subject = (String.isNotBlank(email.subject)) ? email.subject.mid(0,Case.Subject.getDescribe().getLength()) : 'No Subject';
            c.Description = (String.isNotBlank(email.plainTextBody)) ? email.plainTextBody.mid(0,Case.Description.getDescribe().getLength()) : 'No Email Body';
            c.Technical_Impact_Salesforce__c = true;
            c.Reason = 'Other area';
            c.Secondary_Case_Reason__c = 'System / technical issues';
            
            insert c;
            
            //List<Attachment> attsToInsert = new List<Attachment>();
            List<ContentVersion> lstcvInsert = new list<ContentVersion>();
            if (String.isNotBlank(email.htmlBody)) {
                /*attsToInsert.add(
                new Attachment(
                Name = 'EmailBody.html',
                ParentId = c.Id,
                Body = Blob.valueOf(email.htmlBody)
                )
                );*/
                lstcvInsert.add(EXP_GenericFileController.insertContentVersion(false,Blob.valueOf(email.htmlBody),'EmailBody.html','EmailBody.html'));
            }
            
            // Check for, and insert any attachments.
            if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
                
                List<Messaging.InboundEmail.BinaryAttachment> atts = email.binaryAttachments;
                
                for(Messaging.InboundEmail.BinaryAttachment att : atts) {
                    /*Attachment a = new Attachment();
                    a.ParentId = c.Id;
                    a.Body = att.Body;
                    a.Name = att.FileName;
                    attsToInsert.add(a);*/
                    
                    lstcvInsert.add(EXP_GenericFileController.insertContentVersion(false,att.Body,att.FileName,att.FileName));
                }
                
            }
            //insert attsToInsert;
            insert lstcvInsert;
            
            map<Id,ContentVersion> mapContDocs = EXP_GenericFileController.getContentVersions(lstcvInsert);
            list<ContentDocumentLink> lstContDocs = new list<ContentDocumentLink>();
            for(ContentVersion cv1 : mapContDocs.Values()){
                lstContDocs.add(EXP_GenericFileController.insertContentDocumentLink(false,cv1.ContentDocumentId,c.Id));
            }
            insert lstContDocs;
        }
        catch (Exception e) {
            result.success = false;
            result.message = 'System Error Occurred: '+e.getMessage();
        }
        
        return result;
    }
}