trigger Case_PushNotification on Case (after insert, after update) {
	set<Id> closedCases = new set<Id>();
	
	for (Id id : Trigger.newMap.keySet()) {
		if (Trigger.newMap.get(id).IsClosed && 
			((Trigger.isInsert && Trigger.newMap.get(id).Status == 'Closed') || !Trigger.oldMap.get(id).IsClosed)) {
				
			closedCases.add(id);
		}
	}

	CasePushNotification.sendClosedNotification(closedCases);
}