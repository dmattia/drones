from flask import Flask, jsonify, request, render_template
from Paris import getJson

application = Flask(__name__, static_folder="webapp")

@application.route("/jobs", methods=["GET"])
def initialJobs():
  return jsonify(**getJson())

@application.route("/", methods=["GET"])
def main():
  return render_template("/index.html")

if __name__ == "__main__":
  application.debug = True
  application.run()
