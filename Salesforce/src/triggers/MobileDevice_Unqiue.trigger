trigger MobileDevice_Unqiue on Mobile_Device__c (before insert, before update) {
    set<Id> userIds = new set<Id>();
    map<string, Mobile_Device__c> devicesByHash = new map<string, Mobile_Device__c>();
    string error = 'A device may only be registered once per User';
    
    for (Mobile_Device__c d : Trigger.new) {
        string hash = d.User__c + d.Name;
        if (devicesByHash.containsKey(hash)) {
            d.addError(error);
        } else {
            userIds.add(d.User__c);
            devicesByHash.put(hash, d);
        }
    }
    //system.debug('Trigger devices by hash: ' + devicesByHash);
    
    if (Trigger.isInsert) {
	    for (Mobile_Device__c d : [select Name, User__c from Mobile_Device__c where User__c in :userIds]) {
	        string hash = d.User__c + d.Name;
	        //System.debug('Existing hash: ' + hash);
	        if (devicesByHash.containsKey(hash)) {
	            devicesByHash.get(hash).addError(error);
	        }
	    }
    }

}