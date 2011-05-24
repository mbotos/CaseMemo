// STEP 6 c - Test initialization and trigger update of Attachment_Count__c on Case
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
	
	static void insertCaseAttachment() {	
		insertAttachment(myCase.Id);
	}			
	
	static void insertAttachment(id parentId) {				
		attachment = new Attachment(ParentId = parentId, Name = 'Test Attachment', Body = blob.valueOf('Test'));
		insert attachment;		
	}

    static testMethod void newCaseHasZeroAttachments() {
        System.assertEquals(0, getAttachmentCount());
    }
    
    static testMethod void newCaseAttachmentIncrementsCount() {
    	insertCaseAttachment();
    	
        System.assertEquals(1, getAttachmentCount());
    }
    
    static testMethod void deleteCaseAttachmentDecrementsCount() {
   		insertCaseAttachment();
   		delete attachment;
   		
        System.assertEquals(0, getAttachmentCount());
    }
    
    static testMethod void updateCasesPopulatesAllAttachmentCounts() {
    	integer caseCount = [select count() from Case];
    	CaseAttachmentCount.updateAllCases();
    	System.assertEquals(caseCount, [select count() from Case where Attachment_Count__c != null]);
    }
}