// STEP 6 c - Update Attachment_Count__c on Case
trigger Attachment_CaseCount on Attachment (before delete, after insert, after undelete) {
	// use before delete so we still get an aggregate count
	set<Id> caseIds = new set<Id>();
	list<Attachment> attachments;
	
	if (Trigger.isDelete) {
		attachments = Trigger.old;
	} else {
		attachments = Trigger.new;
	}
	
	for (Attachment attachment : attachments) {
		caseIds.add(attachment.ParentId);
	}
	
	CaseAttachmentCount.updateCaseIds(caseIds, Trigger.isDelete);
}