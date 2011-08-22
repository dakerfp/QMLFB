/////////////////////////////////////////////////////////////////////////////////
//
//	QMLFB version 0.1b by Jesse Ikonen
//	QMLFB version 0.2 by Daker Fernandes Pinheiro
//  =======================================
//
//	Simple QML Component that authenticates your users using Facebook Graph.
//
/////////////////////////////////////////////////////////////////////////////////

import QtQuick 1.0
import QtWebKit 2.1
import "helpers.js" as Helpers

WebView {
    id: fbAuth

    //  Facebook Properties
    property variant me: {}
    property string userId: "" // Read Only
    property string token: "" // Read Only
    property string displayStyle: "wap"; // "wap" OR "touch"
    property string applicationId: ""; // can't be null
    property url redirectUri: "http://www.facebook.com/connect/login_success.html"
    property variant scope: ["user_about_me"]
    property string responseType: "token"
    property url logoutUrl: "https://api.facebook.com/restserver.php?access_token="+fbAuth.token+"&method=auth.expireSession&format=json"
    property string authenticationUrl: "https://www.facebook.com/dialog/oauth?client_id=" + applicationId +
        "&redirect_uri=" + redirectUri +
        "&display=" + displayStyle +
        "&response_type=" + responseType +
        "&scope=" + scope.join("+")
    property bool isAuthenticated: false

    // Facebook Signals
    signal userAuthenticated()

    url: ""; //authenticationUrl

    // Facebook Functions

    // some graph stuff

    function myGraph(callback) {
        Helpers.getJSON("https://graph.facebook.com/"+userId+"?access_token="+token, callback);
    }

    function myPicture(opts) {
        var opts = opts || {};
        var size = opts.size || "large";

        return "https://graph.facebook.com/"+userId+"/picture?type="+size;
    }

    function authenticate() {
        url = authenticationUrl;
        __loginObserver();
        // this allows us to follow jasvascript redirects even though js is turned off (this is required as long as FB gets their shit together)
        if (html.match('<html><head><script type="text/javascript">')) {
            var target_arr = html.match(/window\.location\.href="(.*)"/)
            if (target_arr) {
                var crappy_target_url = target_arr[1]; // formatting is: http:\/\/www.facebook.com\/
                var actual_target_url = crappy_target_url.replace(/\\\//g, "/").replace("\u00257C", "|");  // fix formatting
                url = actual_target_url; // and go there.
            }
        }
    }

    // Facebook Implementation Details

    // signal handler
    onUrlChanged: __loginObserver();

    // saves fb token and fb user id
    function __loginObserver() {
        var token_re = "access_token=(.*)&expires_in="; // token
        var uid_re = "-([0-9]*)"; // fuid
        var login_success_re = "^http://www.facebook.com/connect/login_success.html"; // to test login_success page
        var matchable = url.toString(); // url string
        var fb_token = undefined;
        var fb_uid = undefined;

        if ( matchable.match(login_success_re) && /access_token/.test(matchable) ) { // if page is login_success and contains access_token
            fb_token = matchable.match(token_re)[1].replace(/\\u00257C/g, "|"); // replace unicode if found (if js redirect is followed it will be found)
            fb_uid = fb_token.match(uid_re)[1];

            if (fb_token && fb_uid) { // when we have token and user id
                userId = fb_uid; // save id
                token = fb_token; // save token
                isAuthenticated = true; // set booolean
                myGraph(function() {
                    fbAuth.me = this;
                });
                fbAuth.userAuthenticated();

                return true;
            }

        } else if (matchable.match(login_success_re) && /error/.test(matchable)){ // if user does not allow
            url = authenticationUrl; // ask again :)

            return false;
        } else {
            return false;
        }
    }
}


