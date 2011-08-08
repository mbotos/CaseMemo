@isTest
private class CasePushNotification_Test {
	static Case newCase;
	static list<Mobile_Device__c> devices = new list<Mobile_Device__c>();
	
	static {
		CasePushNotification.pushNotificationService = new MockPushNotificationService();
    	System.debug(MockPushNotificationService.sentNotifications);
		
		User user = EntityFactory.insertUser();
		
		// create enough devices to hit future limit if notified individually
		for (integer i = 0; i < 11; i++) {
			devices.add(new Mobile_Device__c(Name = string.valueOf(i), User__c = user.Id));
		}
		insert devices;

		newCase = new Case();
		insert newCase;
		
		System.runAs(user) {
			Attachment attachment = new Attachment(ParentId = newCase.Id, Name = 'Test Attachment.caf', Body = Blob.valueOf('test'));
			insert attachment;
		}
		
		newCase.Status = 'Closed';

		Test.startTest();
		update newCase;
		Test.stopTest();
	}

    
    static testMethod void notificationSentToEachDeviceInSingleBatch() {
    	System.debug(MockPushNotificationService.sentNotifications);
    	
    	System.assertEquals(1, MockPushNotificationService.sentNotifications.size());
    	
    	PushNotification notification = MockPushNotificationService.sentNotifications[0].notifications[0];
    	System.debug('notification ' + notification);
    	System.assertEquals(1, notification.badge);
    	//System.assertEquals(newCase.Id, notification.userInfo.get('caseIds'));
    }
}