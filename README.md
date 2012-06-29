Introduction
------------

CaseMemo for iPad is an iOS application that showcases Salesforce.com integration using OAuth, audio Attachments, and push notifications. 

[Matthew Botos](http://linkedin.com/in/mbotos) presented a walkthrough of building the app in [Beyond the Force.com Toolkit for iOS](http://www.slideshare.net/matthewbotos/beyond-the-forcecom-toolkit-for-ios-dreamforce-2011) at Dreamforce 2011. The Speaker Notes in the slides contain additional details and links. You can also [watch the 51-minute video](http://www.youtube.com/watch?v=PntLl4mWBX4).


Contents
--------

The top-level directory contains:     

* iOS - iPad app  
* Salesforce - Salesforce.com code and configuration

To setup and deploy the Salesforce project in Eclipse to a [free developer org](http://www.developerforce.com/events/regular/registration.php?d=70130000000EjHb):     

1. File > Workspace > Other > Browse to the CaseMemo directory you cloned from Git
2. Window > Open Perspective > Force.com > Force.com
3. File > New Force.com Project > Enter credentials > None 
4. Right-click the src node of the file tree > Force.com > Save to Server > Yes

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

