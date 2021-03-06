/**
*
* @file  /Users/Christopher/Documents/sites/christophervachon.com/services/socialMedia.cfc
* @author  Christopher Vachon
* @description unified interface and cache for social media feeds
*
*/

component output="false" displayname=""  {

	VARIABLES.websiteSettings = javaCast("Null","");
	VARIABLES.twitter = javaCast("Null","");
	VARIABLES.facebook = javaCast("Null","");

	VARIABLES.cache = {};

	public function init() { 

		if (structKeyExists(ARGUMENTS,"websiteSettings")) { this.setWebsiteSettings(ARGUMENTS.websiteSettings); }

		try {
			if (this.canConnectToTwitter()) { this.connectToTwitter(); }
			if (this.canConnectToFacebook()) { this.connectToFacebook(); }
		} catch (any e) {}

		return this; 
	} // close init


	public boolean function canConnectToFacebook() {
		if (this.hasWebsiteSettings()) {
			if (
				(len(this.getWebsiteSettings().getProperty("FB_appID")) > 3) && 
				(len(this.getWebsiteSettings().getProperty("FB_appSecret")) > 3) && 
				(len(this.getWebsiteSettings().getProperty("FB_AppUserToken")) > 3) && 
				(len(this.getWebsiteSettings().getProperty("FB_objectID")) > 3)
			) {
				return true;
			}
		}
		return false;
	} // close canConnectToFacebook


	public void function connectToFacebook() {
		if (this.canConnectToFacebook()) {
			var _appID = this.getWebsiteSettings().getProperty("FB_appID");
			var _appSecrect = this.getWebsiteSettings().getProperty("FB_appSecret");
			var _accessToken = "#_appID#|#_appSecrect#";

			VARIABLES.facebook = new services.facebook.FacebookGraphAPI(_accessToken,_appID);
		} else {
			throw("Can not connect to Facebook");
		}
	} // close connectToFacebook


	public services.facebook.FacebookGraphAPI function getFacebook() {
		if (this.isConnectedToFacebook()) {
			return VARIABLES.facebook;
		} else {
			throw("Facebook is Not Connected");
		}
	} // close getFacebook


	public boolean function isConnectedToFacebook() {
		return (!isNull(VARIABLES.facebook));
	} // close isConnectedToFacebook


	public array function getFacebookPostsForObject(string objectID = this.getWebsiteSettings().getProperty("FB_objectID"), numeric limit = 10) {
		if (isConnectedToFacebook()) {
			if (!structKeyExists(VARIABLES.cache,"facebook")) { VARIABLES.cache.facebook = {}; } 
			if (!structKeyExists(VARIABLES.cache.facebook,"feeds")) { VARIABLES.cache.facebook.feeds = {}; } 
			if (!structKeyExists(VARIABLES.cache.facebook.feeds,ARGUMENTS.objectID)) { VARIABLES.cache.facebook.feeds[ARGUMENTS.objectID] = {}; } 

			if (
				(!structKeyExists(VARIABLES.cache.facebook.feeds[ARGUMENTS.objectID],"feed")) ||
				(!structKeyExists(VARIABLES.cache.facebook.feeds[ARGUMENTS.objectID],"cacheTime")) ||
				(DateDiff("n",VARIABLES.cache.facebook.feeds[ARGUMENTS.objectID].cacheTime,now()) > 15)
			) {
				var _return = this.getFacebook().getObject(
					id=ARGUMENTS.objectID,
					fields="feed.limit(#ARGUMENTS.limit#)"
				);
				if (structKeyExists(_return,"feed")) {
					VARIABLES.cache.facebook.feeds[ARGUMENTS.objectID].cacheTime = now();
					VARIABLES.cache.facebook.feeds[ARGUMENTS.objectID].feed = _return.feed.data;
				} else {
					throw("An Error Occured");
				}
			}
			return VARIABLES.cache.facebook.feeds[ARGUMENTS.objectID].feed;
		}
	} // close getFacebookPostsForObject


	public struct function getFacebookUserDetails(string objectID = this.getWebsiteSettings().getFB_objectID()) {
		if (this.isConnectedToFacebook()) {
			if (!structKeyExists(VARIABLES.cache,"facebook")) { VARIABLES.cache.facebook = {}; }
			if (!structKeyExists(VARIABLES.cache.facebook,"userDetails")) { VARIABLES.cache.facebook.userDetails = {}; }
			if (!structKeyExists(VARIABLES.cache.facebook.userDetails, ARGUMENTS.objectID)) {
				VARIABLES.cache.facebook.userDetails[ARGUMENTS.objectID] = this.getFacebook().getObject(
					id=ARGUMENTS.objectID,
					fields="name,username,link,cover,picture"
				);
			}
			return VARIABLES.cache.facebook.userDetails[ARGUMENTS.objectID];
		}
	} // close getFacebookUserDetails


	public boolean function canConnectToTwitter() {
		if (this.hasWebsiteSettings()) {
			if (
				(len(this.getWebsiteSettings().getProperty("TW_UserName")) > 3) && 
				(len(this.getWebsiteSettings().getProperty("TW_ConsumerKey")) > 3) && 
				(len(this.getWebsiteSettings().getProperty("TW_ConsumerSecret")) > 3) && 
				(len(this.getWebsiteSettings().getProperty("TW_AccessToken")) > 3) && 
				(len(this.getWebsiteSettings().getProperty("TW_AccessTokenSecret")) > 3)
			) {
				return true;
			}
		}
		return false;
	} // close canConnectToTwitter


	public void function connectToTwitter() {
		if (this.canConnectToTwitter()) {
			VARIABLES.twitter = createObject('component','services.coldfumonkeh.monkehTweet').init(
				consumerKey			= this.getWebsiteSettings().getTW_ConsumerKey(),
				consumerSecret		= this.getWebsiteSettings().getTW_ConsumerSecret(),
				oauthToken			= this.getWebsiteSettings().getTW_AccessToken(),
				oauthTokenSecret 	= this.getWebsiteSettings().getTW_AccessTokenSecret(),
				userAccountName		= this.getWebsiteSettings().getTW_UserName(),
				parseResults		= true
			);
		} else {
			throw("Can Not Connect to Twitter");
		}
	} // close connectToTwitter


	public struct function getTwitterUserDetails(string screenName = this.getWebsiteSettings().getTW_UserName()) {
		if (this.isConnectedToTwitter()) {
			if (!structKeyExists(VARIABLES.cache,"twitter")) { VARIABLES.cache.twitter = {}; }
			if (!structKeyExists(VARIABLES.cache.twitter,"userDetails")) { VARIABLES.cache.twitter.userDetails = {}; }
			if (!structKeyExists(VARIABLES.cache.twitter.userDetails, ARGUMENTS.screenName)) {
				VARIABLES.cache.twitter.userDetails[ARGUMENTS.screenName] = this.getTwitter().getUserDetails(screen_name=ARGUMENTS.screenName);
			}
			return VARIABLES.cache.twitter.userDetails[ARGUMENTS.screenName];
		}
	} // close getTwitterUserDetails


	public array function getTwitterUserFeed(string screenName = this.getWebsiteSettings().getTW_UserName(), numeric itemCount = 15) {
		if (this.isConnectedToTwitter()) {

			if (!structKeyExists(VARIABLES.cache,"twitter")) { VARIABLES.cache.twitter = {}; }
			if (!structKeyExists(VARIABLES.cache.twitter,"feeds")) { VARIABLES.cache.twitter.feeds = {}; }
			if (!structKeyExists(VARIABLES.cache.twitter.feeds,ARGUMENTS.screenName)) { VARIABLES.cache.twitter.feeds[ARGUMENTS.screenName] = {}; }

			if (
				(!structKeyExists(VARIABLES.cache.twitter.feeds[ARGUMENTS.screenName],"feed")) ||
				(!structKeyExists(VARIABLES.cache.twitter.feeds[ARGUMENTS.screenName],"cacheTime")) ||
				(DateDiff("n",VARIABLES.cache.twitter.feeds[ARGUMENTS.screenName].cacheTime,now()) > 7)
			) {
				VARIABLES.cache.twitter.feeds[ARGUMENTS.screenName].cacheTime = now();
				VARIABLES.cache.twitter.feeds[ARGUMENTS.screenName].feed = this.getTwitter().getUserTimeline(screen_name=ARGUMENTS.screenName,count=ARGUMENTS.itemCount,exclude_replies=false);
			}
			return VARIABLES.cache.twitter.feeds[ARGUMENTS.screenName].feed;
		}
	} // close getTwitterUserFeed


	public services.coldfumonkeh.monkehTweet function getTwitter() {
		if (!this.isConnectedToTwitter()) { throw("Twitter is Not Connected"); }
		return VARIABLES.twitter;
	} // close getTwitter


	public boolean function isConnectedToTwitter() {
		return (!isNull(VARIABLES.twitter));
	} // close isConnectedToTwitter


	public void function setWebsiteSettings(required models.websiteSettings websiteSettings) {
		VARIABLES.websiteSettings = ARGUMENTS.websiteSettings;
	} // close setWebsiteSettings


	public boolean function hasWebsiteSettings() {
		return (!isNull(VARIABLES.websiteSettings));
	} // close hasWebsiteSettings


	public models.websiteSettings function getWebsiteSettings() {
		if (this.hasWebsiteSettings()) {
			return VARIABLES.websiteSettings;
		} else {
			throw("Website Settings Not Set");
		}
	} // close getWebsiteSettings


	public string function formatPostAsHTML(required string post) {
		var _returnPost = "<p>" & reReplace(ARGUMENTS.post,"\n\r|\r\n|\r|\n","<br>","ALL") & "</p>";
		_returnPost = reReplaceNoCase(_returnPost,"(https?\:\/\/[^\s|\<]+)","<a href='\1' target='_blank'>\1</a>","ALL");
		_returnPost = reReplaceNoCase(_returnPost,"(\##(\w+))","<a href='https://twitter.com/search?q=%23\2' class='hashtag' target='_blank'>\1</a>","ALL");
		_returnPost = reReplaceNoCase(_returnPost,"(@([a-zA-Z0-9-_\.]+))","<a href='https://twitter.com/\2' target='_blank' class='twitterUser' data-screenname='\2'>\1</a>","ALL");
		return _returnPost;
	} // close formatPostAsHTML


	public date function convertTimeStampToDateTime(required string timestamp) {
		var regEx_timestamp_twitter = "(\w+)\s(\w+)\s(\d+)\s(\d+)\:(\d+)\:(\d+)\s\+\d+\s(\d+)";
		var regEx_timestamp_facebook = "(\d{4})-(\d{1,2})-(\d{1,2})T(\d{1,2}):(\d{1,2}):(\d{1,2})\+\d{4}";

		if (arrayLen(REMatchNoCase(regEx_timestamp_twitter,ARGUMENTS.timestamp)) > 0) {
			var dateParts = {
				year = reReplace(ARGUMENTS.timestamp, regEx_timestamp_twitter, "\7", "one"),
				month = int(month(reReplace(ARGUMENTS.timestamp, regEx_timestamp_twitter, "\2 1 \7", "one"))), // twitter returns Feb instread of 2
				day = int(reReplace(ARGUMENTS.timestamp, regEx_timestamp_twitter, "\3", "one")),
				hour = int(reReplace(ARGUMENTS.timestamp, regEx_timestamp_twitter, "\4", "one")),
				min = int(reReplace(ARGUMENTS.timestamp, regEx_timestamp_twitter, "\5", "one")),
				sec = int(reReplace(ARGUMENTS.timestamp, regEx_timestamp_twitter, "\6", "one"))
			};
		} else if (arrayLen(REMatchNoCase(regEx_timestamp_facebook,ARGUMENTS.timestamp)) > 0) {
			var dateParts = {
				year = reReplace(ARGUMENTS.timestamp, regEx_timestamp_facebook, "\1", "one"),
				month = reReplace(ARGUMENTS.timestamp, regEx_timestamp_facebook, "\2", "one"),
				day = int(reReplace(ARGUMENTS.timestamp, regEx_timestamp_facebook, "\3", "one")),
				hour = int(reReplace(ARGUMENTS.timestamp, regEx_timestamp_facebook, "\4", "one")),
				min = int(reReplace(ARGUMENTS.timestamp, regEx_timestamp_facebook, "\5", "one")),
				sec = int(reReplace(ARGUMENTS.timestamp, regEx_timestamp_facebook, "\6", "one"))
			};
		} else {
			throw("unrecognized timestamp");
		}

		var localTimeOffset = -4;

		try {
			var cf_dateTime = createDateTime(dateParts.year, dateParts.month, dateParts.day, dateParts.hour, dateParts.min, dateParts.sec);
			cf_dateTime = DateAdd("h",localTimeOffset,cf_dateTime);
		} catch( any e) {
			var cf_dateTime = createDateTime(dateParts.year, dateParts.month, dateParts.day, (dateParts.hour-1), dateParts.min, dateParts.sec);
			cf_dateTime = DateAdd("h",localTimeOffset,(cf_dateTime+1));
		}
		return cf_dateTime;
	}
}
