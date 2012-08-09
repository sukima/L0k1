Server
======

* Serves page
* Page without Query String is user view: Time remaining for next polling,
  Setting to open tunnel on next poll
* Page with query string is API for client: Start tunnel true/false, query
  string sets next polling timestamp.

Client
======

* Set new random polling interval.
* Send to server with new interval.
* If return value is true check for tunnel and start if not running.
* Wait for polling interval and repeat.

Tunnel
======

* Open reverse tunnel ssh to server.
* set command to `sleep 120`.
