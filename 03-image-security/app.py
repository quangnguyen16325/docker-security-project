
from flask import Flask

import os



app = Flask(__name__)



@app.route('/')

def index():

    user = os.popen('whoami').read().strip()

    return f"Docker Image Security Lab - Running as user: {user}\n"



if __name__ == '__main__':

    app.run(host='0.0.0.0', port=5000)

