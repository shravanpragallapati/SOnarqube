/*----------------------------------------------------------------------------------------
* Date Modified                Modified By                  Description of the update
* 12th July 2021              Shweta Bhuria                 Added Custom label 'MyExperain' in SOQL Where Clause
* 
* ---------------------------------------------------------------------------------------
*/
public with sharing class CTCOM_TopicController{
    @AuraEnabled(cacheable=true)
    public static list<SubTopics> getSubTopics(string topicId) {
        list<SubTopics> lstSubTopics = new list<SubTopics>();
        
        list<string> listTileDefaultNames = new list<string>{'BannerCase.jpg','portal-dq.jpg','other-business-groups-consumer-information-services.jpg',
                                                        'other-business-groups-decision-analytics.jpg','other-business-groups-marketing-services.jpg','portal-alp.jpg','portal-cis.jpg'};
        
        String communityName = system.label.MyExperian;
        Id networkId = [select id, Name from Network where Name = :communityName limit 1].Id;
        ConnectApi.ManagedTopicCollection topics = ConnectApi.ManagedTopics.getManagedTopics(networkId, ConnectApi.ManagedTopicType.Navigational,3);
        integer i=0;
        for (ConnectApi.ManagedTopic managedTopic : topics.managedTopics) {
            System.debug('###managedTopic.topic.name = ' + ((ConnectApi.Topic)managedTopic.topic).name);
            if(topicId != ((ConnectApi.Topic)managedTopic.topic).Id && !Test.isRunningTest()){
                continue ;
            }
            Set<String> topicNames = new Set<String>();
            for (ConnectApi.ManagedTopic childManagedTopic : managedTopic.children) {
                
                SubTopics stopic = new SubTopics();
                stopic.topicName = ((ConnectApi.Topic)childManagedTopic.topic).name;
                stopic.topicId = ((ConnectApi.Topic)childManagedTopic.topic).Id;
                stopic.imageURL = ((ConnectApi.Topic)childManagedTopic.topic).images.coverImageUrl;
                stopic.topicURL = '/'+Label.ctcomCommunityName+'/s/topic/'+stopic.topicId+'/'+stopic.topicName;
                if(string.isBlank(stopic.imageURL)){
                    
                    if(i > listTileDefaultNames.size()-1){
                       stopic.defaultImage = 'experian.jpg';
                    }else{
                        stopic.defaultImage = listTileDefaultNames[i];
                        i++;
                    }
                }
                lstSubTopics.add(stopic);
                
                System.debug('### stopic:\n' + stopic);
            }
        }
        System.debug('### lstSubTopics:\n' + lstSubTopics);
        return lstSubTopics;        
    }
    
    public class SubTopics{
        @AuraEnabled public string topicName;
        @AuraEnabled public string topicId;
        @AuraEnabled public string imageURL;
        @AuraEnabled public string topicURL;
        @AuraEnabled public string defaultImage;
    }
}