from flask import Flask

print("If everything is fine, you should see 'App initialized.' printed to the console in a few seconds.")

# The following code line causes the process to hang.
# If you comment it out, the process will start up fine and
# the "App initialized." message will be printed to the console.
# The app will also respond to requests (GET http://localhost:9999/)

# noinspection PyUnresolvedReferences
from mongoengine.queryset import QuerySet  # This is the culprit

app = Flask(__name__)


@app.route("/")
def hello_world():
    return {"message": "Hello, World!"}


print("App initialized.")
