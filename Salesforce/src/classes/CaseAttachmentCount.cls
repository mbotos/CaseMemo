public with sharing class CaseAttachmentCount {
	public static void updateAllCases() {
		updateCaseIds(null, false);
	}
	
	public static void updateCaseIds(set<Id> caseIds, boolean isDelete) {
		map<Id, Case> cases;
		
		if (caseIds == null) {
			cases = new map<Id, Case>([select Id from Case]);			
		} else {
			cases = new map<Id, Case>([select Id, Attachment_Count__c from Case where Id in :caseIds]);
		}
		
		for (Case c : cases.values()) {
			c.Attachment_Count__c = 0;
		}
		
		for (AggregateResult result : [select ParentId, count(Id) from Attachment where ParentId in :cases.keySet() group by ParentId]) {
			decimal attachmentCount = (decimal)result.get('expr0');
			if (isDelete) {
				attachmentCount--;
			}
			cases.get((Id)result.get('ParentId')).Attachment_Count__c = attachmentCount;
		}
		
		update cases.values();		
	}
}