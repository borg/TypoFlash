<?php
/*
 * Created on 23. Feb 06
 *
 * To change the template for this generated file go to
 * Window - Preferences - PHPeclipse - PHP - Code Templates
 */

class ux_SC_index extends SC_index {
	
	/**
	 * Main function - creating the login/logout form
	 *
	 * @return	void
	 */
	function main()	{
		global $TBE_TEMPLATE, $TYPO3_CONF_VARS, $BE_USER, $LANG;

			// Initialize template object:
		$TBE_TEMPLATE->docType='xhtml_trans';

			// Set JavaScript for creating a MD5 hash of the password:
		$TBE_TEMPLATE->JScode.='
			<script type="text/javascript" src="md5.js"></script>
			'.$TBE_TEMPLATE->wrapScriptTags('
				function doChallengeResponse(superchallenged) {	//
					password = document.loginform.p_field.value;
					if (password)	{
						if (superchallenged)	{
							password = MD5(password);	// this makes it superchallenged!!
						}
						str = document.loginform.username.value+":"+password+":"+document.loginform.challenge.value;
						document.loginform.userident.value = MD5(str);
						if (!document.loginform.p_save.checked) document.loginform.p_field.value = "";
						return true;
					}
				}
			');


			// Checking, if we should make a redirect.
			// Might set JavaScript in the header to close window.
		$this->checkRedirect();

			// Initialize interface selectors:
		$this->makeInterfaceSelectorBox();

			// Replace an optional marker in the "Administration Login" label
		$this->L_vars[6] = str_replace("###SITENAME###",$TYPO3_CONF_VARS['SYS']['sitename'],$this->L_vars[6]);

			// Creating form based on whether there is a login or not:
		if (!$BE_USER->user['uid'])	{

			if ($this->loginSecurityLevel == 'challenged') {
				$TBE_TEMPLATE->form = '
					<form action="index.php" method="post" name="loginform" onsubmit="doChallengeResponse(0);">
					';
			} elseif ($this->loginSecurityLevel == 'normal') {
				$TBE_TEMPLATE->form = '
					<form action="index.php" method="post" name="loginform" onsubmit="document.loginform.userident.value=document.loginform.p_field.value;document.loginform.p_field.value=\'\';document.loginform.challenge.value=\'\';return true;">
					';
			} else { // if ($this->loginSecurityLevel == 'superchallenged') {
				$TBE_TEMPLATE->form = '
					<form action="index.php" method="post" name="loginform" onsubmit="doChallengeResponse(1);">
					';
			}

			$TBE_TEMPLATE->form.= '
					<input type="hidden" name="login_status" value="login" />
				';
			$loginForm = $this->makeLoginForm();
		} else {
			$TBE_TEMPLATE->form = '
				<form action="index.php" method="post" name="loginform">
				<input type="hidden" name="login_status" value="logout" />
				';
			$loginForm = $this->makeLogoutForm();
		}


			// Starting page:
		$this->content.=$TBE_TEMPLATE->startPage('TYPO3 Login: '.$TYPO3_CONF_VARS['SYS']['sitename']);

			// Add login form:
		$this->content.=$this->wrapLoginForm($loginForm);

			// Ending form:
		$this->content.= '
			<input type="hidden" name="userident" value="" />
			<input type="hidden" name="challenge" value="'.($challenge = md5(uniqid('').getmypid())).'" />
			<input type="hidden" name="redirect_url" value="'.htmlspecialchars($this->redirectToURL).'" />
			<input type="hidden" name="loginRefresh" value="'.htmlspecialchars($this->loginRefresh).'" />
			'.$this->interfaceSelector_hidden.'
			';

			// Save challenge value in session data (thanks to Bernhard Kraft for providing code):
		session_start();
		$_SESSION['login_challenge'] = $challenge;

			// This moves focus to the right input field:
		$this->content.=$TBE_TEMPLATE->wrapScriptTags('

				// If the login screen is shown in the login_frameset window for re-login, then try to get the username of the current/former login from opening windows main frame:
			if (parent.opener && parent.opener.TS && parent.opener.TS.username && document.loginform && document.loginform.username)	{
				document.loginform.username.value = parent.opener.TS.username;
			}

				// If for some reason there already is a username in the username for field, move focus to the password field:
			if (document.loginform.username && document.loginform.username.value == "") {
				document.loginform.username.focus();
			} else if (document.loginform.p_field && document.loginform.p_field.type!="hidden") {
				document.loginform.p_field.focus();
			}
		');

			// End page:
		$this->content.=$TBE_TEMPLATE->endPage();
	}
	
	
	
	/**
	 * Creates the login form
	 * This is drawn when NO login exists.
	 *
	 * @return	string		HTML output
	 */
	function makeLoginForm()	{

		$content.='

							<!--
								Login form:
							-->
							<table cellspacing="0" cellpadding="0" border="0" id="logintable">
									<tr>
										<td colspan="2"><h2>'.htmlspecialchars($this->L_vars[6]).'</h2></td>
									</tr>'.($this->commandLI ? '
									<tr class="c-wrong">
										<td colspan="2"><p class="c-wrong">'.htmlspecialchars($this->L_vars[9]).'</p></td>
									</tr>' : '').'
									<tr class="c-username">
										<td><p class="c-username">'.htmlspecialchars($this->L_vars[0]).':</p></td>
										<td><input type="text" name="username" value="'.htmlspecialchars($this->u).'" class="c-username" tabIndex="1" /></td>
									</tr>
									<tr class="c-password">
										<td><p class="c-password">'.htmlspecialchars($this->L_vars[1]).':</p></td>
										<td><input type="password" name="p_field" value="'.htmlspecialchars($this->p).'" class="c-password" tabIndex="2" /> <input type="checkbox" name="p_save" value="1" checked="checked" tabIndex="4"" /> <p class="c-info" style="display:inline;">allow saving</p></td>
									</tr>'.($this->interfaceSelector && !$this->loginRefresh ? '
									<tr class="c-interfaceselector">
										<td><p class="c-interfaceselector">'.htmlspecialchars($this->L_vars[2]).':</p></td>
										<td>'.$this->interfaceSelector.'</td>
									</tr>' : '' ).'
									<tr class="c-submit">
										<td></td>
										<td><input type="submit" name="commandLI" value="'.htmlspecialchars($this->L_vars[3]).'" class="c-submit" tabIndex="3" /></td>
									</tr>
									<tr class="c-info">
										<td colspan="2"><p class="c-info">'.htmlspecialchars($this->L_vars[7]).'</p></td>
									</tr>
								</table>';

			// Return content:
		return $content;
	}
}


if (defined('TYPO3_MODE') && $TYPO3_CONF_VARS[TYPO3_MODE]['XCLASS']['ext/eleon_advancedlogin/class.ux_SC_index.php'])	{
	include_once($TYPO3_CONF_VARS[TYPO3_MODE]['XCLASS']['ext/eleon_advancedlogin/class.ux_SC_index.php']);
}
?>
