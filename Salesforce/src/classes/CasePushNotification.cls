public with sharing class CasePushNotification {
	public static PushNotificationInterface pushNotificationService = new UrbanAirship('Case Memo');
	
	public static map<Id, integer> newResponseCountByOwnerId(set<Id> ownerIds) {
		map<Id, integer> newResponseCountByOwnerId = new map<Id, integer>();
		
		for (AggregateResult result : [select OwnerId, count(Id) from Case where OwnerId in :ownerIds and IsClosed = true and Response_Viewed__c = false group by OwnerId]) {
			newResponseCountByOwnerId.put((Id)result.get('OwnerId'), (integer)result.get('expr0'));	
		}
		
		system.debug(newResponseCountByOwnerId); 
	
		return newResponseCountByOwnerId;
	}


	@future(callout=true)
	public static void sendClosedNotification(set<Id> closedCaseIds) {	
		map<Id, list<Id>> casesByUserId = new map<Id, list<Id>>();
		
		for (Attachment attachment : [select OwnerId, ParentId from Attachment where ParentId in :closedCaseIds]) {
			if (!casesByUserId.containsKey(attachment.OwnerId)) {
				casesByUserId.put(attachment.OwnerId, new list<Id>());
			}
			
			casesByUserId.get(attachment.OwnerId).add(attachment.ParentId);
		}
	
		map<Id, integer> newResponseCountByOwnerId = newResponseCountByOwnerId(casesByUserId.keySet());
		
		for (Mobile_Device__c d : [select Name, User__c from Mobile_Device__c where User__c in :casesByUserId.keySet()]) {
			system.debug('Future push notification to User ' + d.User__c + ' on device ' + d.Name);
			JSONObject caseInfo = new JSONObject();
	
			list<Id> cases = casesByUserId.get(d.User__c);
			list<JsonObject.value> caseIds = new list<JsonObject.value>();	
				
			for (Id id : cases) {
				caseIds.add(new JsonObject.value(id));
			}
			
			caseInfo.putOpt('caseIds', new JsonObject.value(caseIds));
			caseInfo.putOpt('userId', new JsonObject.value(d.User__c));
	
			string message = cases.size() == 1 ? 'Your case has been closed' : 'You have ' + cases.size() + ' closed cases';
			System.debug(message);
			
			pushNotificationService.queuePushNotification(d.Name, message, newResponseCountByOwnerId.get(d.User__c), caseInfo);
		}
		
		pushNotificationService.sendQueuedNotifications();
	}
}