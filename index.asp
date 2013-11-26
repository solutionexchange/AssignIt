<!DOCTYPE html>
<html lang="en">
<head>
	<meta http-equiv="expires" content="-1" />
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<meta name="copyright" content="2013, Web Site Management" />
	<meta http-equiv="X-UA-Compatible" content="IE=edge" >
	<title>Assign It</title>
	<link rel="stylesheet" href="css/bootstrap.min.css" />
	<style type="text/css">
		body
		{
			padding: 10px;
		}
		textarea, input
		{
			width: 95%;
			height: 150px;
		}
	</style>
	<script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
	<script type="text/javascript" src="js/bootstrap.min.js"></script>
	<script type="text/javascript" src="rqlconnector/Rqlconnector.js"></script>
	<script type="text/javascript">
		var _PageGuid = '<%= session("pageguid") %>';
		var ProjectGuid = '<%= session("projectguid") %>';
		var CurrentUserGuid = '<%= session("userguid") %>';
		var LoginGuid = '<%= session("loginguid") %>';
		var SessionKey = '<%= session("sessionkey") %>';
		var RqlConnectorObj = new RqlConnector(LoginGuid, SessionKey);
	
		$(document).ready(function() {
			InitPageGuid();
			
			LoadSimplePageInfo(_PageGuid);
			UsersInProject(ProjectGuid, CurrentUserGuid);
			GetUserEmail(CurrentUserGuid);
			
			$('#assign').click(function(){
				var SelectedUser = $('#new-page-owner option:selected').val();
				AssignPageToUser(_PageGuid, SelectedUser);
			});
			
			$('#sendemail').click(function(){
				var FromEmail = $('#from-email').val();
								
				var ToEmail = $('#to-email option:selected').attr('email');
				
				if(ToEmail == '')
				{
					alert('Selected user do not have email in user profile');
					return;
				}
				
				var SubjectEmail = htmlEncode($('#subject-email').val());
				
				var TextEmail = htmlEncode($('#text-email').text());
								
				SendPlainEmail(FromEmail, ToEmail, SubjectEmail, TextEmail)
			});

		});
		
		function InitPageGuid()
		{
			var objClipBoard = window.opener.document;
			var SmartEditURL;
			if($(objClipBoard).find('iframe[name=Preview]').length > 0)
			{
				SmartEditURL = $(objClipBoard).find('iframe[name=Preview]').contents().get(0).location;
			}
			
			var EditPageGuid = GetUrlVars(SmartEditURL)['EditPageGUID'];
			var ParamPageGuid = GetUrlVars()['pageguid'];
			
			if(EditPageGuid != null)
			{
				_PageGuid = EditPageGuid;
			}
			else if (ParamPageGuid != null)
			{
				_PageGuid = ParamPageGuid;
			}
			
			$('.help-inline').hide();
		}
		
		function FindPage()
		{
			$('.help-inline').hide();
			$('#pageguid-pageid-dialog .control-group').removeClass('error');
			
			var FindPageGuid = $.trim($('#page-guid').val());
			var FindPageId = $.trim($('#page-id').val());
			
			if(FindPageGuid != '')
			{
				ValidatePageGuid(FindPageGuid);
			}else{
				ValidatePageId(FindPageId);
			}
		}
		
		function ValidatePageGuid(PageGuid)
		{
			var FindPageGuid = $.trim($('#page-guid').val());
			var strRQLXML = '<PAGE action="load" guid="' + FindPageGuid + '"/>';
			
			RqlConnectorObj.SendRql(strRQLXML, false, function(data){
				var PageId = $(data).find('PAGE').attr('id');
				
				if(PageId != null)
				{
					_PageGuid = $(data).find('PAGE').attr('guid');
					Refresh(_PageGuid);
				}else{
					// invalid Page Guid
					$('#page-PageGuid').parents('.control-group').addClass('error');
					$('#page-PageGuid').siblings('.help-inline').show();
				}
			});
		}
		
		function ValidatePageId(PageId)
		{
			var strRQLXML = '<PAGE action="xsearch" pagesize="1" maxhits="1" ><SEARCHITEMS><SEARCHITEM key="pageid" value="' + PageId +'" operator="eq" displayvalue=""></SEARCHITEM></SEARCHITEMS></PAGE>';
			
			RqlConnectorObj.SendRql(strRQLXML, false, function(data){
				var PageId = $(data).find('PAGE').attr('id');
				
				if(PageId != null)
				{
					_PageGuid = $(data).find('PAGE').attr('guid');
					Refresh(_PageGuid);
				}else{
					// invalid Page Id
					$('#page-id').parents('.control-group').addClass('error');
					$('#page-id').siblings('.help-inline').show();
				}
			});
		}
		
		function GetUrlVars(SourceUrl)
		{
			if(SourceUrl == undefined)
			{
				SourceUrl = window.location.href;
			}
			SourceUrl = new String(SourceUrl);
			var vars = [], hash;
			var hashes = SourceUrl.slice(SourceUrl.indexOf('?') + 1).split('&');
			for(var i = 0; i < hashes.length; i++)
			{
				hash = hashes[i].split('=');
				vars.push(hash[0]);
				vars[hash[0]] = hash[1];
			}
	
			return vars;
		}
		
		function htmlEncode(value){
			return $('<div/>').text(value).html();
		}

		
		function LoadSimplePageInfo(PageGuid)
		{
			var strRQLXML = '<PAGE action="load" guid="' + PageGuid + '"/>';
			RqlConnectorObj.SendRql(strRQLXML, false, function(data){
				// current owner
				$('#page-owner').val($(data).find('PAGE').attr('changeusername'));
				
				// populate basic page information in email field
				$('#subject-email').val('Page Assigned: ' + $(data).find('PAGE').attr('headline') + ' (Page Id:' + $(data).find('PAGE').attr('id') + ')');
			});
		}
		
		function UsersInProject(ProjectGuid, CurrentUserGuid)
		{
			var strRQLXML = '<ADMINISTRATION><USERS action="search" pagesize="-1" maxhits="-1" orderby=""><SEARCHITEMS><SEARCHITEM key="projectguid" value="' + ProjectGuid + '" operator="like" /></SEARCHITEMS></USERS></ADMINISTRATION>';
			RqlConnectorObj.SendRql(strRQLXML, false, function(data){
				var User;
				$(data).find('USER').each(function(){
					var User = '<option value="' + $(this).attr('guid') + '" email="' + $(this).attr('email') + '">' + $(this).attr('name') + '</option>';
					$('#new-page-owner').append(User);
					
					$('#to-email').append(User);
				});
				
				$('#new-page-owner option[value=' + CurrentUserGuid + ']').attr('selected', 'selected');
			});
		}
		
		function AssignPageToUser(PageGuid, UserGuid)
		{
			$('#processing').modal('show');
			
			var strRQLXML = '<PAGE guid="' + PageGuid + '"><CHANGE><USER action="save" guid="' + UserGuid + '"/></CHANGE></PAGE>';
			RqlConnectorObj.SendRql(strRQLXML, false, function(data){
				// assigned
				var AssignedUserName = $('#new-page-owner option[value=' + UserGuid + ']').text();
				$('#page-owner').val(AssignedUserName);
				
				$('#processing').modal('hide');
			});
		}
		
		function GetUserEmail(UserGuid)
		{
			var strRQLXML = '<ADMINISTRATION><USER action="load" guid="' + UserGuid + '"/></ADMINISTRATION>';
			RqlConnectorObj.SendRql(strRQLXML, false, function(data){
				var UserEmail = $(data).find('USER').attr('email');
				
				if(UserEmail != '')
				{
					$('#from-email').val(UserEmail);
				}
			});

		}
		
		function SendPlainEmail(FromEmail, ToEmail, SubjectEmail, TextEmail)
		{
			$('#processing').modal('show');
			
			var strRQLXML = '<ADMINISTRATION action="sendmail" to="' + ToEmail + '" subject="' + SubjectEmail + '" message="' + TextEmail + '" from="' + FromEmail + '" plaintext="1" />';
			RqlConnectorObj.SendRql(strRQLXML, false, function(data){
				// sent
				$('#processing').modal('hide');
			});
		}
		
		function Refresh(PageGuid)
		{
			window.location.href = window.location.href.split("?")[0] + '?pageguid=' + PageGuid;
			location.reload(); 
		}
	</script>
</head>
<body>
	<div id="processing" class="modal hide fade" data-backdrop="static" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<div class="modal-header">
			<h3>Processing</h3>
		</div>
		<div class="modal-body">
			<p>Please wait...</p>
		</div>
	</div>
	<div id="pageguid-pageid-dialog" class="modal hide fade" data-backdrop="static" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<div class="modal-header">
			<h3>Find Page</h3>
		</div>
		<div class="modal-body">
			<div class="form-horizontal">
				<div class="control-group">
					<label class="control-label" for="page-guid">Page guid</label>
					<div class="controls">
						<input type="text" id="page-guid" maxlength="32" />
						<span class="help-inline">page guid not found</span>
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
						<span class="help-inline">page id not found</span>
					</div>
				</div>
			</div>
		</div>
		<div class="modal-footer">
			<a href="#" class="btn" onclick="$('#pageguid-pageid-dialog').modal('hide')">Close</a>
			<a href="#" class="btn btn-success" onclick="FindPage()">Find</a>
		</div>
	</div>
	<div class="form-horizontal">
		<div class="navbar navbar-inverse">
			<div class="navbar-inner">
				<span class="brand">Current Page Status</span>
				<button class="btn btn-info pull-right" onclick="$('#pageguid-pageid-dialog').modal('show');">Find Page</button>
			</div>
		</div>
		<div class="control-group">
			<label class="control-label" for="page-owner">Current Page Owner:</label>
			<div class="controls">
				<input id="page-owner" readonly="readonly" type="text"/>
			</div>
		</div>
		<div class="control-group">
			<label class="control-label" for="new-page-owner">Assign Page To:</label>
			<div class="controls">
				<select id="new-page-owner"></select>
			</div>
		</div>
		<div class="form-actions">
			<button class="btn btn-success pull-right" id="assign">Assign</button>
		</div>
	</div>
	<div class="form-horizontal">
		<div class="navbar navbar-inverse">
			<div class="navbar-inner">
				<span class="brand">Email User</span>
			</div>
		</div>
		<div class="control-group">
			<label class="control-label" for="from-email">From:</label>
			<div class="controls">
				<input type="text" id="from-email" value="assignit@noreply.com" readonly="readonly"/>
			</div>
		</div>
		<div class="control-group">
			<label class="control-label" for="to-email">To:</label>
			<div class="controls">
				<select id="to-email"></select>
			</div>
		</div>
		<div class="control-group">
			<label class="control-label" for="subject-email">Subject:</label>
			<div class="controls">
				<input type="text" id="subject-email" />
			</div>
		</div>
		<div class="control-group">
			<label class="control-label" for="text-email">Email body:</label>
			<div class="controls">
				<textarea id="text-email"></textarea>
			</div>
		</div>
		<div class="form-actions">
			<button class="btn btn-success pull-right" id="sendemail">Send</button>
		</div>
	</div>
</body>
</html>