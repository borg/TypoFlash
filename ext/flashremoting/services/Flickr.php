<?php
	/**
	 * 
	 * SWX Flickr API by Aral Balkan. Uses the phpFlickr library. You can call this API using SWX, Amfphp, JSON and XML-RPC.
	 * 
	 * @author	Aral Balkan
	 * @copyright	2007 Aral Balkan. All Rights Reserved. 
	 * @link 	http://aralbalkan.com
	 * @link 	http://swxformat.org
	 * @link    mailto://aral@aralbalkan.com
	 * 
	**/
	
	require_once("../lib/phpFlickr/phpFlickr.php");

	class Flickr
	{
		// Please replace these keys with your own if deploying
		// to your own server and please do not abuse these
		// or they will have to be revoked/changed.
		
		// Desktop key
		var $API_KEY = "e7efb59164979981686e62d8bcc473be";
		var $SHARED_SECRET = "2be064bed40b0b78";
		
		// Mobile key
		// var $SHARED_SECRET = "5d4def3e2b05d3ec";
		// var $API_KEY = "da425c036533e7c72761c711cbabcd7f";
		
		var $api;	// phpFlickr class instance
	
		function Flickr()
		{
			global $flickr;
			
			// I'm putting my (Aral's) Flickr API key here so you guys
			// can get up and running with this quickly. Please don't
			// abuse this. If you're going to build your own apps 
			// using the SWX Flickr API, please add your API here instead. 
			// Thanks! :)
			$this->api = new phpFlickr($this->API_KEY, $this->SHARED_SECRET);
		}
	
	
		//
		// SWX Flickr API extensions 
		// 
		// This methods are not part of the official Flickr API but make
		// it easier to work with the Flickr API by returning actually
		// useful URLs, etc., to minimize the amount of client-side
		// data massaging that the user has to do.
		//
		
		/**
		 * DEPRECATED: Alias for swxGetUserPhotos.
		 * 
		 * This method is for backwards compatibility with apps written for SWX Beta 1.3 and earlier. Please use the swxGetUserPhotos methods in the future.
		 * 
		 * @param	Flickr user name
		 * @param 	Style of photo as string (square, thumbnail, small, medium, large, original)
		 * @param	Number of photos to receive (defaults to 10).
		 * @param 	Page of results to receive (defaults to 1).
		 * 
		 * @return User's photos.
		 * @author Aral Balkan
		 **/
		function getUserPhotos($userName, $photoStyle = "medium", $numPhotos = 10, $page = 1)
		{
			return $this->swxGetUserPhotos($userName, $photoStyle, $numPhotos, $page);
		}
	
		/**
		 * Returns the requested number of photos for the specified user.
		 * 
		 * @param	Flickr user name
		 * @param 	Style of photo as string (square, thumbnail, small, medium, large, original)
		 * @param	Number of photos to receive (defaults to 10).
		 * @param 	Page of results to receive (defaults to 1).		 
		 * 
		 * @return User's photos.
		 * @author Aral Balkan
		 **/
		function swxGetUserPhotos($userName, $photoStyle = "medium", $numPhotos = 10, $page = 1)
		{
			$i = 0;
			if (!empty($userName)) 
			{
			    // Find the NSID of the username inputted via the form.
			    $person = $this->api->people_findByUsername($userName);
			
				// Flickr Error?
				if ($person === false) 
				{
					return $this->_getResult($person);
				}
			
			    // Get $numPhotos of the user's public photos, starting at page $page.
			    $photos = $this->api->people_getPublicPhotos($person['id'], NULL, $numPhotos, $page);

				// Flickr Error?
				if ($photos === false)
				{
					return $this->_getResult($photos);
				}

				// Build the results
				$photoList = array();
				
			    // Loop through the photos and output the html
			    foreach ((array)$photos['photo'] as $photo) 
				{
			    	$newPhoto = array
					(	
						'id' => $photo['id'],
						'link' =>  'http://www.flickr.com/photos/'.$photo['owner'].'/'.$photo['id'],
						'alt' => $photo['title'],
						'src' => $this->api->buildPhotoURL($photo, $photoStyle)
					);
					
					array_push($photoList, $newPhoto);
				}
			}

			$result = array('photo' => $photoList, 'page' => $photos['page'], 'pages' => $photos['pages']);
						
			return $result;
		}
		
		
		/**
		 * Returns a list of the latest public photos uploaded to flickr, along with the URLs of the photos (.src) and links to the photo pages (.link).
		 * 
		 * This is a SWX Flickr API Extension and not part of the official Flickr API. 
		 * 
		 * Does not require authentication.
		 * 
		 * @param 	Style of photo as string (square, thumbnail, small, medium, large, original)
		 * @param (str, optional) comma-delimited list of extra information to fetch for each returned record. Currently supported fields are: license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo, tags, machine_tags.
		 * @param (int, optional) Number of photos to return per page. If this argument is omitted, it defaults to 100. The maximum allowed value is 500.
		 * @param (int, optional) The page of results to return. If this argument is omitted, it defaults to 1.
		 *
		 * @return List of the latest public photos uploaded to flickr, including urls and links.
		 * @author Aral Balkan
		 **/
		function swxPhotosGetRecent($photoStyle = "medium", $extras = NULL, $perPage = NULL, $page = NULL)
		{
			$photos = $this->api->photos_getRecent($extras, $perPage, $page);
			
			// Flickr Error?
			if ($photos === false)
			{
				return $this->_getResult($photos);
			}
			
			// Build the results
			$photoList = array();
			
		    // Loop through the photos and output the html
		    foreach ((array)$photos['photo'] as $photo) 
			{
		    	$newPhoto = array
				(	
					'id' => $photo['id'],
					'link' =>  'http://www.flickr.com/photos/'.$photo['owner'].'/'.$photo['id'],
					'alt' => $photo['title'],
					'src' => $this->api->buildPhotoURL($photo, $photoStyle),
					'isFamily' => $photo['isfamily'],
					'isFriend' => $photo['isfriend'],
					'isPublic' => $photo['ispublic']				);
				
				array_push($photoList, $newPhoto);
			}
			
			$result = array('photo' => $photoList, 'page' => $photos['page'], 'pages' => $photos['pages']);
			
			return $result;
		}
		
				
		
		//
		// Official Flickr API
 		//
		
		//
		// Activity methods.
		//
		
		/**
		 * Returns a list of recent activity on photos commented on by the calling user. 
		 * Do not poll this method more than once an hour.
		 *
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.activity.userComments.html
		 * 
		 * Requires read authentication.
		 * 
		 * @param (str)	The auth token that was returned by authGetToken().
		 * @param (int, optional) Number of items to return per page. If this argument is omitted, it defaults to 10. The maximum allowed value is 50.
		 * @param (int, optional) The page of results to return. If this argument is omitted, it defaults to 1.
		 * 
		 * @return List of recent activity on photos commented on by the calling user.
		 * @author Aral Balkan
		 **/
		function activityUserComments($token, $perPage = NULL, $page = NULL)
		{
			$this->api->setToken($token);
			$activityComments = $this->api->activity_userComments($perPage, $page = NULL);
			
			return $this->_getResult($activityComments);
		}
		
		
		/**
		 * Returns a list of recent activity on photos belonging to the calling user.
		 * Do not poll this method more than once an hour.
		 *
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.activity.userPhotos.html
		 * 
		 * Requires read authentication.
		 * 
		 * @param (str)	The auth token that was returned by authGetToken().
		 * @param (str, optional) The timeframe in which to return updates for. This can be specified in days ('2d') or hours ('4h'). The default behavoir is to return changes since the beginning of the previous user session.
		 * @param (int, optional) Number of items to return per page. If this argument is omitted, it defaults to 10. The maximum allowed value is 50.
		 * @param (int, optional) The page of results to return. If this argument is omitted, it defaults to 1.
		 * 
		 * @return List of recent activity on photos belonging to the calling user.
		 * @author Aral Balkan
		 **/
		function activityUserPhotos ($token, $timeframe = NULL, $perPage = NULL, $page = NULL)
	    {
			$this->api->setToken($token);
			$activityPhotos = $this->api->activity_userPhotos ($timeframe, $perPage, $page);
			
			return $this->_getResult($activityPhotos);
		}
		
		//
		// Authentication methods. 
		// (Uses the authentication process for desktop applications.)
		//
	
	
		/**
		 * Returns the credentials attached to an authentication token. 
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.auth.checkToken.html
		 * 
		 * Does not require authentication.
		 * 
		 * @param (str)	The auth token that was returned by authGetToken().
		 *
		 * @return Permissions for token.
		 * @author Aral Balkan
		 **/
		function authCheckToken($token)
		{
			$this->api->setToken($token);
			
			$result = $this->api->auth_checkToken();
			
			return $this->_getResult($result);
		}		
	
	
		/**
		 * Returns a frob to be used during authentication.
		 * 
		 * To authenticate a user using the SWX Flickr API: 
		 * 
		 * 1. First call this method and get the magic frob value.
		 * 2. Call the authGetUrl() method and pass the frob as well as the type of authentication you want ("read", "write", "delete"). This will return a URL.
		 * 3. Send the user to the URL returned in Step 2. Flickr will ask them to authorize your application. Once they've done that, they'll return to your application.
		 * 4. Call the authGetToken() method and pass the frob. If the user granted your application the correct permissions, you should get a token back. Send this token for all authenticated calls. 
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.auth.getFrob.html
		 * 
		 * Original Flickr authorization spec: 
		 * http://www.flickr.com/services/api/auth.spec.html
		 * 
		 * Flickr Desktop Applications How-To:
		 * http://www.flickr.com/services/api/auth.howto.desktop.html		
		 *
		 * @return (str) Frob.
		 * @author Aral Balkan
		 **/
		function authGetFrob()
		{
			$frob = $this->api->auth_getFrob();
			return $this->_getResult($frob);
		}


		/**
		 * Get the full authentication token for a mini-token. This method call must be signed.
		 * 
		 * Note: If you want to test/use this, make sure you are using a Flickr Mobile Key. The SWX key is in the source code for testing purposes. Please use your own key for deployment purposes and please don't abuse they key or I'll be forced to revoke it. Thanks! :)
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.auth.getFullToken.html
		 * 
		 * Does not require authentication.
		 * 
		 * @param (str) The mini-token typed in by a user. It should be 9 digits long. It may optionally contain dashes.
		 *
		 * @return (str) Token, perms, user id and name.
		 * @author Aral Balkan
		 **/
		function authGetFullToken($miniToken)
		{
			$result = $this->api->auth_getFullToken($miniToken);
			
			return $this->_getResult($result);
		}

		/**
		 * Returns the authentication url to redirect the user to so 
		 * they can log in and authorize the Flash application. (This
		 * uses the authentication mechanism for desktop applications, which
		 * is the one that works best for Flash applications).
		 * 
		 * For a full explanation of the authorization system in the 
		 * SWX Flickr API, see the notes on the authGetFrob() method.
		 * 
		 * @param (str) The frob that was returned by the authGetFrob() method.
		 * @param (str, optional) The permissions being requested ("read"|"write"|"delete"). Write includes read, and delete includes both read and write permissions. Defaults to read.
		 *
		 * @return (str) URL to send user to so they can authorize the application.
		 * @author Aral Balkan
		 **/
		function authGetUrl ($frob, $perms="read")
	    {
			// Calculate the desktop auth url.
			$api_sig = md5($this->SHARED_SECRET . 'api_key' . $this->API_KEY . 'frob' . $frob . 'perms' . $perms);
			$desktopAuthUrl = 'http://www.flickr.com/services/auth/?api_key=' . $this->API_KEY . '&perms=' . $perms . '&frob=' . $frob . '&api_sig='. $api_sig;

			// And return it.
			return $this->_getResult($desktopAuthUrl);	    
		}
		

		/**
		 * Returns the token you need to make authenticated calls if the user has authenticated
		 * your application.
		 * 
		 * For a full explanation of the authorization system in the 
		 * SWX Flickr API, see the notes on the authGetFrob() method.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.auth.getToken.html
		 * 
		 * @param (str)	The frob that was returned by the authGetFrob() method.
		 *
		 * @return (str) Flickr auth token.
 		 * @author Aral Balkan
		 **/
		function authGetToken($frob)
		{
			$token = $this->api->auth_getToken($frob);
			return $this->_getResult($token);
		}
		
		
		//		
		// Blog methods
		//
		
		
		/**
		 * Get a list of configured blogs for the calling user.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.blogs.getList.html
		 * 
		 * Requires read authentication.
		 * 
		 * @param (str)	The auth token that was returned by authGetToken().
		 *
		 * @return List of blogs for the calling user.
		 * @author Aral Balkan
		 **/
		function blogsGetList($token)
		{
			$this->api->setToken($token);
			$blogList = $this->api->blogs_getList();
			
			return $this->_getResult($blogList);
		}

		
		/**
		 * Posts a photo to the blog with the passed id. 
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.blogs.postPhoto.html
		 * 
		 * Requires write authentication
		 * 
		 * @param (str)	The auth token that was returned by authGetToken().
		 * @param (str)	The id of the blog to post to.
		 * @param (str)	The id of the photo to blog.
		 * @param (str)	The blog post title.
		 * @param (str)	The blog post body.
		 * @param (str)	The password for the blog (used when the blog does not have a stored password).
		 *
		 * @return (bool) True/False depending on whether the call succeeded or failed.
		 * @author Aral Balkan
		 **/
		function blogsPostPhoto($token, $blogId, $photoId, $title, $description, $blogPassword = NULL)
		{
			$this->api->setToken($token);
			$success = $this->api->blogs_postPhoto($blogId, $photoId, $title, $description, $blogPassword);
			
			return $this->_getResult($success);
		}


		//
		// Contacts methods
		//

		
		/**
		 * Get a list of contacts for the calling user.
		 * 
		 * Valid values for the filter parameter, below, are:
		 * 
		 * friends: Only contacts who are friends (and not family).
		 * family: Only contacts who are family (and not friends).
		 * both: Only contacts who are both friends and family.
		 * neither: Only contacts who are neither friends nor family.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.contacts.getList.html
		 *
		 * Requires read authentication.
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str, optional) An optional filter of the results.
		 * @param (int, optional) The page of results to return. If this argument is omitted, it defaults to 1.
		 * @param (int, optional) Number of photos to return per page. If this argument is omitted, it defaults to 1000. The maximum allowed value is 1000.
		 * 
		 * @return List of contacts or false on error.
		 * @author Aral Balkan
		 **/
		function contactsGetList($token, $filter = NULL, $page = NULL, $per_page = NULL)
		{
			$this->api->setToken($token);
			
			error_log("page = $page, perpage = $per_page");
			
			$contacts = $this->api->contacts_getList($filter, $page, $per_page);
			
			return $this->_getResult($contacts);
		}
		
		
		/**
		 * Get the contact list for a user.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.contacts.getPublicList.html 
		 *
		 * Does not require authentication.
		 * 
		 * @param (str) The NSID of the user to fetch the contact list for.
		 * @param (int, optional) The page of results to return. If this argument is omitted, it defaults to 1.
		 * @param (int, optional) Number of contacts to return per page. If this argument is omitted, it defaults to 1000. The maximum allowed value is 1000.
		 * 
		 * @return List of contacts for the user.
		 * @author Aral Balkan
		 **/
		function contactsGetPublicList($userId, $page = NULL, $perPage = NULL)
		{
			$publicList = $this->api->contacts_getPublicList($userId, $page, $perPage);
			
			return $this->_getResult($publicList);
		}
		
		
		//
		// Favorites methods
		//
		
		
		/**
		 * Returns a list of the user's favorite photos. 
		 * Only photos which the calling user has permission to see are returned.
		 * 
		 * Official Flickr API documentation: 
	 	 * http://www.flickr.com/services/api/flickr.favorites.getList.html
		 * 
		 * Requires read authentication.
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str, optional) The NSID of the user to fetch the favorites list for. If this argument is omitted, the favorites list for the calling user is returned.
		 * @param (str, optional) A comma-delimited list of extra information to fetch for each returned record. Currently supported fields are: license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo, tags, machine_tags.
		 * @param (int, optional) Number of photos to return per page. If this argument is omitted, it defaults to 100. The maximum allowed value is 500.
		 * @param (int, optional) The page of results to return. If this argument is omitted, it defaults to 1.
		 * 
		 * @return List of user's favorite photos.
		 * @author Aral Balkan
		 **/
    	function favoritesGetList($token, $userId = NULL, $extras = NULL, $perPage = NULL, $page = NULL)
		{
			$this->api->setToken($token);
			$favorites = $this->api->favorites_getList($userId, $extras, $perPage, $page);
			
			return $this->_getResult($favorites);
		}
		
		
		/**
		 * Returns a list of favorite public photos for the given user.
		 * 
		 * Official Flickr API documentation: 
		 * http://www.flickr.com/services/api/flickr.favorites.getPublicList.html
		 * 
		 * Does not require authentication.
		 * 
		 * @param (str) The user to fetch the favorites list for.
		 * @param (str, optional) A comma-delimited list of extra information to fetch for each returned record. Currently supported fields are: license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo, tags, machine_tags.
		 * @param (int, optional) Number of photos to return per page. If this argument is omitted, it defaults to 100. The maximum allowed value is 500.
		 * @param (int, optional) The page of results to return. If this argument is omitted, it defaults to 1.
		 *
		 * @return List of favorite public photos for the given user.
		 * @author Aral Balkan
		 **/
		function favoritesGetPublicList($userId, $extras = NULL, $perPage = NULL, $page = NULL)
		{
			$publicList = $this->api->favorites_getPublicList($userId, $extras, $perPage, $page);
			
			return $this->_getResult($publicList);
		}
		
		
		/**
		 * Adds a photo to a user's favorites list.
		 * 
		 * Official Flickr API documentation: 
		 * http://www.flickr.com/services/api/flickr.favorites.add.html
		 * 
		 * Requires write authentication and a POST request.
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str) The id of the photo to add to the user's favorites.
		 *
		 * @return True/False depending on whether call was successful.
		 * @author Aral Balkan
		 **/
		function favoritesAdd ($token, $photoId)
		{
			$this->api->setToken($token);
			$success = $this->api->favorites_add ($photoId);
			
			return $this->_getResult($success);
		}
		
		
		/**
		 * Removes a photo from a user's favorites list.
		 * 
		 * Official Flickr API documentation: 
		 * http://www.flickr.com/services/api/flickr.favorites.remove.html
		 *
		 * Requires write authentication and a POST request.
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str) The id of the photo to remove from the user's favorites.
		 *
		 * @return True/False depending on whether call was successful.
		 * @author Aral Balkan
		 **/
		function favoritesRemove($token, $photoId)
		{
			$this->api->setToken($token);
			$success = $this->api->favorites_remove($photoId);
			
		    return $this->_getResult($success);
		}
		
		
		//
		// Groups methods
		//
		
		
		/**
		 * Browse the group category tree, finding groups and sub-categories.
		 * 
		 * Official Flickr API documentation: 
		 * http://www.flickr.com/services/api/flickr.groups.browse.html
		 * 
		 * Requires read authentication.
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str, optional) The category id to fetch a list of groups and sub-categories for. If not specified, it defaults to zero, the root of the category tree.
		 *
		 * @return Category information.
		 * @author Aral Balkan
		 **/
		function groupsBrowse($token, $catId = NULL)
		{
			$this->api->setToken($token);
			$groups = $this->api->groups_browse($catId);
			
			return $this->_getResult($groups);
		}
		
		
		/**
		 * Search for groups. 
		 * 18+ groups will only be returned for authenticated calls where the authenticated user is over 18.
		 * 
		 * Official Flickr API documentation: 
		 * http://www.flickr.com/services/api/flickr.groups.search.html
		 * 
		 * Does not require authentication unless you also want to receive 18+ groups.
		 * 
		 * @param (str)	Text to search for.
		 * @param (int)	Number of groups to return per page. If this argument is ommited, it defaults to 100. The maximum allowed value is 500.
		 * @param (int)	The page of results to return. If this argument is ommited, it defaults to 1.
		 * @param (str; optional) The auth token that was returned by authGetToken(). Only required to receive 18+ groups.
		 *
		 * @return List of groups matching the search.
		 * @author Aral Balkan
		 **/
		function groupsSearch($text, $perPage = NULL, $page = NULL, $token = NULL)
		{
			if ($token != NULL)
			{
				$this->api->setToken($token);
			}
			$groups = $this->api->groups_search($text, $perPage, $page);
			
			return $this->_getResult($groups);
		}
		
		
		/**
		 * Get information about a group.
		 * 
		 * Official Flickr API documentation: 
		 * http://www.flickr.com/services/api/flickr.groups.getInfo.html
		 * 
		 * Does not require authentication.
		 * 
		 * @param (str)	The NSID of the group to fetch information for.
		 *
		 * @return Information on requested group.
		 * @author Aral Balkan
		 **/
		function groupsGetInfo($groupId)
		{
			$groupInfo = $this->api->groups_getInfo($groupId);
			
			return $this->_getResult($groupInfo);
		}
		
		
		//
		// Groups pools methods
		//
		
		
		/**
		 * Add a photo to a group's pool.
		 * 
		 * Official Flickr API documentation: 
		 * http://www.flickr.com/services/api/flickr.groups.pools.add.html
		 * 
		 * Requires write authentication.
		 *
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str)	The id of the photo to add to the group pool. The photo must belong to the calling user.
		 * @param (str)	The NSID of the group who's pool the photo is to be added to.
		 * 
		 * @return True/False depending on whether call was successful.
		 * @author Aral Balkan
		 **/
		function groupsPoolAdd ($token, $photoId, $groupId)
		{
			$this->api->setToken($token);
			$success = $this->api->groups_pools_add ($photoId, $groupId);
			
			return $this->_getResult($success);
		}
		
		
		/**
		 * Returns next and previous photos for a photo in a group pool.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.groups.pools.getContext.html
		 * 
		 * Does not require authentication.
		 * 
		 * @param (str) The id of the photo to fetch the context for.
		 * @param (str) The nsid of the group who's pool to fetch the photo's context for.
		 *
		 * @return The next and previous photos for requested photo, in the requested group.
		 * @author Aral Balkan
		 **/
		function groupsPoolsGetContext($photoId, $groupId)
		{
			$context = $this->api->groups_pools_getContext ($photoId, $groupId);
	        
			return $this->_getResult($context);
		}
		

		/**
		 * Returns a list of groups to which you can add photos.
		 * 
		 * Official Flickr API documentation: 
		 * http://www.flickr.com/services/api/flickr.groups.pools.getGroups.html
		 * 
		 * Requires read authentication.
		 *
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (int, optional) The page of results to return. If this argument is omitted, it defaults to 1.
		 * @param (int, optional) Number of groups to return per page. If this argument is omitted, it defaults to 400. The maximum allowed value is 400.
		 * 
		 * @return List of groups to which you can add photos.
		 * @author Aral Balkan
		 **/
		function groupsPoolsGetGroups ($token, $page = NULL, $perPage = NULL)
		{
			$this->api->setToken($token);
			$groups = $this->api->groups_pools_getGroups ($page, $perPage);
			
			return $this->_getResult($groups);
		}
		
		
		/**
		 * Returns a list of pool photos for a given group, 
		 * based on the permissions of the group and the user logged in (if any).
		 * 
		 * Official Flickr API documentation: 
		 * http://www.flickr.com/services/api/flickr.groups.pools.getPhotos.html
		 * 
		 * Does not require authentication.
		 * 
		 * @param (str) The id of the group who's pool you which to get the photo list for.
		 * @param (str, optional) A tag to filter the pool with. At the moment only one tag at a time is supported.
		 * @param (str, optional) The nsid of a user. Specifiying this parameter will retrieve for you only those photos that the user has contributed to the group pool.
		 * @param (str, optional) A comma-delimited list of extra information to fetch for each returned record. Currently supported fields are: license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo, tags, machine_tags.
		 * @param (int, optional) Number of photos to return per page. If this argument is omitted, it defaults to 100. The maximum allowed value is 500.
		 * @param (int, optional) The page of results to return. If this argument is omitted, it defaults to 1.
		 *
		 * @return List of pool photos for a given group.
		 * @author Aral Balkan
		 **/
		function groupsPoolsGetPhotos($groupId, $tags = NULL, $userId = NULL, $extras = NULL, $perPage = NULL, $page = NULL)
		{
			$photos = $this->api->groups_pools_getPhotos ($groupId, $tags, $userId, $extras, $perPage, $page);
			
			return $this->_getResult($photos);
		}
		
		
		/**
		 * Remove a photo from a group pool.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.groups.pools.remove.html
		 * 
		 * Requires write authentication. 
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str) The id of the photo to remove from the group pool. The photo must either be owned by the calling user of the calling user must be an administrator of the group.
		 * @param (str) The NSID of the group who's pool the photo is to removed from.
		 *
		 * @return True/Error obj depending on whether call was successful.
		 * @author Aral Balkan
		 **/
		function groupsPoolsRemove($token, $photoId, $groupId)
		{
			$this->api->setToken($token);
			$success = $this->api->groups_pools_remove ($photoId, $groupId);
			
			return $this->_getResult($success);
		}
		
		
		//
		// Interestingness methods
		//
		
		/**
		 * Returns the list of interesting photos for the most recent day or a user-specified date.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.interestingness.getList.html
		 * 
		 * Does not require authentication.
		 * 
		 * @param (str, optional) A specific date, formatted as YYYY-MM-DD, to return interesting photos for.
		 * @param (str, optional) A comma-delimited list of extra information to fetch for each returned record. Currently supported fields are: license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo, tags, machine_tags.
		 * @param (int, optional) Number of photos to return per page. If this argument is omitted, it defaults to 100. The maximum allowed value is 500.
		 * @param (int, optional) The page of results to return. If this argument is omitted, it defaults to 1.
		 *
		 * @return List of interesting photos for the most recent day or a user-specified date.
		 * @author Aral Balkan
		 **/
		function interestingnessGetList($date = NULL, $extras = NULL, $perPage = NULL, $page = NULL)
		{
			$photos = $this->api->interestingness_getList($date, $extras, $perPage, $page);
			
			return $this->_getResult($photos);
		}
		
		//
		// People methods
		//
		
		/**
		 * Return a user's NSID, given their email address
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.people.findByEmail.html
		 * 
		 * Does not require authentication.
		 * 
		 * @param (str) The email address of the user to find (may be primary or secondary).
		 * 
		 * @return User's NSID.
		 * @author Aral Balkan
		 **/
		function peopleFindByEmail($findEmail)
		{
			$nsid = $this->api->people_findByEmail($findEmail);
			
			return $this->_getResult($nsid);
		}
		
		
		/**
		 * Return a user's NSID, given their username.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.people.findByUsername.html
		 * 
		 * Does not require authentication.
		 * 
		 * @param (str) The username of the user to lookup.
		 *
		 * @return User's NSID.
		 * @author Aral Balkan
		 **/
		function peopleFindByUsername($userName)
		{
			$nsid = $this->api->people_findByUsername($userName);
		    
			return $this->_getResult($nsid);
		}
		
		
		/**
		 * Get information about a user.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.people.getInfo.html
		 *
		 * Does not require authentication but will return additional information
		 * if authenticated. 
		 * 
		 * @param (str) The NSID of the user to fetch information about.
		 * @param (str, optional) The auth token that was returned by authGetToken().
		 * 
		 * @return User info.
		 * @author Aral Balkan
		 **/
		function peopleGetInfo($userId, $token = NULL)
		{
			if ($token != NULL)
		    {
				$this->api->setToken($token);
			}
			
			$userInfo = $this->api->people_getInfo($userId);
			
			return $this->_getResult($userInfo);
		}
		
		
		/**
		 * Returns the list of public groups a user is a member of.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.people.getPublicGroups.html
		 * 
		 * Does not require authentication.
		 * 
		 * @param (str) The NSID of the user to fetch groups for.
		 *
		 * @return List of public groups a user is a member of.
		 * @author Aral Balkan
		 **/
		function peopleGetPublicGroups($userId)
		{    
			$publicGroups = $this->api->people_getPublicGroups($userId);
			
			return $this->_getResult($publicGroups);
		}

		
		/**
		 * Get a list of public photos for the given user.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.people.getPublicPhotos.html
		 * 
		 * Does not require authentication. 
		 *
		 * @param (str) The NSID of the user who's photos to return.
		 * @param (str, optional) A comma-delimited list of extra information to fetch for each returned record. Currently supported fields are: license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo, tags, machine_tags.
		 * @param (int, optional) Number of photos to return per page. If this argument is omitted, it defaults to 100. The maximum allowed value is 500.
		 * @param (int, optional) The page of results to return. If this argument is omitted, it defaults to 1.
		 * 
		 * @return List of public photos for the given user.
		 * @author Aral Balkan
		 **/
		function peopleGetPublicPhotos($userId, $extra = NULL, $perPage = NULL, $page = NULL)
		{
			$publicPhotos = $this->api->people_getPublicPhotos($userId, $extras, $perPage, $page);
			
			return $this->_getResult($publicPhotos);
		}
		
		
		/**
		 * Returns information for the calling user related to photo uploads.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.people.getUploadStatus.html
		 * 
		 * Requires read authentication.
		 *
		 * @param (str) The auth token that was returned by authGetToken().
		 * 
		 * @return Information for the calling user related to photo uploads.
		 * @author Aral Balkan
		 **/
		function peopleGetUploadStatus($token)
		{
			$this->api->setToken($token);
			$uploadStatus = $this->api->people_getUploadStatus();
	    
			return $this->_getResult($uploadStatus);
		}
		
		
		//
		// Photos methods
		//
		
		
		/**
		 * Add tags to a photo.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photos.addTags.html
		 * 
		 * Requires write authentication.
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str) The id of the photo to add tags to.
		 * @param (str) The tags to add to the photo.
		 *
		 * @return True/False depending on result of the call.
		 * @author Aral Balkan
		 **/
		function photosAddTags($token, $photoId, $tags)
		{
			$this->api->setToken($token);
			
			$success = $this->api->photos_addTags ($photoId, $tags);
			
			return $this->_getResult($success);
		}
		
		
		/**
		 * Delete a photo from flickr.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photos.delete.html
		 * 
		 * This method requires delete authentication.
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str) The id of the photo to delete.
		 *
		 * @return True/False depending on result of the call.
		 * @author Aral Balkan
		 **/
		function photosDelete($token, $photoId)
		{
			$this->api->setToken($token);
			
			$success = $this->api->photos_delete($photoId);
			
			return $this->_getResult($success);
		}


		/**
		 * Returns all visible sets and pools the photo belongs to.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photos.getAllContexts.html
		 * 
		 * Does not require authentication.
		 * 
		 * @param (str) The photo to return information for.
		 *
		 * @return All visible sets and pools the photo belongs to.
		 * @author Aral Balkan
		 **/
		function photosGetAllContexts($photoId)
		{
			$contexts = $this->api->photos_getAllContexts($photoId);
			
			return $this->_getResult($contexts);
		}
		
		
		/**
		 * Fetch a list of recent photos from the calling users' contacts.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photos.getContactsPhotos.html
		 *
		 * Requires read authentication.
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (int, optional) Number of photos to return. Defaults to 10, maximum 50. This is only used if single_photo is not passed.
		 * @param (int, optional) Set as 1 to only show photos from friends and family (excluding regular contacts).
		 * @param (?, optional) Only fetch one photo (the latest) per contact, instead of all photos in chronological order.
		 * @param (int, optional) Set to 1 to include photos from the calling user.
		 * @param (str, optional) A comma-delimited list of extra information to fetch for each returned record. Currently supported fields are: license, date_upload, date_taken, owner_name, icon_server, original_format, last_update.
		 * 
		 * @return List of recent photos from the calling users' contacts.
		 * @author Aral Balkan
		 **/
		function photosGetContactsPhotos($token, $count = NULL, $justFriends = NULL, $singlePhoto = NULL, $includeSelf = NULL, $extras = NULL)
		{
			$this->api->setToken($token);
			
			$contactsPhotos = $this->api->photos_getContactsPhotos($count, $justFriends, $singlePhoto, $includeSelf, $extras);
			
			return $this->_getResult($contactsPhotos);
		}
		
		
		/**
		 * Fetch a list of recent public photos from a users' contacts.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photos.getContactsPublicPhotos.html
		 * 
		 * @param (str) The NSID of the user to fetch photos for.
		 * @param (int, optional) Number of photos to return. Defaults to 10, maximum 50. This is only used if single_photo is not passed.
		 * @param (int, optional) Set as 1 to only show photos from friends and family (excluding regular contacts).
		 * @param (?, optional) Only fetch one photo (the latest) per contact, instead of all photos in chronological order.
		 * @param (int, optional) Set to 1 to include photos from the calling user.
		 * @param (str, optional) A comma-delimited list of extra information to fetch for each returned record. Currently supported fields are: license, date_upload, date_taken, owner_name, icon_server, original_format, last_update.
		 *
		 * @return List of recent public photos from a users' contacts.
		 * @author Aral Balkan
		 **/
		function photosGetContactsPublicPhotos($userId, $count = NULL, $justFriends = NULL, $singlePhoto = NULL, $includeSelf = NULL, $extras = NULL)
		{
			$contactsPublicPhotos = $this->api->photos_getContactsPublicPhotos($userId, $count, $justFriends, $singlePhoto, $includeSelf, $extras);
			
			return $this->_getResult($contactsPublicPhotos);
		}
		
		
		/**
		 * Returns next and previous photos for a photo in a photostream.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photos.getContext.html
		 *
		 * Does not require authentication.
		 * 
		 * @param (str) The id of the photo to fetch the context for.
		 * 
		 * @return Next and previous photos for a photo in a photostream.
		 * @author Aral Balkan
		 **/
		function photosGetContext($photoId)
		{
			$context = $this->api->photos_getContext ($photoId);
			
			return $this->_getResult($context);
		}
		
		
		/**
		 * Gets a list of photo counts for the given date ranges for the calling user.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photos.getCounts.html
		 * 
		 * Requires read authentication.
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str, optional) A comma delimited list of unix timestamps, denoting the periods to return counts for. They should be specified smallest first. You must specify either this or takenDates. 
		 * @param (str, optional) A comma delimited list of mysql datetimes, denoting the periods to return counts for. They should be specified smallest first. You must specify either this or dates.
		 * 
		 * @return List of photo counts for the given date ranges for the calling user.
		 * @author Aral Balkan
		 **/
		function photosGetCounts($token, $dates = NULL, $takenDates = NULL)
		{
			$this->api->setToken($token);
			$counts = $this->api->photos_getCounts($dates, $takenDates);
			
			return $this->_getResult($counts);
		}
		
		
		/**
		 * Retrieves a list of EXIF/TIFF/GPS tags for a given photo. 
		 * The calling user must have permission to view the photo.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photos.getExif.html
		 *
		 * Does not require authentication.
		 * 
		 * @param (str) The id of the photo to fetch information for.
		 * @param (str, optional) The secret for the photo. If the correct secret is passed then permissions checking is skipped. This enables the 'sharing' of individual photos by passing around the id and secret.
		 * 
		 * @return List of EXIF/TIFF/GPS tags for a given photo.
		 * @author Aral Balkan
		 **/
		function photosGetExif($photoId, $secret = NULL)
		{
			$exif = $this->api->photos_getExif ($photoId, $secret);
			
			return $this->_getResult($exif);
		}
		
		
		/**
		 * Returns the list of people who have favorited a given photo.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photos.getFavorites.html
		 * 
		 * Does not require authentication.
		 * 
		 * @param (str) The ID of the photo to fetch the favoriters list for.
		 * @param (int, optional) The page of results to return. If this argument is omitted, it defaults to 1.
		 * @param (int, optional) Number of usres to return per page. If this argument is omitted, it defaults to 10. The maximum allowed value is 50.
		 *
		 * @return List of people who have favorited a given photo.
		 * @author Aral Balkan
		 **/
		function photosGetFavorites($photoId, $page = NULL, $perPage = NULL)
		{
			$favorites = $this->api->photos_getFavorites($photoId, $page, $perPage);
			
			return $this->_getResult($favorites);
		}
		
		
		/**
		 * Get information about a photo. 
		 * The calling user must have permission to view the photo.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photos.getInfo.html
		 * 
		 * @param (str) The id of the photo to get information for.
		 * @param (str, optional) The secret for the photo. If the correct secret is passed then permissions checking is skipped. This enables the 'sharing' of individual photos by passing around the id and secret.
		 *
		 * @return Information about a photo. 
		 * @author Aral Balkan
		 **/
		function photosGetInfo($photoId, $secret = NULL)
		{
			$info = $this->api->photos_getInfo($photoId, $secret = NULL);
			
			return $this->_getResult($info);
		}
		
		
		/**
		 * Returns a list of your photos that are not part of any sets.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photos.getNotInSet.html
		 * 
		 * Requires read authentication.
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str, optional) Minimum upload date. Photos with an upload date greater than or equal to this value will be returned. The date should be in the form of a unix timestamp.
		 * @param (str, optional) Maximum upload date. Photos with an upload date less than or equal to this value will be returned. The date should be in the form of a unix timestamp.
		 * @param (str, optional) Minimum taken date. Photos with an taken date greater than or equal to this value will be returned. The date should be in the form of a mysql datetime.
		 * @param (str, optional) Maximum taken date. Photos with an taken date less than or equal to this value will be returned. The date should be in the form of a mysql datetime.
		 * @param (int, optional) Return photos only matching a certain privacy level. Valid values are: 1 public photos,	2 private photos visible to friends, 3 private photos visible to family, 4 private photos visible to friends & family, 5 completely private photos
		 * @param (str, optional) A comma-delimited list of extra information to fetch for each returned record. Currently supported fields are: license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo, tags, machine_tags.
		 * @param (int, optional) Number of photos to return per page. If this argument is omitted, it defaults to 100. The maximum allowed value is 500.
		 * @param (int, optional) The page of results to return. If this argument is omitted, it defaults to 1.
		 *
		 * @return List of your photos that are not part of any sets.
		 * @author Aral Balkan
		 **/
		function photosGetNotInSet($token, $minUploadDate = NULL, $maxUploadDate = NULL, $minTakenDate = NULL, $maxTakenDate = NULL, $privacyFilter = NULL, $extras = NULL, $perPage = NULL, $page = NULL)
		{
			$this->api->setToken($token);
			$photosNotInSet = $this->api->photos_getNotInSet($minUploadDate, $maxUploadDate, $minTakenDate, $maxTakenDate, $privacyFilter, $extras, $perPage, $page);
			
			return $this->_getResult($photosNotInSet);
		}
		
		
		/**
		 * Get permissions for a photo.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photos.getPerms.html
		 *
		 * Requires read authentication.
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str) The id of the photo to get permissions for. 
		 * 
		 * @return Permissions for a photo.
		 * @author Aral Balkan
		 **/
		function photosGetPerms($token, $photoId)
		{
			$this->api->setToken($token);
			
			$perms = $this->api->photos_getPerms($photoId);
			
			return $this->_getResult($perms);
		}
		
		
		/**
		 * Returns a list of the latest public photos uploaded to flickr.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photos.getRecent.html
		 * 
		 * Does not require authentication.
		 * 
		 * @param (str, optional) comma-delimited list of extra information to fetch for each returned record. Currently supported fields are: license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo, tags, machine_tags.
		 * @param (int, optional) Number of photos to return per page. If this argument is omitted, it defaults to 100. The maximum allowed value is 500.
		 * @param (int, optional) The page of results to return. If this argument is omitted, it defaults to 1.
		 *
		 * @return List of the latest public photos uploaded to flickr.
		 * @author Aral Balkan
		 **/
		function photosGetRecent($extras = NULL, $perPage = NULL, $page = NULL)
		{
			$recentPhotos = $this->api->photos_getRecent($extras, $perPage, $page);
			
			return $this->_getResult($recentPhotos);
		}
		
		
		/**
		 * Returns the available sizes for a photo. 
		 * The calling user must have permission to view the photo.
		 * 
		 * Official Flickr API documentation: 
		 * http://www.flickr.com/services/api/flickr.photos.getSizes.html
		 * 
		 * Does not require authentication.
		 * 
		 * @param (str) The id of the photo to fetch size information for.
		 *
		 * @return The available sizes for a photo. 
		 * @author Aral Balkan
		 **/
		function photosGetSizes($photoId)
		{
		    $sizes = $this->api->photos_getSizes($photoId);
		
			return $this->_getResult($sizes);		
		}
		
		
		/**
		 * Returns a list of your photos with no tags.
		 * 
		 * Official Flickr API documentation: 
		 * http://www.flickr.com/services/api/flickr.photos.getUntagged.html
		 * 
		 * Requires read authentication.
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str, optional) Minimum upload date. Photos with an upload date greater than or equal to this value will be returned. The date should be in the form of a unix timestamp.
		 * @param (str, optional) Maximum upload date. Photos with an upload date less than or equal to this value will be returned. The date should be in the form of a unix timestamp.
		 * @param (str, optional) Minimum taken date. Photos with an taken date greater than or equal to this value will be returned. The date should be in the form of a mysql datetime.
		 * @param (str, optional) Maximum taken date. Photos with an taken date less than or equal to this value will be returned. The date should be in the form of a mysql datetime.
		 * @param (int, optional) Return photos only matching a certain privacy level. Valid values are: 1 public photos, 2 private photos visible to friends,	3 private photos visible to family, 4 private photos visible to friends & family,	5 completely private photos
		 * @param (str, optional) A comma-delimited list of extra information to fetch for each returned record. Currently supported fields are: license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo, tags, machine_tags.
		 * @param (int, optional) Number of photos to return per page. If this argument is omitted, it defaults to 100. The maximum allowed value is 500.
		 * @param (int, optional) The page of results to return. If this argument is omitted, it defaults to 1.
		 *
		 * @return List of your photos with no tags.
		 * @author Aral Balkan
		 **/
		function photosGetUntagged($token, $minUploadDate = NULL, $maxUploadDate = NULL, $minTakenDate = NULL, $maxTakenDate = NULL, $privacyFilter = NULL, $extras = NULL, $perPage = NULL, $page = NULL)
		{
			$this->api->setToken($token);
			$untagged = $this->api->photos_getUntagged($minUploadDate, $maxUploadDate, $minTakenDate, $maxTakenDate, $privacyFilter, $extras, $perPage, $page);
			
			return $this->_getResult($untagged);
		}
		
		
		/**
		 * Returns a list of your geo-tagged photos.
		 * 
		 * Official Flickr API documentation: 
		 * http://www.flickr.com/services/api/flickr.photos.getWithGeoData.html
		 * 
		 * Requires read authentication.
		 *
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str, optional) Minimum upload date. Photos with an upload date greater than or equal to this value will be returned. The date should be in the form of a unix timestamp.
		 * @param (str, optional) Maximum upload date. Photos with an upload date less than or equal to this value will be returned. The date should be in the form of a unix timestamp.
		 * @param (str, optional) Minimum taken date. Photos with an taken date greater than or equal to this value will be returned. The date should be in the form of a mysql datetime.
		 * @param (str, optional) Maximum taken date. Photos with an taken date less than or equal to this value will be returned. The date should be in the form of a mysql datetime.
		 * @param (int, optional) Return photos only matching a certain privacy level. Valid values are: 1 public photos, 2 private photos visible to friends,	3 private photos visible to family, 4 private photos visible to friends & family,	5 completely private photos
		 * @param (str, optional) A comma-delimited list of extra information to fetch for each returned record. Currently supported fields are: license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo, tags, machine_tags.
		 * @param (int, optional) Number of photos to return per page. If this argument is omitted, it defaults to 100. The maximum allowed value is 500.
		 * @param (int, optional) The page of results to return. If this argument is omitted, it defaults to 1.
		 * 
		 * @return List of your geo-tagged photos.
		 * @author Aral Balkan
		 **/
		function photosGetWithGeoData($token, $minUploadDate = NULL, $maxUploadDate = NULL, $minTakenDate = NULL, $maxTakenDate = NULL, $privacyFilter = NULL, $sort = NULL, $extras = NULL, $perPage = NULL, $page = NULL)
		{				
			$this->api->setToken($token);

			// Create the args array. (The way PHPFlickr implemented this method
			// differs from the norm.
			$args = array('min_upload_date' => $minUploadDate, 'max_upload_date' => $maxUploadDate, 'min_taken_date' => $minTakenDate, 'max_taken_date' => $maxTakenDate, 'private_filter' => $privacyFilter, 'sort' => $sort, 'extras' => $extras, 'per_page' => $perPage, 'page' => $page);
			
	    	$photosWithGeoData = $this->api->photos_getWithGeoData($args);
	
			return $this->_getResult($photosWithGeoData);		
		}		
		
		
		/**
		 * Returns a list of your photos which haven't been geo-tagged.
		 * 
		 * Official Flickr API documentation: 
		 * http://www.flickr.com/services/api/flickr.photos.getWithoutGeoData.html
		 * 
		 * Requires read authentication.
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str, optional) Minimum upload date. Photos with an upload date greater than or equal to this value will be returned. The date should be in the form of a unix timestamp.
		 * @param (str, optional) Maximum upload date. Photos with an upload date less than or equal to this value will be returned. The date should be in the form of a unix timestamp.
		 * @param (str, optional) Minimum taken date. Photos with an taken date greater than or equal to this value will be returned. The date should be in the form of a mysql datetime.
		 * @param (str, optional) Maximum taken date. Photos with an taken date less than or equal to this value will be returned. The date should be in the form of a mysql datetime.
		 * @param (int, optional) Return photos only matching a certain privacy level. Valid values are: 1 public photos, 2 private photos visible to friends,	3 private photos visible to family, 4 private photos visible to friends & family,	5 completely private photos
		 * @param (str, optional) A comma-delimited list of extra information to fetch for each returned record. Currently supported fields are: license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo, tags, machine_tags.
		 * @param (int, optional) Number of photos to return per page. If this argument is omitted, it defaults to 100. The maximum allowed value is 500.
		 * @param (int, optional) The page of results to return. If this argument is omitted, it defaults to 1.
		 *
		 * @return List of your photos which haven't been geo-tagged.
		 * @author Aral Balkan
		 **/
		function photosGetWithoutGeoData($token, $minUploadDate = NULL, $maxUploadDate = NULL, $minTakenDate = NULL, $maxTakenDate = NULL, $privacyFilter = NULL, $sort = NULL, $extras = NULL, $perPage = NULL, $page = NULL)
		{
			$this->api->setToken($token);
			
			// Create the args array. (The way PHPFlickr implemented this method
			// differs from the norm.
			$args = array('min_upload_date' => $minUploadDate, 'max_upload_date' => $maxUploadDate, 'min_taken_date' => $minTakenDate, 'max_taken_date' => $maxTakenDate, 'private_filter' => $privacyFilter, 'sort' => $sort, 'extras' => $extras, 'per_page' => $perPage, 'page' => $page);
			
			$photosWithoutGeoData = $this->api->photos_getWithoutGeoData($args);
			
			return $this->_getResult($photosWithoutGeoData);
		}
		
		
		/**
		 * Return a list of your photos that have been recently created 
		 * or which have been recently modified. Recently modified may mean 
		 * that the photo's metadata (title, description, tags) may have 
		 * been changed or a comment has been added (or just modified somehow :-)
		 * 
		 * Official Flickr API documentation: 
		 * http://www.flickr.com/services/api/flickr.photos.recentlyUpdated.html
		 *
		 * Requires read authentication.
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str) A Unix timestamp indicating the date from which modifications should be compared.
		 * @param (str, optional) A comma-delimited list of extra information to fetch for each returned record. Currently supported fields are: license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo, tags, machine_tags.
		 * @param (int, optional) Number of photos to return per page. If this argument is omitted, it defaults to 100. The maximum allowed value is 500.
		 * @param (int, optional) The page of results to return. If this argument is omitted, it defaults to 1.
		 * 
		 * @return List of your photos that have been recently created 
		 * or which have been recently modified.
		 * @author Aral Balkan
		 **/
		function photosRecentlyUpdated($token, $minDate = NULL, $extras = NULL, $perPage = NULL, $page = NULL)
		{
			$this->api->setToken($token);
			
			$photos = $this->api->photos_recentlyUpdated($minDate, $extras, $perPage, $page);
			
			return $this->_getResult($photos);
		}
		
		
		/**
		 * Remove a tag from a photo.
		 * 
		 * Official Flickr API documentation: 
		 * http://www.flickr.com/services/api/flickr.photos.removeTag.html
		 * 
		 * Requires write authentication.
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str) The tag to remove from the photo. This parameter should contain a tag id, as returned by photosGetInfo().
		 *
		 * @return True on success, or error object.
		 * @author Aral Balkan
		 **/
		function photosRemoveTag($token, $tagId)
		{
			$this->api->setToken($token);
			
			$result = $this->api->photos_removeTag($tagId);

			return $this->_getResult($result);
		}
		
		
		/**
		 * Return a list of photos matching some criteria. Only photos visible 
		 * to the calling user will be returned. To return private or semi-private
		 *  photos, the caller must be authenticated with 'read' permissions, and 
		 * have permission to view the photos. 
		 * 
		 * Autentication is optional. Unauthenticated calls will only return 
		 * public photos.
		 *
		 * Official Flickr API documentation: 
		 * http://www.flickr.com/services/api/flickr.photos.search.html
		 * 
		 * @param (str, optional) The auth token that was returned by authGetToken().
		 * @param (str, optional) The NSID of the user who's photo to search. If this parameter isn't passed then everybody's public photos will be searched. A value of "me" will search against the calling user's photos for authenticated calls.
		 * @param (str, optional) A comma-delimited list of tags. Photos with one or more of the tags listed will be returned.
		 * @param (str, optional) Either 'any' for an OR combination of tags, or 'all' for an AND combination. Defaults to 'any' if not specified.
		 * @param (str, optional) A free text search. Photos who's title, description or tags contain the text will be returned.
		 * @param (str, optional) Minimum upload date. Photos with an upload date greater than or equal to this value will be returned. The date should be in the form of a unix timestamp.
		 * @param (str, optional) Maximum upload date. Photos with an upload date less than or equal to this value will be returned. The date should be in the form of a unix timestamp.
		 * @param (str, optional) Minimum taken date. Photos with an taken date greater than or equal to this value will be returned. The date should be in the form of a mysql datetime.
		 * @param (str, optional) Maximum taken date. Photos with an taken date less than or equal to this value will be returned. The date should be in the form of a mysql datetime.
		 * @param (str, optional) The license id for photos (for possible values see the flickr.photos.licenses.getInfo method). Multiple licenses may be comma-separated.
		 * @param (str, optional) The order in which to sort returned photos. Deafults to date-posted-desc. The possible values are: date-posted-asc, date-posted-desc, date-taken-asc, date-taken-desc, interestingness-desc, interestingness-asc, and relevance.
		 * @param (int, optional) Return photos only matching a certain privacy level. This only applies when making an authenticated call to view photos you own. Valid values are: 1 public photos, 2 private photos visible to friends, 3 private photos visible to family, 4 private photos visible to friends & family, 5 completely private photos
		 * @param (str, optional) A comma-delimited list of 4 values defining the Bounding Box of the area that will be searched. The 4 values represent the bottom-left corner of the box and the top-right corner, minimum_longitude, minimum_latitude, maximum_longitude, maximum_latitude. Longitude has a range of -180 to 180 , latitude of -90 to 90. Defaults to -180, -90, 180, 90 if not specified. Unlike standard photo queries, geo (or bounding box) queries will only return 250 results per page. Geo queries require some sort of limiting agent in order to prevent the database from crying. This is basically like the check against "parameterless searches" for queries without a geo component. A tag, for instance, is considered a limiting agent as are user defined min_date_taken and min_date_upload parameters — If no limiting factor is passed we return only photos added in the last 12 hours (though we may extend the limit in the future).
		 * @param (int, optional) Recorded accuracy level of the location information. Current range is 1-16:	World level is 1, Country is ~3, Region is ~6, City is ~11, Street is ~16, Defaults to maximum value if not specified.
		 * @param (int, optional) Safe search setting: 1 for safe. 2 for moderate. 3 for restricted.	(Please note: Un-authed calls can only see Safe content.)
		 * @param (int, optional) Content Type setting:	1 for photos only. 2 for screenshots only. 3 for 'other' only. 4 for photos and screenshots. 5 for screenshots and 'other'. 6 for photos and 'other'. 7 for photos, screenshots, and 'other' (all).
		 * @param (str, optional) Aside from passing in a fully formed machine tag, there is a special syntax for searching on specific properties: Find photos using the 'dc' namespace : "machine_tags" => "dc:". Find photos with a title in the 'dc' namespace : "machine_tags" => "dc:title=".	Find photos titled "mr. camera" in the 'dc' namespace : "machine_tags" => "dc:title=\"mr. camera\". Find photos whose value is "mr. camera" : "machine_tags" => "*:*=\"mr. camera\"".	Find photos that have a title, in any namespace : "machine_tags" => "*:title=". Find photos that have a title, in any namespace, whose value is "mr. camera" : "machine_tags" => "*:title=\"mr. camera\"". Find photos, in the 'dc' namespace whose value is "mr. camera" : "machine_tags" => "dc:*=\"mr. camera\"". Multiple machine tags may be queried by passing a comma-separated list. The number of machine tags you can pass in a single query depends on the tag mode (AND or OR) that you are querying with. "AND" queries are limited to (16) machine tags. "OR" queries are limited to (8).
		 * @param (str, required if searching for machine tags)	Either 'any' for an OR combination of tags, or 'all' for an AND combination. Defaults to 'any' if not specified.
		 * @param (str, optional) The id of a group who's pool to search. If specified, only matching photos posted to the group's pool will be returned.
		 * @param (str, optional) A comma-delimited list of extra information to fetch for each returned record. Currently supported fields are: license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo, tags, machine_tags.
		 * @param (int, optional) Number of photos to return per page. If this argument is omitted, it defaults to 100. The maximum allowed value is 500.
		 * @param (int, optional) The page of results to return. If this argument is omitted, it defaults to 1.
		 * 
		 * @return List of photos matching the criteria.
		 * @author Aral Balkan
		 **/
		function photosSearch($token = NULL, $userId = NULL, $tags = NULL, $tagMode = NULL, $text = NULL, $minUploadDate = NULL, $maxUploadDate = NULL, $minTakenDate = NULL, $maxTakenDate = NULL, $license = NULL, $sort = NULL, $privacyFilter = NULL, $bbox = NULL, $accuracy = NULL, $safeSearch = NULL, $contentType = NULL, $machineTags = NULL, $machineTagMode = NULL, $groupId = NULL, $extras = NULL, $perPage = NULL, $page = NULL)
		{
			if ($token !== NULL)
			{
				$this->api->setToken($token);
			}
			
			$args = array('user_id' => $userId, 'tags' => $tags, 'tag_mode' => $tagMode, 'text' => $text, 'min_upload_date' => $minUploadDate, 'max_upload_date' => $maxUploadDate, 'min_taken_date' => $minTakenDate, 'max_taken_date' => $maxTakenDate, 'license' => $license, 'sort' => $sort, 'privacy_filter' => $privacyFilter, 'bbox' => $bbox, 'accuracy' => $accuracy, 'safe_search' => $safeSearch, 'content_type' => $contentType, 'machine_tags' => $machineTags, 'machine_tag_mode' => $machineTagMode, 'group_id' => $groupId, 'extras' => $extras, 'per_page' => $perPage, 'page' => $page);
			
		    $result = $this->api->photos_search($args);
		
			return $this->_getResult($result);
		}
		
		/**
		 * Set the content type of a photo.
		 * 
		 * Requires write authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photos.setContentType.html
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str) The id of the photo to set the content type of.
		 * @param (int) The content type of the photo. Must be one of: 1 for Photo, 2 for Screenshot, and 3 for Other.
		 *
		 * @return Flickr response.
		 * @author Aral Balkan
		 **/
		function photosSetContentType($token, $photoId, $contentType)
		{
			$this->api->setToken($token);
			
			$args = array('photo_id' => $photoId, 'content_type' => $contentType);
			
			$this->api->request("flickr.photos.setContentType", $args);
		    
			return $this->_getResult($this->api->parsed_response);
		}
		
		
		/**
		 * Set one or both of the dates for a photo. Dates documentation is at http://www.flickr.com/services/api/misc.dates.html
		 * 
		 * Requires write authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photos.setDates.html 
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str) The id of the photo to edit dates for.
		 * @param (str) The date the photo was uploaded to flickr (see the dates documentation)
		 * @param (str) The date the photo was taken (see the dates documentation)
		 * @param (str) The granularity of the date the photo was taken (see the dates documentation)
		 *
		 * @return void
		 * @author Aral Balkan
		 **/
		function photosSetDates ($token, $photoId, $datePosted = NULL, $dateTaken = NULL, $dateTakenGranularity = NULL)
		{
			$this->api->setToken($token);
			
			$result = $this->api->photos_setDates($photoId, $datePosted, $dateTaken, $dateTakenGranularity);
			
			return $this->_getResult($result);			
		}
		
		
		/**
		 * Set the meta information for a photo.
		 * 
		 * Requires write authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photos.setMeta.html
		 *
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str) The id of the photo to set information for.
		 * @param (str) The title for the photo.
		 * @param (str) The description for the photo.
		 * 
		 * @return True or error object.
		 * @author Aral Balkan
		 **/
		function photosSetMeta ($token, $photoId, $title, $description)
		{
			$this->api->setToken($token);
			
			$result = $this->api->photos_setMeta($photoId, $title, $description);
			
			return $this->_getResult($result);
		}
		
		
		/**
		 * Set permissions for a photo.
		 *
		 * Requires write authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photos.setPerms.html
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str) The id of the photo to set permissions for.
		 * @param (int) 1 to set the photo to public, 0 to set it to private.
		 * @param (int) 1 to make the photo visible to friends when private, 0 to not.
		 * @param (int) 1 to make the photo visible to family when private, 0 to not.
		 * @param (int) who can add comments to the photo and it's notes. one of: 0: nobody, 1: friends & family, 2: contacts, 3: everybody.
		 * @param (int) who can add notes and tags to the photo. one of 0: nobody / just the owner, 1: friends & family, 2: contacts, 3: everybody.
		 * 
		 * @return True or error object. 
		 * @author Aral Balkan
		 **/
		function photosSetPerms ($token, $photoId, $isPublic, $isFriend, $isFamily, $permComment, $permAddmeta)
		{
			$this->api->setToken($token);			
			
			$result = $this->api->photos_setPerms($photoId, $isPublic, $isFriend, $isFamily, $permComment, $permAddmeta);
			
			return $this->_getResult($result);
		}
		
		/**
		 * Set the safety level of a photo.
		 * 
		 * Requires write authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photos.setSafetyLevel.html
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str) The id of the photo to set the adultness of.
		 * @param (int, optional) The safety level of the photo. Must be one of: 1 for Safe, 2 for Moderate, and 3 for Restricted.
		 * @param (int, optional) Whether or not to additionally hide the photo from public searches. Must be either 1 for Yes or 0 for No.
		 *
		 * @return Flickr response.
		 * @author Aral Balkan
		 **/
		function photosSetSafetyLevel($token, $photoId, $safetyLevel, $hidden)
		{
			$this->api->setToken($token);
			
			$args = array('photo_id' => $photoId, 'safety_level' => $safetyLevel, 'hidden' => $hidden);
			
			$this->api->request("flickr.photos.setSafetyLevel", $args);
		    
			return $this->_getResult($this->api->parsed_response);
		}		
		
		
		/**
		 * Set the tags for a photo.
		 * 
		 * Requires write authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photos.setTags.html
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str) The id of the photo to set tags for.
		 * @param (str) All tags for the photo (as a single space-delimited string).
		 *
		 * @return Flickr response.
		 * @author Aral Balkan
		 **/
		function photosSetTags ($token, $photoId, $tags)
		{
			$this->api->setToken($token);
			
			$result = $this->api->photos_setTags($photoId, $tags);
			
			return $this->_getResult($result);
		}
		
		
		//
		// Photos Comments methods
		//
		
		
		/**
		 * Add comment to a photo as the currently authenticated user.
		 * 
		 * Requires write authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photos.comments.addComment.html
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str) The id of the photo to add a comment to.
		 * @param (str) Text of the comment
		 *
		 * @return Comment id of the posted comment.
		 * @author Aral Balkan
		 **/
		function photosCommentsAddComment ($token, $photoId, $commentText)
		{
			$this->api->setToken($token);
			
			$result = $this->api->photos_comments_addComment($photoId, $commentText);
			
			return $this->_getResult($result);
		}
		
		
		/**
		 * Delete a comment as the currently authenticated user.
		 * 
		 * Requires write authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photos.comments.addComment.html
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str) The id of the comment to edit.
		 *
		 * @return True or error object.
		 * @author Aral Balkan
		 **/
		function photosCommentsDeleteComment ($token, $commentId)
		{
			$this->api->setToken($token);
			
			$result = $this->api->photos_comments_deleteComment($commentId);
			
			return $this->_getResult($result);
		}
				

		/**
		 * Edit the text of a comment as the currently authenticated user.
		 * 
		 * Requires write authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photos.comments.editComment.html
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str) The id of the comment to edit.
		 * @param (str) Update the comment to this text.
		 *
		 * @return True or error object.
		 * @author Aral Balkan
		 **/
		function photosCommentsEditComment ($token, $commentId, $commentText)
		{
			$this->api->setToken($token);
			
			$result = $this->api->photos_comments_editComment($commentId, $commentText);
			
			return $this->_getResult($result);
		}
		
		
		/**
		 * Returns the comments for a photo.
		 * 
		 * Does not require authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photos.comments.getList.html
		 * 
		 * @param (str) The id of the photo to fetch comments for.
		 *
		 * @return Comments for the photo or error object.
		 * @author Aral Balkan
		 **/
		function photosCommentsGetList ($photoId)
		{
			$result = $this->api->photos_comments_getList($photoId);
			
			return $this->_getResult($result);
		}		


		//
		// Photos Geo methods
		//
		
		/**
		 * Get the geo data (latitude and longitude and the accuracy level) for a photo.
		 * 
		 * Does not require authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photos.geo.getLocation.html
		 * 
		 * @param (str) The id of the photo you want to retrieve location data for.
		 *
		 * @return Geo data for photo or error object.
		 * @author Aral Balkan
		 **/
		function photosGeoGetLocation ($photoId)
		{
			$result = $this->api->photos_geo_getLocation($photoId);
			
			return $this->_getResult($result);
		}		
		
		/**
		 * Get permissions for who may view geo data for a photo.
		 * 
		 * Requires read authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photos.geo.getPerms.html
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str) The id of the photo you want to retrieve location data for.
		 *
		 * @return Flickr response.
		 * @author Aral Balkan
		 **/
		function photosGeoGetPerms ($token, $photoId)
		{
			$this->api->setToken($token);			
			
			$result = $this->api->photos_geo_getPerms($photoId);
			
			return $this->_getResult($result);
		}		
		
		
		/**
		 * Removes the geo data associated with a photo.
		 * 
		 * Requires write authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photos.geo.removeLocation.html
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str) The id of the photo you want to remove location data for.
		 *
		 * @return Flickr response.
		 * @author Aral Balkan
		 **/
		function photosGeoRemoveLocation ($token, $photoId)
		{
			$this->api->setToken($token);			
			
			$result = $this->api->photos_geo_removeLocation($photoId);
			
			return $this->_getResult($result);
		}		

		
		/**
		 * 	Sets the geo data (latitude and longitude and, optionally, the accuracy level) for a photo. Before users may assign location data to a photo they must define who, by default, may view that information. Users can edit this preference at http://www.flickr.com/account/geo/privacy/. If a user has not set this preference, the API method will return an error.
		 * 
		 * Requires write authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photos.geo.setLocation.html
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str) The id of the photo you want to set location data for.
		 * @param (str) The latitude whose valid range is -90 to 90. Anything more than 6 decimal places will be truncated.
		 * @param (str) The longitude whose valid range is -180 to 180. Anything more than 6 decimal places will be truncated.
		 * @param (str) Recorded accuracy level of the location information. World level is 1, Country is ~3, Region ~6, City ~11, Street ~16. Current range is 1-16. Defaults to 16 if not specified.
		 * 
		 * @return Flickr response.
		 * @author Aral Balkan
		 **/
		function photosGeoSetLocation ($token, $photoId, $lat, $lon, $accuracy = NULL)
		{
			$this->api->setToken($token);			
			
			$result = $this->api->photos_geo_setLocation($photoId, $lat, $lon, $accuracy);
			
			return $this->_getResult($result);
		}
		

		/**
		 * Set the permission for who may view the geo data associated with a photo.
		 * 
		 * Requires write authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photos.geo.setPerms.html
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str) The id of the photo to get permissions for.
		 * @param (int) 1 to set viewing permissions for the photo's location data to public, 0 to set it to private.
		 * @param (int) 1 to set viewing permissions for the photo's location data to contacts, 0 to set it to private.
		 * @param (int) 1 to set viewing permissions for the photo's location data to friends, 0 to set it to private.
		 * @param (int) 1 to set viewing permissions for the photo's location data to family, 0 to set it to private.
		 *
		 * @return Flickr response.
		 * @author Aral Balkan
		 **/
		function photosGeoSetPerms ($token, $photoId, $isPublic, $isContact, $isFriend, $isFamily)
		{
			$this->api->setToken($token);			
			
			$result = $this->api->photos_geo_setPerms($photoId, $isPublic, $isContact, $isFriend, $isFamily);
			
			return $this->_getResult($result);
		}		


		//
		// Photos Licenses methods.
		//
		
		
		/**
		 * Fetches a list of available photo licenses for Flickr.
		 * 
		 * Does not require authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photos.licenses.getInfo.html
		 * 
		 * @return List of available photo licenses for Flickr.
		 * @author Aral Balkan
		 **/
		function photosLicensesGetInfo ()
		{
			$result = $this->api->photos_licenses_getInfo();
			
			return $this->_getResult($result);
		}		
		
		
		/**
		 * Sets the license for a photo.
		 * 
		 * Requires write authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photos.licenses.setLicense.html
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str) The photo to update the license for.
		 * @param (int) The id of the license to apply, or 0 (zero) to remove the current license. Get a list of license ids using the photosLicensesGetInfo() method.
		 *
		 * @return Flickr response.
		 * @author Aral Balkan
		 **/
		function photosLicensesSetLicense ($token, $photoId, $licenseId)
		{
			$this->api->setToken($token);			
			
			$result = $this->api->photos_licenses_setLicense($photoId, $licenseId);
			
			return $this->_getResult($result);
		}		
		
		
		//
		// Photos Notes methods.
		//
		
		/**
		 * Add a note to a photo. Coordinates and sizes are in pixels, based on the 500px image size shown on individual photo pages.
		 * 
		 * Requires write authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photos.notes.add.html
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str) The id of the photo to add a note to.
		 * @param (int) The left coordinate of the note.
		 * @param (int) The top coordinate of the note.
		 * @param (int) The width of the note.
		 * @param (int) The height of the note.
		 * @param (str) The description of the note.
		 *
		 * @return The ID of the added note.
		 * @author Aral Balkan
		 **/
		function photosNotesAdd ($token, $photoId, $noteX, $noteY, $noteW, $noteH, $noteText)
		{
			$this->api->setToken($token);			
			
			$result = $this->api->photos_notes_add($photoId, $noteX, $noteY, $noteW, $noteH, $noteText);
			
			return $this->_getResult($result);
		}
				
		
		/**
		 * Delete a note from a photo.
		 * 
		 * Requires write authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photos.notes.delete.html
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str) The id of the note to delete.
		 *
		 * @return True or error object.
		 * @author Aral Balkan
		 **/
		function photosNotesDelete ($token, $noteId)
		{
			$this->api->setToken($token);			
			
			$result = $this->api->photos_notes_delete($noteId);
			
			return $this->_getResult($result);
		}
				

		/**
		 * Edit a note on a photo. Coordinates and sizes are in pixels, based on the 500px image size shown on individual photo pages.
		 * 
		 * Requires write authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photos.notes.edit.html
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str) The id of the note to edit.
		 * @param (int) The left coordinate of the note.
		 * @param (int) The top coordinate of the note.
		 * @param (int) The width of the note.
		 * @param (int) The height of the note.
		 * @param (str) The description of the note.
		 *
		 * @return True or error object.
		 * @author Aral Balkan
		 **/
		function photosNotesEdit ($token, $noteId, $noteX, $noteY, $noteW, $noteH, $noteText)
		{
			$this->api->setToken($token);			
			
			$result = $this->api->photos_notes_edit($noteId, $noteX, $noteY, $noteW, $noteH, $noteText);
			
			return $this->_getResult($result);
		}


		//
		// Photos transform methods.
		//
		
		/**
		 * Rotate a photo.
		 * 
		 * Requires write authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photos.transform.rotate.html
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str) The id of the photo to rotate.
		 * @param (int) The amount of degrees by which to rotate the photo (clockwise) from it's current orientation. Valid values are 90, 180 and 270.
		 *
		 * @return True or error object.
		 * @author Aral Balkan
		 **/
		function photosTransformRotate ($token, $photoId, $degrees)
		{
			$this->api->setToken($token);			
			
			$result = $this->api->photos_transform_rotate($photoId, $degrees);
			
			return $this->_getResult($result);
		}		
		
		
		// 
		// Photos Upload methods.
		//
		
		/**
		 * Checks the status of one or more asynchronous photo upload tickets.
		 * 
		 * To actually upload a photo to Flickr, use the Flickr Upload script at
		 * swxformat.org. For an example of how to do this, see the Flickr Upload
		 * example in the flash/examples folder. (To use this method, set the 
		 * upload method to async=true when using the Flickr Upload script.)
		 * 
		 * Does not require authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photos.upload.checkTickets.html
		 * 
		 * @param (str) A comma-delimited list of ticket ids
		 *
		 * @return Completion status of inquired ticket ids.
		 * @author Aral Balkan
		 **/
		function photosUploadCheckTickets ($tickets)
		{
			$result = $this->api->photos_upload_checkTickets($tickets);
			
			return $this->_getResult($result);
		}		
		
		
		//
		// Photosets methods.
		//
		
		/**
		 * Add a photo to the end of an existing photoset.
		 * 
		 * Requires write authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photosets.addPhoto.html
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str) The id of the photoset to add a photo to.
		 * @param (str) The id of the photo to add to the set.
		 *
		 * @return True or error object.
		 * @author Aral Balkan
		 **/
		function photosetsAddPhoto ($token, $photosetId, $photoId)
		{
			$this->api->setToken($token);			
			
			$result = $this->api->photosets_addPhoto($photosetId, $photoId);
			
			return $this->_getResult($result);
		}
		
		
		/**
		 * Create a new photoset for the calling user.
		 * 
		 * Requires write authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photosets.create.html
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str) A title for the photoset.
		 * @param (str) The id of the photo to represent this set. The photo must belong to the calling user.
		 * @param (optional, str) A description of the photoset. May contain limited html.
		 *
		 * @return Object with ID and Url of created photoset.
		 * @author Aral Balkan
		 **/
		function photosetsCreate ($token, $title, $primaryPhotoId, $description = NULL)
		{
			$this->api->setToken($token);			
			
			$result = $this->api->photosets_create($title, $description, $primaryPhotoId);
			
			return $this->_getResult($result);
		}		
		
		
		/**
		 * Delete a photoset.
		 * 
		 * Requires write authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photosets.delete.html
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str) The id of the photoset to delete. It must be owned by the calling user.
		 *
		 * @return True or error object.
		 * @author Aral Balkan
		 **/
		function photosetsDelete ($token, $photosetId)
		{
			$this->api->setToken($token);			
			
			$result = $this->api->photosets_delete($photosetId);
			
			return $this->_getResult($result);
		}		


		/**
		 * Modify the meta-data for a photoset.
		 * 
		 * Requires write authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photosets.editMeta.html
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str) The id of the photoset to modify.
		 * @param (str) The new title for the photoset.
		 * @param (optional, str) A description of the photoset. May contain limited html.
		 *
		 * @return True or error object.
		 * @author Aral Balkan
		 **/
		function photosetsEditMeta ($token, $photosetId, $title, $description = NULL)
		{
			$this->api->setToken($token);			
			
			$result = $this->api->photosets_editMeta($photosetId, $title, $description);
			
			return $this->_getResult($result);
		}		
		
		
		/**
		 * Modify the photos in a photoset. Use this method to add, remove and re-order photos.
		 * 
		 * Requires write authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photosets.editPhotos.html
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str) The id of the photoset to modify. The photoset must belong to the calling user.
		 * @param (str) The id of the photo to use as the 'primary' photo for the set. This id must also be passed along in photo_ids list argument.
		 * @param (str) A comma-delimited list of photo ids to include in the set. They will appear in the set in the order sent. This list must contain the primary photo id. All photos must belong to the owner of the set. This list of photos replaces the existing list. Call flickr.photosets.addPhoto to append a photo to a set.
		 *
		 * @return True or error object.
		 * @author Aral Balkan
		 **/
		function photosetsEditPhotos ($token, $photosetId, $primaryPhotoId, $photoIds)
		{
			$this->api->setToken($token);			
			
			$result = $this->api->photosets_editPhotos($photosetId, $primaryPhotoId, $photoIds);
			
			return $this->_getResult($result);
		}
		
		
		/**
		 * Returns next and previous photos for a photo in a set.
		 * 
		 * Does not require authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photosets.getContext.html
		 * 
		 * @param (str) The id of the photo to fetch the context for.
		 * @param (str) The id of the photoset for which to fetch the photo's context.
		 *
		 * @return Next and previous photos.
		 * @author Aral Balkan
		 **/
		function photosetsGetContext ($photoId, $photosetId)
		{
			$result = $this->api->photosets_getContext($photoId, $photosetId);
			
			return $this->_getResult($result);
		}
		
			
		/**
		 * Gets information about a photoset.
		 * 
		 * Does not require authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photosets.getInfo.html
		 * 
		 * @param (str) The ID of the photoset to fetch information for.
		 *
		 * @return Photoset information.
		 * @author Aral Balkan
		 **/
		function photosetsGetInfo ($photosetId)
		{
			$result = $this->api->photosets_getInfo($photosetId);
			
			return $this->_getResult($result);
		}			
					
					
		/**
		 * Returns the photosets belonging to the specified user.
		 * 
		 * Either provide a token or the NSID of the user you want the lists for.
		 * 
		 * Does not require authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photosets.getList.html
		 * 
		 * @param (optional, str) The auth token that was returned by authGetToken().
		 * @param (optional, str) The NSID of the user to get a photoset list for. If none is specified, the calling user is assumed.
		 *
		 * @return Photosets belonging to the specified user.
		 * @author Aral Balkan
		 **/
		function photosetsGetList ($token = NULL, $userId = NULL)
		{
			if (isset($token))
			{
				$this->api->setToken($token);
			}
			
			$result = $this->api->photosets_getList($userId);
			
			return $this->_getResult($result);
		}			
		
		
		/**
		 * Get the list of photos in a set.
		 * 
		 * Does not require authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photosets.getPhotos.html
		 * 
		 * @param (str) The id of the photoset to return the photos for.
		 * @param (optional, str) A comma-delimited list of extra information to fetch for each returned record. Currently supported fields are: license, date_upload, date_taken, owner_name, icon_server, original_format, last_update.
		 * @param (optional, int) Return photos only matching a certain privacy level. This only applies when making an authenticated call to view a photoset you own. Valid values are: 1 public photos, 2 private photos visible to friends, 3 private photos visible to family, 4 private photos visible to friends & family, 5 completely private photos.
		 * @param (optional, int) Number of photos to return per page. If this argument is omitted, it defaults to 500. The maximum allowed value is 500.
		 * @param (optional, int) The page of results to return. If this argument is omitted, it defaults to 1.
		 * 		 
		 * @return List of photos in a set.
		 * @author Aral Balkan
		 **/
		function photosetsGetPhotos ($photosetId, $extras = NULL, $privacyFilter = NULL, $perPage = NULL, $page = NULL)
		{
			$result = $this->api->photosets_getPhotos($photosetId, $extras, $privacyFilter, $perPage, $page);
			
			return $this->_getResult($result);
		}			


		/**
		 * Set the order of photosets for the calling user.
		 * 
		 * (Note: This method doesn't appear to work reliably for me; tried it
		 * with Yahoo!'s own service explorer too.)
		 * 
		 * Requires write authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photosets.orderSets.html
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str) A comma delimited list of photoset IDs, ordered with the set to show first, first in the list. Any set IDs not given in the list will be set to appear at the end of the list, ordered by their IDs.
 		 *
		 * @return True or error object.
		 * @author Aral Balkan
		 **/
		function photosetsOrderSets ($token, $photosetIds)
		{
			$this->api->setToken($token);			
			
			$result = $this->api->photosets_orderSets($photosetIds);
			
			return $this->_getResult($result);
		}
		
		
		/**
		 * Remove a photo from a photoset.
		 * 
		 * Requires write authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photosets.removePhoto.html
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str) The id of the photoset to remove a photo from.
		 * @param (str) The id of the photo to remove from the set.
 		 *
		 * @return True or error object.
		 * @author Aral Balkan
		 **/
		function photosetsRemovePhoto ($token, $photosetId, $photoId)
		{
			$this->api->setToken($token);			
			
			$result = $this->api->photosets_removePhoto($photosetId, $photoId);
			
			return $this->_getResult($result);
		}
		
		
		//
		// Photosets Comments methods.
		//
		
		/**
		 * Add a comment to a photoset.
		 * 
		 * Requires write authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photosets.comments.addComment.html
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str) The id of the photoset to add a comment to.
		 * @param (str) Text of the comment.
 		 *
		 * @return Id of the added comment or error object.
		 * @author Aral Balkan
		 **/
		function photosetsCommentsAddComment ($token, $photosetId, $commentText)
		{
			$this->api->setToken($token);			
			
			$result = $this->api->photosets_comments_addComment($photosetId, $commentText);
			
			return $this->_getResult($result);
		}		
		
		
		/**
		 * Delete a photoset comment as the currently authenticated user.
		 * 
		 * Requires write authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photosets.comments.deleteComment.html
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str) The id of the comment to delete from a photoset.
 		 *
		 * @return True or error object.
		 * @author Aral Balkan
		 **/
		function photosetsCommentsDeleteComment ($token, $commentId)
		{
			$this->api->setToken($token);			
			
			$result = $this->api->photosets_comments_deleteComment($commentId);
			
			return $this->_getResult($result);
		}		
		
		
		/**
		 * Edit the text of a comment as the currently authenticated user.
		 * 
		 * Requires write authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photosets.comments.editComment.html
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (str) The id of the comment to edit.
		 * @param (str) Update the comment to this text.
 		 *
		 * @return True or error object.
		 * @author Aral Balkan
		 **/
		function photosetsCommentsEditComment ($token, $commentId, $commentText)
		{
			$this->api->setToken($token);			
			
			$result = $this->api->photosets_comments_editComment($commentId, $commentText);
			
			return $this->_getResult($result);
		}		
		
		/**
		 * Returns the comments for a photoset.
		 * 
		 * Does not require authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.photosets.comments.getList.html
		 * 
		 * @param (str) The id of the photoset to fetch comments for.
 		 *
		 * @return True or error object.
		 * @author Aral Balkan
		 **/
		function photosetsCommentsGetList ($photosetId)
		{
			$result = $this->api->photosets_comments_getList($photosetId);
			
			return $this->_getResult($result);
		}		

		
		//
		// Prefs methods
		//
		
		/**
		 * Returns the default content type preference for the user.
		 * 
		 * Requires read authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.prefs.getContentType.html
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
 		 *
		 * @return Default content type preference for the user.
		 * @author Aral Balkan
		 **/
		function prefsGetContentType ($token)
		{
			$this->api->setToken($token);			
			
			$this->api->request("flickr.prefs.getContentType", array());
		    
			return $this->_getResult($this->api->parsed_response);
			
			return $this->_getResult($result);
		}		

		
		/**
		 * Returns the default hidden preference for the user.
		 * 
		 * Requires read authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.prefs.getHidden.html
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
 		 *
		 * @return Default hidden preference for the user.
		
		 * @author Aral Balkan
		 **/
		function prefsGetHidden ($token)
		{
			$this->api->setToken($token);			
			
			$this->api->request("flickr.prefs.getHidden", array());
		    
			return $this->_getResult($this->api->parsed_response);
			
			return $this->_getResult($result);
		}
		
		
		/**
		 * Returns the default safety level preference for the user.
		 * 
		 * Requires read authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.prefs.getSafetyLevel.html
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
 		 *
		 * @return Default safety level preference for the user.
		
		 * @author Aral Balkan
		 **/
		function prefsGetSafetyLevel ($token)
		{
			$this->api->setToken($token);			
			
			$this->api->request("flickr.prefs.getSafetyLevel", array());
		    
			return $this->_getResult($this->api->parsed_response);
		}
		
		
		// 
		// Reflection methods.
		//
		
		/**
		 * Returns information for a given flickr API method.
		 * 
		 * Does not require authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.reflection.getMethodInfo.html
		 * 
		 * @param (str) The name of the method to fetch information for.
 		 *
		 * @return Method info or error object.
		 * @author Aral Balkan
		 **/
		function reflectionGetMethodInfo ($methodName)
		{
			$result = $this->api->reflection_getMethodInfo($methodName);
			
			return $this->_getResult($result);
		}		


		/**
		 * Returns a list of available flickr API methods.
		 * 
		 * Does not require authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.reflection.getMethods.html
 		 *
		 * @return List of methods.
		 * @author Aral Balkan
		 **/
		function reflectionGetMethods ()
		{
			$result = $this->api->reflection_getMethods();
			
			return $this->_getResult($result);
		}		
				
				
		//
		// Tags methods.
		//
		
		
		/**
		 * Returns a list of hot tags for the given period.
		 * 
		 * Does not require authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.tags.getHotList.html
		 * 
		 * @param (optional, str) The period for which to fetch hot tags. Valid values are day and week (defaults to day).
		 * @param (optional, int) The number of tags to return. Defaults to 20. Maximum allowed value is 200.
 		 *
		 * @return List of hot tags.
		 * @author Aral Balkan
		 **/
		function tagsGetHotList($period = NULL, $count = NULL)
		{
			$result = $this->api->tags_getHotList($period, $count);
			
			return $this->_getResult($result);
		}				
		
		
		/**
		 * Get the tag list for a given photo.
		 * 
		 * Does not require authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.tags.getListPhoto.html
		 * 
		 * @param (str) The id of the photo to return tags for.
 		 *
		 * @return List of tags for given photo.
		 * @author Aral Balkan
		 **/
		function tagsGetListPhoto($photoId)
		{
			$result = $this->api->tags_getListPhoto($photoId);
			
			return $this->_getResult($result);
		}		
		
		
		/**
		 * Get the tag list for a given user (or the currently logged in user).
		 * 
		 * Does not require authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.tags.getListUser.html
		 * 
		 * @param (optional, str) The auth token that was returned by authGetToken().
		 * @param (optional, str) The NSID of the user to fetch the tag list for. If this argument is not specified, the currently logged in user (if any) is assumed.
 		 *
		 * @return Tag list for a given user.
		 * @author Aral Balkan
		 **/
		function tagsGetListUser($token = NULL, $userId = NULL)
		{
			if (isset($token))
			{
				$this->api->setToken($token);
			}
			
			$result = $this->api->tags_getListUser($userId);
			
			return $this->_getResult($result);
		}	
			

		/**
		 * Get the popular tags for a given user (or the currently logged in user).
		 * 
		 * Does not require authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.tags.getListUserPopular.html
		 * 
		 * @param (optional, str) The auth token that was returned by authGetToken().
		 * @param (optional, str) The NSID of the user to fetch the tag list for. If this argument is not specified, the currently logged in user (if any) is assumed.
		 * @param (optional, int) Number of popular tags to return. defaults to 10 when this argument is not present.
 		 *
		 * @return Popular tag list for a given user.
		 * @author Aral Balkan
		 **/
		function tagsGetListUserPopular($token = NULL, $userId = NULL, $count = NULL)
		{
			if (isset($token))
			{
				$this->api->setToken($token);
			}

			$result = $this->api->tags_getListUserPopular($userId, $count);
			
			return $this->_getResult($result);
		}		


		/**
		 * Get the raw versions of a given tag (or all tags) for the currently logged-in user.
		 * 
		 * Does not require authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.tags.getListUserRaw.html
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
		 * @param (optional, str) The tag you want to retrieve all raw versions for.
 		 *
		 * @return Raw versions of a given tag (or all tags).
		 * @author Aral Balkan
		 **/
		function tagsGetListUserRaw($token, $tag = NULL)
		{
			$this->api->setToken($token);

			$result = $this->api->tags_getListUserRaw($tag);
			
			return $this->_getResult($result);
		}		


		/**
		 * 	Returns a list of tags 'related' to the given tag, based on clustered usage analysis.
		 * 
		 * Does not require authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.tags.getRelated.html
		 * 
		 * @param (str) The tag to fetch related tags for.
 		 *
		 * @return List of tags 'related' to the given tag.
		 * @author Aral Balkan
		 **/
		function tagsGetRelated($tag)
		{
			$result = $this->api->tags_getRelated($tag);
			
			return $this->_getResult($result);
		}
		
		
		//
		// Test methods.
		//
		
		
		/**
		 * 	A testing method which echos all parameters back in the response.
		 * 
		 * Does not require authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.test.echo.html
		 * 
		 * @param (any) Argument to echo.
 		 *
		 * @return Echo.
		 * @author Aral Balkan
		 **/
		function testEcho($arg)
		{
			$result = $this->api->test_echo($arg);
			
			return $this->_getResult($result);
		}
		
		
		/**
		 * A testing method which checks if the caller is logged in then returns their username.
		 * 
		 * Requires read authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.test.login.html
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
 		 *
		 * @return Username or error.
		 * @author Aral Balkan
		 **/
		function testLogin($token)
		{
			$this->api->setToken($token);

			$result = $this->api->test_login();
			
			return $this->_getResult($result);
		}
		
		
		/**
		 * Null test.
		 * 
		 * Not really sure what this does. When tested here and in the official
		 * Flickr API Explorer, it returns the following result when successful:
		 * "Method "flickr.test.null" not handled by library".
		 * 
		 * Requires read authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.test.null.html
		 * 
		 * @param (str) The auth token that was returned by authGetToken().
 		 *
		 * @return Flickr response.
		 * @author Aral Balkan
		 **/
		function testNull($token)
		{
			$this->api->setToken($token);

			$this->api->request("flickr.test.null", array());
		    
			return $this->_getResult($this->api->parsed_response);
		}		
		
		
		//
		// URLS methods.
		//
		
		/**
		 * Returns the url to a group's page.
		 * 
		 * Does not require authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.urls.getGroup.html
		 * 
		 * @param (str) The NSID of the group to fetch the url for.
 		 *
		 * @return Url to a group's page.
		 * @author Aral Balkan
		 **/
		function urlsGetGroup($groupId)
		{
			$result = $this->api->urls_getGroup($groupId);
			
			return $this->_getResult($result);
		}		
		
		
		/**
		 * Returns the url to a users's photos.
		 * 
		 * Does not require authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.urls.getUserPhotos.html
		 *
		 * @param (optional, str) The auth token that was returned by authGetToken(). 
		 * @param (optional, str) The NSID of the user to fetch the url for. If omitted, the calling user is assumed.
 		 *
		 * @return Url to a user's photos.
		 * @author Aral Balkan
		 **/
		function urlsGetUserPhotos($token = NULL, $userId = NULL)
		{
			if (isset($token))
			{
				$this->api->setToken($token);
			}
			
			$result = $this->api->urls_getUserPhotos($userId);
			
			return $this->_getResult($result);
		}		
		
		
		/**
		 * Returns the url to a user's profile.
		 * 
		 * Does not require authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.urls.getUserProfile.html
		 *
		 * @param (optional, str) The auth token that was returned by authGetToken(). 
		 * @param (optional, str) The NSID of the user to fetch the url for. If omitted, the calling user is assumed.
 		 *
		 * @return Url to a user's profile.
		 * @author Aral Balkan
		 **/
		function urlsGetUserProfile($token = NULL, $userId = NULL)
		{
			if (isset($token))
			{
				$this->api->setToken($token);
			}
			
			$result = $this->api->urls_getUserProfile($userId);
			
			return $this->_getResult($result);
		}
		
		
		/**
		 * Returns a group NSID, given the url to a group's page or photo pool.
		 * 
		 * Does not require authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.urls.lookupGroup.html
		 * 
		 * @param (str) The url to the group's page or photo pool.
 		 *
		 * @return Group name and NSID.
		 * @author Aral Balkan
		 **/
		function urlsLookupGroup($url)
		{
			$result = $this->api->urls_lookupGroup($url);
			
			return $this->_getResult($result);
		}		
		
		
		/**
		 * Returns a user NSID, given the url to a user's photos or profile.
		 * 
		 * Does not require authentication.
		 * 
		 * Official Flickr API documentation:
		 * http://www.flickr.com/services/api/flickr.urls.lookupUser.html
		 * 
		 * @param (str) The url to the user's profile or photos page.
 		 *
		 * @return User name and NSID.
		 * @author Aral Balkan
		 **/
		function urlsLookupUser($url)
		{
			$result = $this->api->urls_lookupUser($url);
			
			return $this->_getResult($result);
		}		
		
						
		//
		// Private methods
		//
		
		
		function _getResult($result)
		{
			if ($result === false)
			{
				// Send the meaningful error message returned by Flickr, instead of false.
				$result = array('error'=>true, 'code'=>$this->api->error_code, 'message'=>$this->api->error_msg);
			}
			
			return $result;
		}
		
	}
	
?>