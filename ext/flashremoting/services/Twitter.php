<?php
	/**
	 * 
	 * SWX Twitter API by Aral Balkan.
	 * 
	 * You can call this API using SWX, Amfphp, JSON and XML-RPC.
	 * 
	 * @author	Aral Balkan
	 * @copyright	2007 Aral Balkan. All Rights Reserved. 
	 * @link 	http://aralbalkan.com
	 * @link 	http://swxformat.org
	 * @link    mailto://aral@aralbalkan.com
	 * 
	**/
	
	// Require base service class
	require_once("../BaseService.php");

	/**
	 * SWX Twitter API by Aral Balkan. You can call this API using SWX, Amfphp, JSON and XML-RPC.
	**/
	class Twitter extends BaseService
	{
		//////////////////////////////////////////////////////////////////////////////////////////
		//
		// Official Twitter API methods: These implement the official twitter API.
		// See http://groups.google.com/group/twitter-development-talk/web/api-documentation
		// for the full official documentation.
		//
		//////////////////////////////////////////////////////////////////////////////////////////
		
		//
		// Status methods.
		//
		
		/**
		 * Returns the 20 most recent statuses from non-protected users who have set a custom user icon.  Does not require authentication.
		 *
		 * @param	(optional)	Returns only public statuses with an ID greater than (that is, more recent than) the specified.
		 * @param	(optional)	Narrows the returned results to just those statuses created after the specified HTTP-formatted date.
		 * 
		 * @return Array of statuses.
		 * @author Aral Balkan
		 **/
		function publicTimeline($sinceId = NULL)
		{
			$url = 'twitter.com/statuses/public_timeline.json';

			$vars = array('since_id' => $sinceId);

			$response = $this->_jsonCall($url, $vars, 'GET');
			
			return $response;
		}
		
		/**
		 * Returns the 20 most recent statuses posted in the last 24 hours from the authenticating user and that user's friends.  It's also possible to request another user's friends_timeline via the id parameter.
		 * 
		 * @param	Your username.
		 * @param	Your password.
		 * @param	(optional)	ID or screen name of the user for whom to return the friends_timeline.
		 * @param	(optional)	Narrows the returned results to just those statuses created after the specified HTTP-formatted date.
		 * 
		 * @return Array of statuses.
		 * @author Aral Balkan
		 **/
		function friendsTimeline($user, $pass, $id = NULL, $since = NULL)
		{
			$url = 'twitter.com/statuses/friends_timeline.json';
			
			$vars = array('id' => $id, 'since' => $since);
			
			$response = $this->_jsonCall($url, $vars, 'GET', $user, $pass);
			
			return $response;
		}
		
		/**
		 * Returns the 20 most recent statuses posted in the last 24 hours from the authenticating user.  It's also possible to request another user's timeline via the id parameter below.
		 * 
		 *
		 * @return 20 most recent statuses.
		 * @author Aral Balkan
		 **/
		function userTimeline($user, $pass, $id = NULL, $count = NULL, $since = NULL)
		{
			$url = 'twitter.com/statuses/user_timeline.json';
			
			$vars = array('id' => $id, 'count' => $count, 'since' => $since);
			
			$response = $this->_jsonCall($url, $vars, 'GET', $user, $pass);
			
			return $response;
		}
		
		/**
		 * Returns a single status, specified by the id parameter below.  The status's author will be returned inline.
		 * 
		 * @param The numerical ID of the status you're trying to retrieve. 
		 *
		 * @return A single status.
		 * @author Aral Balkan
		 **/
		function showStatus($id)
		{
			$url = "twitter.com/statuses/show/$id.json";
			
			$response = $this->_jsonCall($url, NULL, 'GET');
			
			return $response;
		}

		/**
		 * Posts a twitter update.
		 *
		 * @param (str) Twitter update message
		 * @param (str) Your user name
		 * @param (str) Your password
		 * @param (optional, str) Source string. If enabled by Twitter, this will appear in the "from" section of the update.  
		 * 
		 * @return 	(array)	Success/failure message.
		 * 
		 * @author 	Aral Balkan
		 **/
		function update($update, $user, $pass, $source = NULL)
		{
			$url = 'twitter.com/statuses/update.json';
			$args = array('status' => $update);
			
			if ($source != NULL) 
			{
				error_log("source = ".$source);
				$args['source'] = $source;	
				
				error_log($args['status']);
				error_log($args['source']);
			}
			
			$response = $this->_jsonCall($url, $args, 'POST', $user, $pass);
			
			return $response;
		}
		
		/**
		 * Returns the 20 most recent replies (status updates prefixed with @username posted by users who are friends with the user being replied to) to the authenticating user.  Replies are only available to the authenticating user; you can not request a list of replies to another user whether public or protected.
		 * 
		 * @param (str) Your user name
		 * @param (str) Your password
		 * @param (optional, int) Page number
		 *
		 * @return 20 most recent replies
		 * @author Aral Balkan
		 **/
		function replies($user, $pass, $page = NULL)
		{
			$url = 'http://twitter.com/statuses/replies.json';
			$args = array('page' => $page);
			
			$response = $this->_jsonCall($url, $args, 'POST', $user, $pass);
			
			return $response;			
		}
		
		
		/**
		 * Destroys the status specified by the required ID parameter.  The authenticating user must be the author of the specified status.
		 *
		 * @return void
		 * @author Aral Balkan
		 **/
		function destroy($id, $user, $pass)
		{
			$url = "http://twitter.com/statuses/destroy/$id.json";

			$response = $this->_jsonCall($url, NULL, 'POST', $user, $pass);
			
			return $response;						
		}		
		
		//
		// User methods.
		//

		/**
		 * Gets friends for the passed user.
		 *
		 * @param	(str) Username.
		 * @param	(str) Password.
		 * 
		 * @return 	(array)	List of friends.
		 * @author Aral Balkan
		 **/
		function friends($user, $pass)
		{
			$url = "twitter.com/statuses/friends/$user.json";
			$response = $this->_jsonCall($url,  NULL, 'GET', $user, $pass);
			return $response;
		}
		
		/**
		 * Gets followers for authenticated user.
		 * 
		 * @param	(str) Your username.
		 * @param	(str) Your password.
		 * 
		 * @return (array) List of followers.
		 * @author Aral Balkan
		 **/
		function followers($user, $pass)
		{
			$url = 'twitter.com/statuses/followers.json';
			
			$response = $this->_jsonCall($url, NULL, 'GET', $user, $pass);
			
			return $response;	
		}
		
		/**
		 * Returns currently featured users on the site and their latest update.
		 * 
		 * @return 	(array) List of featured users and their current update.
		 * @author Aral Balkan
		 **/
		function featured()
		{
			$url = 'twitter.com/statuses/featured.json';
			
			$response = $this->_jsonCall($url, NULL, 'GET');
			
			return $response;	
		}
		
		
		/**
		 * Returns extended information of a given user, specified by ID or screen name as per the required id parameter below.  This information includes design settings, so third party developers can theme their widgets according to a given user's preferences.
		 * 
		 * @param	(str/int)	The ID or screen name of a user. 
		 * @param	(str)	Your username.
		 * @param	(str)	Your password.
		 *
		 * @return Information on user.
		 * @author Aral Balkan
		 **/
		function showUser($id, $user, $pass)
		{
			$url = "twitter.com/users/show/$id.json";
			$response = $this->_jsonCall($url, NULL, 'GET', $user, $pass);
			return $response;
		}

		//
		// Direct message methods.
		//

		/**
		 * Returns the list of direct messages for the passed user.
		 *
		 * @param	(str) Your user name
		 * @param	(str) Your password
		 * @param 	(str) Since (optional)
 		 * 
		 * @return 	(array)	List of direct messages
		 * 
		 * @author 	Aral Balkan
		 **/
		function directMessages($user, $pass, $since = NULL)
		{
			$url = 'twitter.com/direct_messages.json';
						
			$vars = array('since' => $since);
			
			$response = $this->_jsonCall($url, $vars, 'GET', $user, $pass);
			
			return $response;
		}

		/**
		 * Returns a list of the 20 most recent direct messages sent by the authenticating user. Includes detailed information about the sending and recipient users.
		 * 
		 * @param (str) Your user name
		 * @param (str) Your password
		 * @param (optional, int) Retrieves the 20 next most recent direct messages sent.
		 * @param (optional, str) Narrows the resulting list of direct messages to just those sent after the specified HTTP-formatted date.
		 * @param (optional, str) Returns only sent direct messages with an ID greater than (that is, more recent than) the specified ID.
		 *
		 * @return List of the 20 most recent direct messages.
		 * @author Aral Balkan
		 **/
		function sentDirectMessages($user, $pass, $page = NULL, $since = NULL, $since_id = NULL)
		{
			$url = 'http://twitter.com/direct_messages/sent.json';
			
			$vars = array('page' => $page, 'since' => $since, 'since_id' => $since_id);
			
			$response = $this->_jsonCall($url, $vars, 'POST', $user, $pass);
			
			return $response;
		}

		
		/**
		 * Sends a direct message
		 * 
		 * @param	User name of recipient
		 * @param	Message to send
		 * @param	Your username
		 * @param	Your password
		 *
		 * @return 	The sent direct message.
		 * @author Aral Balkan
		 **/
		function newDirectMessage($recipient, $message, $user, $pass)
		{
			$url = 'twitter.com/direct_messages/new.json';
			
			$vars = array('user' => $recipient, 'text' => $message);
			
			$response = $this->_jsonCall($url, $vars, 'POST', $user, $pass);
			
			return $response;
		}

		
		/**
		 * Destroys the direct message specified in the required ID parameter.  The authenticating user must be the recipient of the specified direct message.
		 * 
		 * @param (str) The ID of the direct message to destroy.
		 * @param (str) Your username
		 * @param (str) Your password
		 *
		 * @return Destroyed direct message.
		 * @author Aral Balkan
		 **/
		function destroyDirectMessage($id, $user, $pass)
		{
			$url = "http://twitter.com/direct_messages/destroy/$id.json";
			
			$response = $this->_jsonCall($url, NULL, 'POST', $user, $pass);
			
			return $response;
		}
		
		//
		// Friendship methods.
		//
		
		/**
		 * Befriends the user specified in the ID parameter as the authenticating user. Returns the befriended user in the requested format when successful. Returns a string describing the failure condition when unsuccessful.
		 * 
		 * @param (str) The ID or screen name of the user to befriend.
		 * @param (str) Your username
		 * @param (str) Your password
		 *
		 * @return Befriended user or error string.
		 * @author Aral Balkan
		 **/
		function friendshipCreate($id, $user, $pass)
		{
			$url = "http://twitter.com/friendships/create/$id.json";

			$response = $this->_jsonCall($url, NULL, 'POST', $user, $pass);
			
			return $response;
		}
		
		/**
		 * Discontinues friendship with the user specified in the ID parameter as the authenticating user.  Returns the un-friended user in the requested format when successful.  Returns a string describing the failure condition when unsuccessful.
		 * 
		 * @param (str) The ID or screen name of the user with whom to discontinue friendship.
		 * @param (str) Your username
		 * @param (str) Your password
		 *
		 * @return Un-friended user or error string.
		 * @author Aral Balkan
		 **/
		function friendshipDestroy($id, $user, $pass)
		{
			$url = "http://twitter.com/friendships/destroy/$id.json";

			$response = $this->_jsonCall($url, NULL, 'POST', $user, $pass);
			
			return $response;
		}		
		
		//
		// Account methods.
		//
		
		/**
		 * Returns an HTTP 200 OK response code and a format-specific response if authentication was successful.  Use this method to test if supplied user credentials are valid with minimal overhead.
		 *
		 * @return authorized = "true" on success. null on failure.
		 * @author Aral Balkan
		 **/
		function verifyCredentials($user, $pass)
		{
			$url = 'http://twitter.com/account/verify_credentials.json';
			
			$response = $this->_jsonCall($url, NULL, 'GET', $user, $pass);
			
			return $response;
		}
		
		/**
		 * Ends the session of the authenticating user, returning a null cookie.  Use this method to sign users out of client-facing applications like widgets.
		 *
		 * @return Response from Twitter.
		 * @author Aral Balkan
		 **/
		function endSession($user, $pass)
		{
			$url = 'http://twitter.com/account/end_session';
			
			$response = $this->_call($url, NULL, NULL, $user, $pass);
			
			return $response;
		}
		
		////////////////////////////////////////////////////////////////////////////////
		//
		// Custom methods
		//
		// These are additional utility methods that are not part of the official
		// Twitter API. Some of these use screen-scraping techniques and may break
		// in future versions of the official Twitter API.
		//
		////////////////////////////////////////////////////////////////////////////////

		//
		// Custom update methods.
		//

		/**
		 * Returns the number of requested updates from the public timeline (max 20).
		 *
		 * @param	(int)	Number of updates to get (max 20)
		 * @param	(str)	URL-encoded date
		 *
		 * @return array Updates
		 * 
		 * @author Aral Balkan
		 **/
		function getNumPublicTimelineUpdates($n = 20, $since = NULL)
		{
			$url = 'twitter.com/statuses/public_timeline.json';
			
			$vars = array('since' => $since);

			$response = $this->_jsonCall($url, $vars, 'GET');
			
			// Error?
			if (isset($response['error']))
			{
				return $response;
			}

			if ($response === NULL)
			{
				if ($since === NULL)
				{
					// There was an error in the call.
					trigger_error("getNumPublicTimelineUpdates() - Twitter returned null", E_USER_ERROR);
				}
				else
				{
					// There just weren't any updates since the user last checked.
					$response = array();
				}
			}
			else
			{
				$response = array_slice($response, 0, $n);
			}
						
			// Error conditions:
			//return array(false);
			//syntax_error
			
			return $response;			
		}

		
		/**
		 * Alias for getNumPublicTimelineUpdates (which didn't fit on the moo card!) :)
		 *
		 * @param	(int)	Number of updates to get (max 20)
		 * @param	(str)	URL-encoded date
		 * 
		 * @return array Updates
		 * 
		 * @author Aral Balkan
		 **/
		function getPublicUpdates($n = 20, $since = NULL)
		{
			return $this->getNumPublicTimelineUpdates($n, $since);
		}


		/**
		 * Returns the number of updates for the user and her friends (up to 20) for the passed user name (or email).
		 *
		 * Note that when calling this without the since parameter, the results appear to be affected 
		 * by the caching that Twitter has implemented and the results may not be the most recent.
		 *
		 * @param	(str)	User name (or email)
		 * @param	(int)	Number of updates to get (max 20)
		 * @param	(str)	(optional) URL-encoded date
		 *
		 * @return array Updates
		 * 
		 * @author Aral Balkan
		 **/
		function getNumFriendsUpdates($userName, $n = 20, $since = NULL)
		{
			if ($n === NULL) $n = 20;
			
			$url = "twitter.com/statuses/friends_timeline/$userName.json";

			$vars = array('since' => $since);

			$response = $this->_jsonCall($url, $vars, 'GET');     

			if (isset($response['error']))
			{
				return $response;
			}
			
			if ($response === NULL)
			{
				if ($since === NULL)
				{
					// There was an error in the call.
					trigger_error("getNumFriendsUpdates() - Twitter returned null; make sure that the user name you requested ('$userName') exists", E_USER_ERROR);
				}
				else
				{
					// There just weren't any updates since the user last checked.
					$response = array();
				}
			}
			else
			{
				$response = array_slice($response, 0, $n);
			}
			
			// Error conditions:
			//return array(false);
			//syntax_error
			
			return $response;			
		}

		//
		// Custom friendship methods.
		//

		/**
		 * Gets friends for the passed user name. Doesn't
		 * require authentication but will not return friends
		 * who have set themselves to private.
		 *
		 * @param	(str) User name
		 * 
		 * @return 	(array)	List of friends.
		 * @author Aral Balkan
		 **/
		function friendsNoAuth($user)
		{
			$url = "twitter.com/statuses/friends/$userName.json";
			$response = $this->_jsonCall($url,  NULL, 'GET');
			return $response;
		}		

		/**
		 * Returns followers who are not friends.
		 * 
		 * @param 	(str) User name.
		 * @param	(str) Password.
		 *
		 * @return (array) List of followers that are not friends.
		 * @author Aral Balkan
		 **/
		function followersWhoAreNotFriends($user, $pass)
		{
			// Get list of followers and friends from Twitter
			// (this may take a while if you have lots of them!)
			$followers = $this->followers($user, $pass);
			$friends = $this->friends($user, $pass);
			
			// Create followers id-based hash
			$followerIds = array();
			$numFollowers = count($followers);
			for ($i = 0; $i < $numFollowers; $i++)
			{
				$follower = $followers[$i];
				$id = $follower->id;
				error_log('Followers screen_name = '.$id);
				$followerIds[$id] = $follower;
			}
			
			// Create friends id-based hash
			$friendIds = array();
			$numFriends = count($friends);
			for ($i = 0; $i < $numFriends; $i ++)
			{
				$friend = $friends[$i];
				$id = $friend->id;
				error_log('Friends ID = '.$id);
				$friendIds[$id] = $friend;
			}
			
			// Calculate the difference of the id arrays
			$followersWhoAreNotFriends = array();
			foreach ($followerIds as $followerId => $follower)
			{
				error_log("testing: " . $friendIds[$followerId]);
				if (!isset($friendIds[$followerId]))
				{
					error_log("Friend with id $followerId, does not exist.");
					array_push($followersWhoAreNotFriends, $follower);
				}
				else
				{
					error_log("Friend with id $followerId exists.");
				}
			}
			
			return $followersWhoAreNotFriends;
		}
		
		
		/**
		 * Returns a list of your fans (people who have added you as friends but
		 * whom you have not added as a friend.) This is an alias function for
		 * followersWhoAreNotFriends().
		 *
		 * @return void
		 * @author Aral Balkan
		 **/
		function getFans($user, $pass)
		{
			return followersWhoAreNotFriends($user, $pass);
		}


		/**
		 * Follows friend with passed friend ID and user name.
		 * 
		 * You can also call notifications(true, ...)
		 *
		 * @param	(int)	Friend ID
		 * @param	(str)	Friend's user name
		 * @param	(str)	Your user name
		 * @param 	(str) 	Your password
		 * 
		 * @return 	(bool)	Success (true/false).		
		 * 
		 * @author Aral Balkan
		 **/
		function followFriend($friendId, $friendUserName, $yourUserName, $yourPassWord)
		{
			$url = "http://twitter.com/friends/follow/$friendId";
			
			$response = $this->_call($url, NULL, 'GET', $yourUserName, $yourPassWord, "http://twitter.com/$friendUserName");
			
			$success = (strpos($response, 'Notifications on') !== false);
			
			return $success;
		}

		/**
		 * Leaves friend with passed friend ID and user name.
		 * 
		 * You can also call notifications(false, ...)
		 *
		 * @param	(int)	Friend ID
		 * @param	(str)	Friend's user name
		 * @param	(str)	Your user name
		 * @param 	(str) 	Your password
		 * 
		 * @return 	(bool)	Success (true/false).		
		 * 
		 * @author Aral Balkan
		 **/
		function leaveFriend($friendId, $friendUserName, $yourUserName, $yourPassWord)
		{
			$url = "http://twitter.com/friends/leave/$friendId";
			
			$response = $this->_call($url, NULL, 'GET', $yourUserName, $yourPassWord, "http://twitter.com/$friendUserName");
			
			$success = (strpos($response, 'Notifications off') !== false);
			
			return $success;
		}
		
		/**
		 * Turns notifications for a user on or off. 
		 *
		 * @param (bool) True = turn notifications on, false = turn notifications off.
		 * @param (str) Friend's ID.
		 * @param (str) Friend's username.
		 * @param (str) Your username.
		 * @param (str) Your password.
		 * 
		 * @return true/false based on success.
		 * @author Aral Balkan
		 **/
		function notifications($state, $friendId, $friendUserName, $user, $pass)
		{
			// TODO: Looks like bools are coming in as strings. Investigate why this is.
			if ($state == "true")
			{
				return $this->followFriend($friendId, $friendUserName, $user, $pass);
			}
			else
			{
				return $this->leaveFriend($friendId, $friendUserName, $user, $pass);
			}
		}

		//
		// Deprecated methods: Do not use. May be removed in future versions.
		//

		/**
		 * Adds friend with passed friend ID and user name.
		 * 
		 * DEPRECATED! Use the new friendshipCreate() method in the official Twitter API instead.
		 * 
		 * Deprecated as of Beta 1.4.
		 *
		 * @param	(int)	Friend ID
		 * @param	(str)	Friend's user name
		 * @param	(str)	Your user name
		 * @param 	(str) 	Your password
		 * 
		 * @return 	(bool)	Success (true/false).		
		 * 
		 * @author Aral Balkan
		 **/
		function addFriend($friendId, $friendUserName, $yourUserName, $yourPassWord)
		{
			$url = "http://twitter.com/friendships/create/$friendId";
			
			$response = $this->_call($url, NULL, 'GET', $yourUserName, $yourPassWord, "http://twitter.com/$friendUserName");
			
			$checkString = "<strong>You follow ".$friendUserName."</strong>";
			$success = (strpos($response, $checkString ) !== false);
		
			return $success;			
		}


		/**
		 * Removes friend with passed friend ID and user name.
		 * 
		 * DEPRECATED! Use the new friendshipDestroy() method in the official Twitter API instead.
		 * 
		 * Deprecated as of Beta 1.4.
		 * 
		 * @param	(int)	Friend ID
		 * @param	(str)	Friend's user name
		 * @param	(str)	Your user name
		 * @param 	(str) 	Your password
		 * 
		 * @return 	(bool)	Success (true/false).		
		 * 
		 * @author Aral Balkan
		 **/
		function removeFriend($friendId, $friendUserName, $yourUserName, $yourPassWord)
		{
			$url = "http://twitter.com/friendships/destroy/$friendId";
			
			$response = $this->_call($url, NULL, 'GET', $yourUserName, $yourPassWord, "http://twitter.com/$friendUserName");
			
			$success = (strpos($response, 'add</a>') !== false);
			
			return $success;
		}
	}
?>