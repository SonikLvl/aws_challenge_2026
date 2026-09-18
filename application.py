from flask import Flask

application = Flask(__name__)

@application.route("/")
def index():
    return "Hello from 9ped0fct Elastic Beanstalk CI-CD"

if __name__ == "__main__":
    application.run(host="0.0.0.0", port=5000)