# Configuration

One might experience luck reproducing the issue on a local machine but if it does not work, please use the following AWS EC2 instance type.

The issue can _reliably_ be reproduced on a `c6a.8xlarge` AWS EC2 virtual machine with the Amazon Linux installed.

# Steps to reproduce

## 3.12.2 with ddtrace-run or 3.12.4 without ddtrace-run (works, all good)

1) Build the image and run the container:
```
docker build -f 3.12.2_ddtrace.Dockerfile -t reproducer . && docker run --rm -it -p 9999:9999 reproducer
```

or 

```
docker build -f 3.12.4_no_ddtrace_run.Dockerfile -t reproducer . && docker run --rm -it -p 9999:9999 reproducer
```

2) Observe the following output:
```
[2024-06-13 22:17:56 +0000] [7] [INFO] Starting gunicorn 22.0.0
[2024-06-13 22:17:56 +0000] [7] [INFO] Listening at: http://0.0.0.0:9999 (7)
[2024-06-13 22:17:56 +0000] [7] [INFO] Using worker: gevent
[2024-06-13 22:17:56 +0000] [14] [INFO] Booting worker with pid: 14
If everything is fine, you should see 'App initialized.' printed to the console in a few seconds.
App initialized.
```
3) Run the following command:
```
curl -v http://localhost:9999 --max-time 2
```
4) Observe the output:
```
...
> 
< HTTP/1.1 200 OK
< Server: gunicorn
< Date: Thu, 13 Jun 2024 22:18:50 GMT
< Connection: keep-alive
< Content-Type: application/json
< Content-Length: 28
< 
{"message":"Hello, World!"}
* Connection #0 to host localhost left intact
```

5. Send the `SIGINT` (Ctrl+C) signal to the container and observe the following output:

```
^C[2024-06-13 22:33:12 +0000] [7] [INFO] Handling signal: int
[2024-06-13 22:33:12 +0000] [14] [INFO] Worker exiting (pid: 14)
[2024-06-13 22:33:12 +0000] [7] [INFO] Shutting down: Master
```

Gunicorn stops gracefully. Sometimes it might print a stack trace, but this does not affect the functionality.

```
^C[2024-06-13 22:46:47 +0000] [7] [INFO] Handling signal: int
[2024-06-13 22:46:47 +0000] [14] [INFO] Worker exiting (pid: 14)
Traceback (most recent call last):
  File "/root/.cache/pypoetry/virtualenvs/reproducer-9TtSrW0h-py3.12/lib/python3.12/site-packages/gevent/monkey.py", line 849, in _shutdown
    sleep()
  File "/root/.cache/pypoetry/virtualenvs/reproducer-9TtSrW0h-py3.12/lib/python3.12/site-packages/gevent/hub.py", line 159, in sleep
    waiter.get()
  File "src/gevent/_waiter.py", line 143, in gevent._gevent_c_waiter.Waiter.get
  File "src/gevent/_waiter.py", line 154, in gevent._gevent_c_waiter.Waiter.get
  File "src/gevent/_greenlet_primitives.py", line 61, in gevent._gevent_c_greenlet_primitives.SwitchOutGreenletWithLoop.switch
  File "src/gevent/_greenlet_primitives.py", line 61, in gevent._gevent_c_greenlet_primitives.SwitchOutGreenletWithLoop.switch
  File "src/gevent/_greenlet_primitives.py", line 65, in gevent._gevent_c_greenlet_primitives.SwitchOutGreenletWithLoop.switch
  File "src/gevent/_gevent_c_greenlet_primitives.pxd", line 35, in gevent._gevent_c_greenlet_primitives._greenlet_switch
  File "src/gevent/greenlet.py", line 908, in gevent._gevent_cgreenlet.Greenlet.run
  File "/root/.cache/pypoetry/virtualenvs/reproducer-9TtSrW0h-py3.12/lib/python3.12/site-packages/gunicorn/workers/base.py", line 198, in handle_quit
    sys.exit(0)
SystemExit: 0
2024-06-13T22:46:47Z <greenlet.greenlet object at 0x7ff18575e980 (otid=0x7ff1897ddda0) current active started main> failed with SystemExit

[2024-06-13 22:46:48 +0000] [7] [INFO] Shutting down: Master

```

## 3.12.3 or 3.12.4 with ddtrace-run (does not work, the app hangs)

1) Build the image and run the container:
```
docker build -f 3.12.4_ddtrace.Dockerfile -t reproducer . && docker run --rm -it -p 9999:9999 reproducer
```

2) Observe the following output:
```
[2024-06-13 22:23:29 +0000] [7] [INFO] Starting gunicorn 22.0.0
[2024-06-13 22:23:29 +0000] [7] [INFO] Listening at: http://0.0.0.0:9999 (7)
[2024-06-13 22:23:29 +0000] [7] [INFO] Using worker: gevent
[2024-06-13 22:23:29 +0000] [14] [INFO] Booting worker with pid: 14
If everything is fine, you should see 'App initialized.' printed to the console in a few seconds.
```

The message `App initialized.` is **not** printed to the console.

3) Run the following command:
```
curl http://localhost:9999 --max-time 2
```
4) Observe the output:
```
* Host localhost:9999 was resolved.
* IPv6: ::1
* IPv4: 127.0.0.1
*   Trying [::1]:9999...
* Connected to localhost (::1) port 9999
> GET / HTTP/1.1
> Host: localhost:9999
> User-Agent: curl/8.6.0
> Accept: */*
> 
* Operation timed out after 2005 milliseconds with 0 bytes received
* Closing connection
curl: (28) Operation timed out after 2005 milliseconds with 0 bytes received

```

5. Send the `SIGINT` (Ctrl+C) signal to the container and observe the following output:
```
^C[2024-06-13 22:28:50 +0000] [7] [INFO] Handling signal: int
[2024-06-13 22:29:21 +0000] [7] [ERROR] Worker (pid:14) was sent SIGKILL! Perhaps out of memory?
[2024-06-13 22:29:21 +0000] [7] [INFO] Shutting down: Master

```

Gunicorn has to kill the worker process with `SIGKILL` because it does not respond to the `SIGINT` signal.