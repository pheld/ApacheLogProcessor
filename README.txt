= ApacheLogProcessor

* http://uwruby.com/2009/04/hello-here-is-your-week-4-homework/ 

== DESCRIPTION:

An apache log processor. For this project you will:

    * Provide a commandline tool that safely modifies files
    * Change IP Address at the beginning of the line in an Apache logfile
    * Must be multithreaded
    * Must maintain log order
    * Cache name lookups across invocations
    * Age the cache items (expire lookups)
    * Commandline option to limit number of threads (you should determine a sensible default)
    * Look at “resolv” for DNS lookups
    * This homework can be completed using only tools from ruby’s standard library

The file format will look like this:

208.77.188.166 - - [29/Apr/2009:16:07:38 -0700] "GET / HTTP/1.1" 200 1342
75.119.201.189 - - [29/Apr/2009:16:07:44 -0700] "GET /favicon.ico HTTP/1.1" 200 1406
75.146.57.34 - - [29/Apr/2009:16:08:38 -0700] "GET / HTTP/1.1" 304 -
75.119.201.189 - - [29/Apr/2009:16:09:53 -0700] "GET / HTTP/1.1" 200 1340
208.77.188.166 - - [29/Apr/2009:16:11:51 -0700] "GET / HTTP/1.1" 304 -
75.146.57.34 - - [29/Apr/2009:16:12:00 -0700] "GET / HTTP/1.1" 304 -
75.119.201.189 - - [29/Apr/2009:16:13:15 -0700] "GET / HTTP/1.1" 304 -
208.77.188.166 - - [29/Apr/2009:16:13:15 -0700] "GET / HTTP/1.1" 304 -
75.119.201.189 - - [29/Apr/2009:16:13:17 -0700] "GET / HTTP/1.1" 304 -
75.146.57.34 - - [29/Apr/2009:16:13:50 -0700] "GET / HTTP/1.1" 200 1294
75.146.57.34 - - [29/Apr/2009:16:13:55 -0700] "GET /stylesheets/main.css?1240264242 HTTP/1.1" 200 2968
74.125.67.100 - - [29/Apr/2009:16:13:55 -0700] "GET /stylesheets/home.css?1240264242 HTTP/1.1" 200 7829

We want the file to end up looking like this:

example.com - - [29/Apr/2009:16:07:38 -0700] "GET / HTTP/1.1" 200 1342
example.com - - [29/Apr/2009:16:07:44 -0700] "GET /favicon.ico HTTP/1.1" 200 1406
example.com - - [29/Apr/2009:16:08:38 -0700] "GET / HTTP/1.1" 304 -
example.com - - [29/Apr/2009:16:09:53 -0700] "GET / HTTP/1.1" 200 1340
example.com - - [29/Apr/2009:16:11:51 -0700] "GET / HTTP/1.1" 304 -
example.com - - [29/Apr/2009:16:12:00 -0700] "GET / HTTP/1.1" 304 -
example.com - - [29/Apr/2009:16:13:15 -0700] "GET / HTTP/1.1" 304 -
example.com - - [29/Apr/2009:16:13:15 -0700] "GET / HTTP/1.1" 304 -
example.com - - [29/Apr/2009:16:13:17 -0700] "GET / HTTP/1.1" 304 -
example.com - - [29/Apr/2009:16:13:50 -0700] "GET / HTTP/1.1" 200 1294
example.com - - [29/Apr/2009:16:13:55 -0700] "GET /stylesheets/main.css?1240264242 HTTP/1.1" 200 2968
example.com - - [29/Apr/2009:16:13:55 -0700] "GET /stylesheets/home.css?1240264242 HTTP/1.1" 200 7829

These domain names aren’t correct, but your output format should be similar.

Here is an example session using the command line tool you will write for your homework:

$ apache_lookup my_logs.log

After execution you should be able to examine my_logs.log and see that the ip addresses have been replaced with domain names. You should also be able to do this:

$ apache_lookup -t 100 my_logs.log

The above execution should spawn 100 threads to process your logfile.

This homework MUST be test driven. We will dock points for non-test driven code. You MUST turn your homework in as a tar.gz or as a gem. Remember to email the mailing list, use IRC, start early, test all the time, and have fun!

== FEATURES/PROBLEMS:

* Multi-threaded
* Maintains log order
* Caches name lookups across invocations
* Customizable thread count

== SYNOPSIS:

Regular usage:
$ apache_lookup my_logs.log

Thread count specified:
$ apache_lookup -t 100 my_logs.log

== REQUIREMENTS:

* No special gems.  Just Ruby standard library.

== INSTALL:

* N/A

== LICENSE:

(The MIT License)

Copyright (c) 2009 Peter Held

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
