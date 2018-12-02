from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Welcome to EatGeek!'

@app.route('/nutrition')
def nutrition():
    return jsonify({ "sugar": "0-7 g", "carbohydrates": "0-10 g" })

