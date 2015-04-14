function AssignIt(RqlConnectorObj, PageGuid, ProjectGuid, CurrentUserGuid) {
	this.RqlConnectorObj = RqlConnectorObj;
	
	this.TemplatePageStatus = '#template-page-status';
	this.TemplatePageStatusPageGuidLoading = '#template-page-status-page-guid-loading';
	this.TemplatePageStatusPageGuidNotFound = '#template-page-status-page-guid-not-found';
	this.TemplatePageStatusPageOwnerLoading = '#template-page-status-page-owner-loading';
	this.TemplatePageStatusPageOwnerNotFound = '#template-page-status-page-owner-not-found';
	this.TemplatePageStatusNewPageOwnerLoading = '#template-page-status-new-page-owner-loading';
	this.TemplatePageStatusPageGuid = '#template-page-status-page-guid';
	this.TemplatePageStatusPageOwner = '#template-page-status-page-owner';
	this.TemplatePageStatusNewPageOwner = '#template-page-status-new-page-owner';
	this.TemplatePageStatusActions = '#template-page-status-actions';
	this.TemplatePageStatusActionsLoading = '#template-page-status-actions-loading';
	this.TemplateEmail = '#template-email';
	this.TemplateEmailToLoading = '#template-email-to-loading';
	this.TemplateEmailSubjectLoading = '#template-email-subject-loading';
	this.TemplateEmailToNotFound = '#template-email-to-not-found';
	this.TemplateEmailSubjectNotFound = '#template-email-subject-not-found';
	this.TemplateEmailTo = '#template-email-to';
	this.TemplateEmailSubject = '#template-email-subject';
	this.TemplateEmailActions = '#template-email-actions';
	this.TemplateEmailActionsLoading = '#template-email-actions-loading';
	this.TemplateFindPageDialog = '#template-find-page-dialog';
	
	this.Init(PageGuid, ProjectGuid, CurrentUserGuid);
}

AssignIt.prototype.Init = function(PageGuid, ProjectGuid, CurrentUserGuid) {
	var ThisClass = this;

	var PageStatusNewPageOwnerContainer = $(this.TemplatePageStatusNewPageOwner).attr('data-container');
	$('body').on('change', PageStatusNewPageOwnerContainer, function(){
		var UserGuid = $(this).find('option:selected').attr('data-user-guid');

		ThisClass.GetUserEmail(UserGuid);
	});
	
	var PageStatusContainer = $(this.TemplatePageStatus).attr('data-container');
	$(PageStatusContainer).on('click', '.find-page', function(){
		ThisClass.UpdateArea(ThisClass.TemplateFindPageDialog, undefined);
		var FindPageDialogContainer = $(ThisClass.TemplateFindPageDialog).attr('data-container');
		$(FindPageDialogContainer).find('.modal').modal('show');
	});
	
	$(PageStatusContainer).on('click', '.assign', function(){
		var PageGuid = $(PageStatusContainer).find('.page-guid input').val();
		var UserGuid = $(PageStatusContainer).find('.new-page-owner option:selected').attr('data-user-guid');
		
		ThisClass.AssignPageToUser(PageGuid, UserGuid);
	});
	
	var FindPageDialogContainer = $(this.TemplateFindPageDialog).attr('data-container');
	$(FindPageDialogContainer).on('click', '.find', function(){
		ThisClass.FindPage();
	});
	
	var EmailContainer = $(this.TemplateEmail).attr('data-container');
	$(EmailContainer).on('click', '.email-send', function(){
		$(EmailContainer).find('.error').removeClass('error');
	
		var EmailFrom = $(EmailContainer).find('.email-from input').val();
						
		var EmailTo = $(EmailContainer).find('.email-to input').val();
		
		if(!EmailTo)
		{
			$(EmailContainer).find('.email-to').parent().addClass('error');
			return;
		}
		
		var EmailSubject = ThisClass.HtmlEncode($(EmailContainer).find('.email-subject input').val());
		
		var EmailText = ThisClass.HtmlEncode($(EmailContainer).find('.email-text textarea').text());

		ThisClass.SendPlainEmail(EmailFrom, EmailTo, EmailSubject, EmailText);
	});

	this.UpdateArea(this.TemplatePageStatus, undefined);
	this.UpdateArea(this.TemplatePageStatusActions, undefined);
	this.UpdateArea(this.TemplateEmail, undefined);
	this.UpdateArea(this.TemplateEmailActions, undefined);
	this.UpdateArea(this.TemplatePageStatusNewPageOwnerLoading, undefined);
	this.UpdateArea(this.TemplateEmailToLoading, undefined);

	this.UsersInProject(ProjectGuid, CurrentUserGuid);
	this.FindPage(PageGuid);
}

AssignIt.prototype.HtmlEncode = function(Html) {
	return $('<div/>').text(Html).html();
}

AssignIt.prototype.UsersInProject = function(ProjectGuid, CurrentUserGuid) {
	var ThisClass = this;
	var RqlXml = '<ADMINISTRATION><USERS action="search" pagesize="-1" maxhits="-1" orderby=""><SEARCHITEMS><SEARCHITEM key="projectguid" value="' + ProjectGuid + '" operator="like" /></SEARCHITEMS></USERS></ADMINISTRATION>';
	
	RqlConnectorObj.SendRql(RqlXml, false, function(data){
		var UsersObject = {
			'users': []
		};
		
		$(data).find('USER').each(function(){
			var User = {
				'userguid': $(this).attr('guid'),
				'username': $(this).attr('name'),
				'useremail': $(this).attr('email'),
				'selected': ''
			};
			
			if(User.guid == CurrentUserGuid){
				User.selected = 'selected';
			}
			
			UsersObject.users.push(User);
		});
		
		ThisClass.UpdateArea(ThisClass.TemplatePageStatusNewPageOwner, UsersObject);
		
		var PageStatusNewPageOwnerContainer = $(ThisClass.TemplatePageStatusNewPageOwner).attr('data-container');
		$(PageStatusNewPageOwnerContainer).trigger('change');
	});
}

AssignIt.prototype.LoadSimplePageInfo = function(PageGuid, CallbackFunc) {
	var ThisClass = this;
	var RqlXml = '<PAGE action="load" guid="' + PageGuid + '"/>';
	
	RqlConnectorObj.SendRql(RqlXml, false, function(data){
		var PageObj = {
			'username': $(data).find('PAGE').attr('changeusername'),
			'headline': $(data).find('PAGE').attr('headline'),
			'pageid': $(data).find('PAGE').attr('id'),
			'pageguid': PageGuid
		};
		
		CallbackFunc(PageObj);
	});
}

AssignIt.prototype.GetUserEmail = function(UserGuid) {
	var ThisClass = this;
	var RqlXml = '<ADMINISTRATION><USER action="load" guid="' + UserGuid + '"/></ADMINISTRATION>';
	
	RqlConnectorObj.SendRql(RqlXml, false, function(data){
		var UserObj = {
			useremail: $(data).find('USER').attr('email')
		};

		ThisClass.UpdateArea(ThisClass.TemplateEmailTo, UserObj);
	});
}

AssignIt.prototype.FindPage = function(CurrentPageGuid) {
	var FindPageDialogContainer = $(this.TemplateFindPageDialog).attr('data-container');
	var PageGuid = $(FindPageDialogContainer).find('#page-guid').val();
	var PageId = $(FindPageDialogContainer).find('#page-id').val();
	var ThisClass = this;
	
	if(CurrentPageGuid || PageGuid || PageId){
		this.UpdateArea(this.TemplatePageStatusPageGuidLoading, undefined);
		this.UpdateArea(this.TemplatePageStatusPageOwnerLoading, undefined);
		this.UpdateArea(this.TemplateEmailSubjectLoading, undefined);
		
		var FoundPage = function(PageObj){
			if(PageObj.headline){
				ThisClass.UpdateArea(ThisClass.TemplatePageStatusPageGuid, PageObj);
				ThisClass.UpdateArea(ThisClass.TemplatePageStatusPageOwner, PageObj);
				ThisClass.UpdateArea(ThisClass.TemplateEmailSubject, PageObj);
			} else {
				ThisClass.UpdateArea(ThisClass.TemplatePageStatusPageGuidNotFound, PageObj);
				ThisClass.UpdateArea(ThisClass.TemplatePageStatusPageOwnerNotFound, PageObj);
				ThisClass.UpdateArea(ThisClass.TemplateEmailSubjectNotFound, PageObj);
			}
		}
	
		if(CurrentPageGuid){
			this.FindPageByGuid(CurrentPageGuid, FoundPage);
		} else if(PageGuid){
			this.FindPageByGuid(PageGuid, FoundPage);
		} else if(PageId){
			this.FindPageById(PageId, FoundPage);
		}
	}
}

AssignIt.prototype.FindPageByGuid = function(PageGuid, CallbackFunc) {
	var ThisClass = this;
	
	this.LoadSimplePageInfo(PageGuid, function(data){
		var PageObj = data;
		
		CallbackFunc(PageObj);
	});
}

AssignIt.prototype.FindPageById = function(PageId, CallbackFunc) {
	var ThisClass = this;

	var RqlXml = '<PAGE action="xsearch" pagesize="1" maxhits="1" ><SEARCHITEMS><SEARCHITEM key="pageid" value="' + PageId +'" operator="eq" displayvalue=""></SEARCHITEM></SEARCHITEMS></PAGE>';
	
	RqlConnectorObj.SendRql(RqlXml, false, function(data){
		var PageObj = {
			'username': $(data).find('PAGE CHANGE USER').attr('name'),
			'headline': $(data).find('PAGE').attr('headline'),
			'pageid': PageId,
			'pageguid': $(data).find('PAGE').attr('guid')
		};
		
		CallbackFunc(PageObj);
	});
}

AssignIt.prototype.AssignPageToUser = function(PageGuid, UserGuid) {
	this.UpdateArea(this.TemplatePageStatusActionsLoading, undefined);
	
	var ThisClass = this;
	var RqlXml = '<PAGE guid="' + PageGuid + '"><CHANGE><USER action="save" guid="' + UserGuid + '"/></CHANGE></PAGE>';
	
	RqlConnectorObj.SendRql(RqlXml, false, function(data){
		ThisClass.FindPage(PageGuid);
		
		ThisClass.UpdateArea(ThisClass.TemplatePageStatusActions, undefined);
	});
}
		
AssignIt.prototype.SendPlainEmail = function(FromEmail, ToEmail, SubjectEmail, TextEmail) {
	this.UpdateArea(this.TemplateEmailActionsLoading, undefined);
	
	var ThisClass = this;
	var RqlXml = '<ADMINISTRATION action="sendmail" to="' + ToEmail + '" subject="' + SubjectEmail + '" message="' + TextEmail + '" from="' + FromEmail + '" plaintext="1" />';
	
	RqlConnectorObj.SendRql(RqlXml, false, function(data){
		// sent
		ThisClass.UpdateArea(ThisClass.TemplateEmailActions, undefined);
	});
}

AssignIt.prototype.UpdateArea = function(TemplateId, Data){
	var ContainerId = $(TemplateId).attr('data-container');
	var TemplateAction = $(TemplateId).attr('data-action');
	var Template = Handlebars.compile($(TemplateId).html());
	var TemplateData = Template(Data);

	if((TemplateAction == 'append') || (TemplateAction == 'replace'))
	{
		if (TemplateAction == 'replace') {
			$(ContainerId).empty();
		}

		$(ContainerId).append(TemplateData);
	}

	if(TemplateAction == 'prepend')
	{
		$(ContainerId).prepend(TemplateData);
	}

	if(TemplateAction == 'after')
	{
		$(ContainerId).after(TemplateData);
	}
}