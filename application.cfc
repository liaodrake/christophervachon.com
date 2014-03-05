/**
*
* @file  /Users/Christopher/Documents/sites/christophervachon.com/application.cfc
* @author  
* @description
*
*/

component extends="frameworks.org.corfield.framework" {

	this.name = 'ChristopherVachonVr0.0.1';
	this.sessionManagement = true;
	this.sessionTimeout = CreateTimespan(0,0,20,0);

	this.datasource = "cmv";
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate = ((this.getEnvironment() == "dev")?"update":"none"),
		eventHandling = true,
		cfclocation = 'models',
		flushatrequestend = false,
		namingstrategy = "smart",
		dialect = "MySQL"
	};

	VARIABLES.framework = {
		generateSES = true,
		SESOmitIndex = true,
		applicationKey = 'fw1',
		reloadApplicationOnEveryRequest = (this.getEnvironment() == "dev"),
		routes = [
			{"/blog/:year/:month/:day/:title"="/blog/view/articleDate/:year-:month-:day/title/:title"},
			{"/blog/:year/:month/:day"="/blog/default/year/:year/month/:month/day/:day"},
			{"/blog/:year/:month"="/blog/default/year/:year/month/:month"},
			{"/blog/:year"="/blog/default/year/:year"}
		]
	};


	public string function getEnvironment() {
		if (reFindNoCase("\.(local)$",CGI.SERVER_NAME) > 0) {
			return "dev";
		} else {
			return "live";
		}
	}


	public void function setupApplication() {}


	public void function setupRequest() {
		if (isFrameworkReloadRequest()) {
			ORMClearSession();
			ORMReload();
		}

		REQUEST.CONTEXT.security = new services.security();
		REQUEST.CONTEXT.validation = new services.validationService();

		REQUEST.CONTEXT.security.cookieSignIn();

		REQUEST.CONTEXT.template = new models.template();
		REQUEST.CONTEXT.template.setSiteName("Christopher Vachon");
		REQUEST.CONTEXT.template.addFile("christophervachon.min.css");
		REQUEST.CONTEXT.template.addFile("/favicon.ico");
		REQUEST.CONTEXT.template.addFile("//code.jquery.com/jquery-1.10.2.min.js");
		REQUEST.CONTEXT.template.addFile("//netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js");
		REQUEST.CONTEXT.template.addFile("//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap-theme.min.css");
	}


	public string function onMissingView( required struct rc ) {
		return view( 'main/404' );
	}


	public void function before( required struct rc) {
		RC.template.addPageCrumb("Home","/");
	}
}