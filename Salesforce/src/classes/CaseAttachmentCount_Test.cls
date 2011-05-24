@isTest
private class CaseAttachmentCount_Test {
	static Case myCase = new Case();
	static Attachment attachment;
	
	static {
		insert myCase;
	}
	
	static decimal getAttachmentCount() {
		return [select Attachment_Count__c from Case where id = :myCase.Id].Attachment_Count__c;
	}
	
	static void insertAttachment() {				
		attachment = new Attachment(ParentId = myCase.Id, Name = 'Test Attachment', Body = blob.valueOf('Test'));
		insert attachment;		
	}

    static testMethod void newCaseHasZeroAttachments() {
        System.assertEquals(0, getAttachmentCount());
    }
    
    static testMethod void newCaseAttachmentIncrementsCount() {
    	insertAttachment();
    	
        System.assertEquals(1, getAttachmentCount());
    }
    
    static testMethod void deleteCaseAttachmentDecrementsCount() {
   		insertAttachment();
   		delete attachment;
   		
        System.assertEquals(0, getAttachmentCount());
    }
    
    static testMethod void updateCasesPopulatesAllAttachmentCounts() {
    	integer caseCount = [select count() from Case];
    	CaseAttachmentCount.updateAllCases();
    	System.assertEquals(caseCount, [select count() from Case where Attachment_Count__c != null]);
    }
}