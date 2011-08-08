Introduction
------------

CaseMemo for iPad is an iOS application that showcases Salesforce integration using OAuth, audio Attachments, and push notifications.

I'll be using it in my Dreamforce 11 presentation, [Session: Beyond the Force.com Toolkit for iOS](https://dreamevent.my.salesforce.com/a093000000BtXA1) (Dreamforce login required).


Contents
--------

iOS - iPad app
Salesforce - Salesforce code and configuration, see [How To Use Github and the Force.com IDE](http://blog.sforce.com/sforce/2011/04/how-to-use-git-github-force-com-ide-open-source-labs-apps.html)

The iOS code is commented in steps; searching for "STEP 1" will list the relevant comments. 
Search results are in line-number order, not alphabetical - you may need to jump around to follow them in a logical order.   

The steps are as follows:

1. Login with OAuth
2. Get list of Cases
3. Cache OAuth token
4. Get Case details
5. Get list of Attachments
6. Add loading indicators
7. Record audio
8. Save attachment
9. Play audio
10. Push notifications


Configuration
-------------

Steps 1-9 can be run in the iOS simulator; Step 10 requires a physical iOS device, iOS Developer account, and free [Urban Airship](http://urbanairship.com/) account. 

