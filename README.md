L0k1
====

This is a small hack that will open up a remote tunnel that is triggered from a
web page.

You place the php on a server. It uses Google Authenticator to establish
authentication.

Then place the client on the computer you want to poll the php page. When the
request for a reverse ssh tunnel is entered via the page the client will pick
it up and open the tunnel for 120 seconds. Then rinse, lather, repeat using a
random polling interval (bell curve distribution)

Server
------

* Serves page
* Page without Query String is user view: Time remaining for next polling,
  Setting to open tunnel on next poll
* Page with query string is API for client: Start tunnel true/false, query
  string sets next polling timestamp.

Client
------

* Set new random polling interval.
* Send to server with new interval.
* If return value is true check for tunnel and start if not running.
* Wait for polling interval and repeat.

Tunnel
------

* Open reverse tunnel ssh to server.
* set command to `sleep 120`.
