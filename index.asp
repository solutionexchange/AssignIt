<!DOCTYPE html>
<html lang="en">
<head>
	<meta http-equiv="expires" content="-1" />
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<meta name="copyright" content="2015, Web Site Management" />
	<meta http-equiv="X-UA-Compatible" content="IE=edge" >
	<title>Assign It</title>
	<link rel="stylesheet" href="css/bootstrap.min.css" />
	<link rel="stylesheet" href="css/custom.css" />
	<script type="text/javascript" src="js/jquery-1.10.2.min.js"></script>
	<script type="text/javascript" src="js/bootstrap.min.js"></script>
	<script type="text/javascript" src="js/handlebars-v2.0.0.js"></script>
	<script type="text/javascript" src="rqlconnector/Rqlconnector.js"></script>
	<script type="text/javascript" src="js/assign-it.js"></script>
	<script id="template-page-status" type="text/x-handlebars-template" data-container="#page-status" data-action="replace">
		<div class="form-horizontal">
			<div class="navbar navbar-inverse">
				<div class="navbar-inner">
					<span class="brand">Current Page Status</span>
					<button class="btn btn-info pull-right find-page">Find Page</button>
				</div>
			</div>
			<div class="control-group">
				<label class="control-label">Current Page Guid:</label>
				<div class="controls page-guid">
				</div>
			</div>
			<div class="control-group">
				<label class="control-label">Current Page Owner:</label>
				<div class="controls page-owner">
				</div>
			</div>
			<div class="control-group">
				<label class="control-label">Assign Page To:</label>
				<div class="controls new-page-owner">
				</div>
			</div>
			<div class="form-actions">
				
			</div>
		</div>
	</script>
	
	<script id="template-page-status-page-guid-loading" type="text/x-handlebars-template" data-container="#page-status .page-guid" data-action="replace">
		<span class="alert alert-warning">Loading...</span>
	</script>
	
	<script id="template-page-status-page-guid-not-found" type="text/x-handlebars-template" data-container="#page-status .page-guid" data-action="replace">
		<span class="alert alert-error">Not found</span>
	</script>
	
	<script id="template-page-status-page-owner-loading" type="text/x-handlebars-template" data-container="#page-status .page-owner" data-action="replace">
		<span class="alert alert-warning">Loading...</span>
	</script>
	
	<script id="template-page-status-page-owner-not-found" type="text/x-handlebars-template" data-container="#page-status .page-owner" data-action="replace">
		<span class="alert alert-error">Owner for {{#if pageid}}page id {{pageid}}{{/if}}{{#if pageguid}}page guid {{pageguid}}{{/if}} not found</span>
	</script>
	
	<script id="template-page-status-new-page-owner-loading" type="text/x-handlebars-template" data-container="#page-status .new-page-owner" data-action="replace">
		<span class="alert alert-warning">Loading...</span>
	</script>
	
	<script id="template-page-status-page-guid" type="text/x-handlebars-template" data-container="#page-status .page-guid" data-action="replace">
		<input readonly="readonly" type="text" value="{{pageguid}}"/>
	</script>
	
	<script id="template-page-status-page-owner" type="text/x-handlebars-template" data-container="#page-status .page-owner" data-action="replace">
		<input readonly="readonly" type="text" value="{{username}}"/>
	</script>
	
	<script id="template-page-status-new-page-owner" type="text/x-handlebars-template" data-container="#page-status .new-page-owner" data-action="replace">
		<select>
			{{#each users}}
			<option data-user-guid="{{userguid}}" {{selected}}>{{username}}</option>
			{{/each}}
		</select>
	</script>
	
	<script id="template-page-status-actions" type="text/x-handlebars-template" data-container="#page-status .form-actions" data-action="replace">
		<div class="btn btn-success pull-right assign">Assign</div>
	</script>
	
	<script id="template-page-status-actions-loading" type="text/x-handlebars-template" data-container="#page-status .form-actions" data-action="replace">
		<div class="btn pull-right"><i class="icon-cog"></i> Assigning</div>
	</script>
	
	<script id="template-email" type="text/x-handlebars-template" data-container="#email" data-action="replace">
		<div class="form-horizontal">
			<div class="navbar navbar-inverse">
				<div class="navbar-inner">
					<span class="brand">Email User</span>
				</div>
			</div>
			<div class="control-group">
				<label class="control-label">From:</label>
				<div class="controls email-from">
					<input type="text" value="assignit@noreply.com" readonly="readonly"/>
				</div>
			</div>
			<div class="control-group">
				<label class="control-label">To:</label>
				<div class="controls email-to">
				</div>
			</div>
			<div class="control-group">
				<label class="control-label">Subject:</label>
				<div class="controls email-subject">
				</div>
			</div>
			<div class="control-group">
				<label class="control-label" for="text-email">Email body:</label>
				<div class="controls email-text">
					<textarea></textarea>
				</div>
			</div>
			<div class="form-actions">
				
			</div>
		</div>
	</script>
	
	<script id="template-email-to-loading" type="text/x-handlebars-template" data-container="#email .email-to" data-action="replace">
		<span class="alert alert-warning">Loading...</span>
	</script>
	
	<script id="template-email-subject-loading" type="text/x-handlebars-template" data-container="#email .email-subject" data-action="replace">
		<span class="alert alert-warning">Loading...</span>
	</script>
	
	<script id="template-email-to-not-found" type="text/x-handlebars-template" data-container="#email .email-to" data-action="replace">
		<span class="alert alert-error">Email for {{#if pageid}}page id {{pageid}}{{/if}}{{#if pageguid}}page guid {{pageguid}}{{/if}} not found</span>
	</script>
	
	<script id="template-email-subject-not-found" type="text/x-handlebars-template" data-container="#email .email-subject" data-action="replace">
		<span class="alert alert-error">Email subject for {{#if pageid}}page id {{pageid}}{{/if}}{{#if pageguid}}page guid {{pageguid}}{{/if}} can not be generated</span>
	</script>
	
	<script id="template-email-to" type="text/x-handlebars-template" data-container="#email .email-to" data-action="replace">
		<input type="text" value="{{useremail}}" />
	</script>
	
	<script id="template-email-subject" type="text/x-handlebars-template" data-container="#email .email-subject" data-action="replace">
		<input type="text" value="Page Assigned: {{headline}} (Page Id: {{pageid}})" />
	</script>
	
	<script id="template-email-actions" type="text/x-handlebars-template" data-container="#email .form-actions" data-action="replace">
		<div class="btn btn-success pull-right email-send">Send</div>
	</script>
	
	<script id="template-email-actions-loading" type="text/x-handlebars-template" data-container="#email .form-actions" data-action="replace">
		<div class="btn pull-right"><i class="icon-cog"></i> Sending</div>
	</script>
	
	<script id="template-find-page-dialog" type="text/x-handlebars-template" data-container="#find-page-dialog" data-action="replace">
		<div class="modal fade" tabindex="-1" role="dialog">
			<div class="modal-header">
				<h3>Find Page</h3>
			</div>
			<div class="modal-body">
				<div class="form-horizontal">
					<div class="control-group">
						<label class="control-label" for="page-guid">Page guid</label>
						<div class="controls">
							<input type="text" id="page-guid" maxlength="32" />
						</div>
					</div>
					<div class="control-group">
						<div class="controls">
							or
						</div>
					</div>
					<div class="control-group">
						<label class="control-label" for="page-guid">Page id</label>
						<div class="controls">
							<input type="text" id="page-id" />
						</div>
					</div>
				</div>
			</div>
			<div class="modal-footer">
				<div class="btn" data-dismiss="modal">Close</div>
				<div class="btn btn-success find" data-dismiss="modal">Find</div>
			</div>
		</div>
	</script>
	
	<script type="text/javascript">
		var PageGuid = '<%= session("pageguid") %>';
		var ProjectGuid = '<%= session("projectguid") %>';
		var CurrentUserGuid = '<%= session("userguid") %>';
		var LoginGuid = '<%= session("loginguid") %>';
		var SessionKey = '<%= session("sessionkey") %>';
		var RqlConnectorObj = new RqlConnector(LoginGuid, SessionKey);
		
		$(document).ready(function() {
			var AssignItObj = new AssignIt(RqlConnectorObj, PageGuid, ProjectGuid, CurrentUserGuid);
		});
	</script>
</head>
<body>
	<div id="find-page-dialog">
	
	</div>
	<div class="container">
		<div id="page-status">
	
		</div>
		<div id="email">
		
		</div>
	</div>
</body>
</html>