/**=====================================================================
 * Experian
 * Name: articleFeedbackNotification
 * Description: 22035363 - Sends Email Notification Article Owner when feedback is submitted
 * Created Date: June 29th, 2021. 
 * Created By: Shweta Bhuria
 *
 * Date Modified                Modified By                  Description of the update
 * 
 =====================================================================*/
public class articleFeedbackNotification {

    @InvocableMethod(label='Send email notification to Article Owner for feedbacks')
    public static void sendEmailNotification(List<Id> feedBackId){
        
        afl__afl_Article_Feedback__c articleFeedback = [SELECT Id,Name,afl__Article_Link__c,afl__Knowledge_Article_Version_Id__c
                                                        FROM afl__afl_Article_Feedback__c WHERE Id = :feedbackId LIMIT 1];
        
        knowledge__kav knowledgeRecord = [SELECT Id,Title,Article_Owner__c,Article_Owner__r.Email,Article_Owner__r.Name 
                                          FROM Knowledge__kav WHERE 
                                          Id = :articleFeedback.afl__Knowledge_Article_Version_Id__c LIMIT 1];
        
        EmailTemplate template=[SELECT Id, Name, Subject, HtmlValue,body FROM EmailTemplate where developerName='Feedback_Notification_to_Owner']; 
        
        If(template != null && knowledgeRecord.Article_Owner__c != null){
            List<string> toAddresses = new List<string>();
            toAddresses.add(knowledgeRecord.Article_Owner__r.Email);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            string subject = template.subject.replace('{!Knowledge__kav.Title}',knowledgeRecord.Title);
            string body = template.HtmlValue.replace('{!Knowledge__kav.Title}', knowledgeRecord.Title);
            body = body.replace('{!Knowledge__kav.Article_Owner__c}',knowledgeRecord.Article_Owner__r.Name);
            body = body.replace('{!afl__afl_Article_Feedback__c.Name}',articleFeedback.Name);
            string url = URL.getOrgDomainUrl().toExternalForm() + '/'+ articleFeedback.Id;
            body = body.replace('{!afl__afl_Article_Feedback__c.afl__Article_Link__c}',url);
            mail.setToAddresses(toAddresses);
            mail.setBccSender(false);
            mail.setSubject(subject);
            mail.setHtmlBody(body);
            mail.setUseSignature(false);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
    }
}