/**=====================================================================
 * Experian
 * Name: Test_articlefeedbackNotification
 * Description: Provide test coverage to the class "articlefeedbackNotification"
 * Created Date: June 29th, 2021
 * Created By: Shweta Bhuria
 *
 * Date Modified                Modified By                  Description of the update
 * 
 =====================================================================*/

@istest
public class Test_articlefeedbackNotification {
    
    static testMethod void testArticleNotificationsforSingleSubriber() {
        knowledge__kav newArticle = new knowledge__kav(Title='test',summary='xyz',
                                                       urlname='xyz',Article_Owner__c = userinfo.getUserId(),
                                                       Answer__c = 'Test Answer');
        insert newArticle;
        knowledge__kav article = [SELECT Id,Title,knowledgeArticleId from Knowledge__kav limit 1];
        
        afl__afl_Article_Feedback__c feedback = new afl__afl_Article_Feedback__c();
        feedback.Name = 'testfb';
        feedback.afl__Knowledge_Article_Version_Id__c = article.id;
        feedback.afl__Article_Title__c = article.title;
        insert feedback;
        
        List<Id> feedbackIdList = new List<Id>();
        feedbackIdList.add(feedBack.id);
        articleFeedbackNotification.sendEmailNotification(feedbackIdList);
    }    
}