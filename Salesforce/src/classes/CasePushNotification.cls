public with sharing class CasePushNotification {
	public static PushNotificationInterface pushNotificationService = new UrbanAirship('Case Memo');
	
	public static map<Id, integer> newResponseCountByUserId(set<Id> ownerIds) {
		map<Id, integer> newResponseCountByUserId = new map<Id, integer>();
		map<Id, set<Id>> casesByUserId = new map<Id, set<Id>>();
		set<Id> caseIds = new set<Id>();
		
		for (Attachment attachment : [select OwnerId, ParentId from Attachment where OwnerId in :ownerIds]) {
			if (!casesByUserId.containsKey(attachment.OwnerId)) {
				casesByUserId.put(attachment.OwnerId, new set<Id>());
			}
			
			casesByUserId.get(attachment.OwnerId).add(attachment.ParentId);
			caseIds.add(attachment.ParentId);
			newResponseCountByUserId.put(attachment.OwnerId, 0);
		}
		
		for (Case c : [select Id from Case where Id in :caseIds and IsClosed = true and Response_Viewed__c = false]) {
			for (Id userId : casesByUserId.keySet()) {
				if (casesByUserId.get(userId).contains(c.Id)) {
					newResponseCountByUserId.put(userId, newResponseCountByUserId.get(userId) + 1);
				}
			}
		}
		
		system.debug(newResponseCountByUserId); 
	
		return newResponseCountByUserId;
	}


	@future(callout=true)
	public static void sendClosedNotification(set<Id> closedCaseIds) {	
		System.debug('sendClosedNotification ' + closedCaseIds);
		
		map<Id, list<Id>> casesByUserId = new map<Id, list<Id>>();
		
		for (Attachment attachment : [select OwnerId, ParentId from Attachment where ParentId in :closedCaseIds]) {
			if (!casesByUserId.containsKey(attachment.OwnerId)) {
				casesByUserId.put(attachment.OwnerId, new list<Id>());
			}
			
			casesByUserId.get(attachment.OwnerId).add(attachment.ParentId);
		}
	
		map<Id, integer> newResponseCountByUserId = newResponseCountByUserId(casesByUserId.keySet());
		
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
			
			pushNotificationService.queuePushNotification(d.Name, message, newResponseCountByUserId.get(d.User__c), caseInfo);
		}
		
		pushNotificationService.sendQueuedNotifications();
	}
}