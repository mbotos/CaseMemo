public with sharing class MockPushNotificationService implements PushNotificationInterface {
	public static list<string> devicesRegistered = new list<string>();
	public static list<string> sentNotifications = new list<string>();
	public static list<string> queuedNotifications = new list<string>();

	public integer createDevice(string deviceToken) {
		devicesRegistered.add(deviceToken);
		return 200;		
	}
	
	public void registerDevices(set<Id> deviceIds) {		
	}
	
	public void sendPushNotification(string body) {
		sentNotifications.add(body);		
	}

	public void sendQueuedNotifications() {
		string body = '[' + Utility.joinStrings(queuedNotifications, ',') + ']';
		
		sentNotifications.add(body);
		queuedNotifications.clear();
	}

	public void queuePushNotification(string deviceToken, string message, integer badge, string json) {		
		queuedNotifications.add(deviceToken + message + badge + json);
	}
}