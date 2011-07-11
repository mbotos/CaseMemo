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

		newCase = new Case(Status = 'Closed');
		insert newCase;
		
		System.runAs(user) {
			Test.startTest();
			Attachment attachment = new Attachment(ParentId = newCase.Id, Name = 'Test Attachment.caf', Body = Blob.valueOf('test'));
			insert attachment;
			Test.stopTest();
		}
	}

    
    static testMethod void notificationSentToEachDeviceInSingleBatch() {
    	System.debug(MockPushNotificationService.sentNotifications);
    	
    	System.assertEquals(1, MockPushNotificationService.sentNotifications.size());
    	
    	PushNotification notification = MockPushNotificationService.sentNotifications[0];
    	System.assertEquals(1, notification.badge);
    }
}