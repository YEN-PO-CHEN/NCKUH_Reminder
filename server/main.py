import os
from flask import Flask
import json

from package.Database import Database
from package.Browser import Browser
import requests

browser = Browser()
database = Database()

# Flask app
app = Flask(__name__)

linebot_url = 'http://127.0.0.1:8000'

@app.route("/get_return_list/<string:user_id>")
def get_return_appointment_list(user_id):
    if not database.check_user_by_id(user_id):
        return json.dumps({"appointments": []})
    browser.login(database.get_user_data_by_id(user_id))
    appointments = browser.extract_data()
    return json.dumps({"appointments": appointments})


@app.route("/get_return_list_by_ID_number/<string:ID_number>")
def get_return_appointment_list_by_ID_number(ID_number):
    id = database.get_id_by_ID_number(ID_number)
    return get_return_appointment_list(id)


@app.route("/get_return_list_by_line_id/<string:line_id>")
def get_return_appointment_list_by_lint_id(line_id):
    id = database.get_id_by_line_id(line_id)
    print(id)
    if id == '0':
        result = {'status': False, 'data': {}}
    else:
        profile = database.get_user_data_by_id(id)
        browser.login(profile)
        appointments = browser.extract_data()
        appointments[0]['name'] = profile['name']
        result = {'status': True, 'data': appointments[0]}
    return json.dumps(result)

@app.route("/remind_families/<string:user_id>")
def remind_families(user_id):
    profile = database.get_user_data_by_id(user_id)
    print("a;ldkfj: " + profile['ID_number'])
    requests.get(linebot_url+'/catch_id_and_json/' + profile['ID_number'])
    return 'ok'

@app.route("/remind_get_data/<string:ID_number>")
def remind_get_data(ID_number):
    id = database.get_id_by_ID_number(ID_number)
    print(id + 'remind')
    if id == '0':
        print('remind error')
        return json.dumps({"line_ids": [], "data": {}})
    else:
        profile = database.get_user_data_by_id(id)
        browser.login(profile)
        appointments = browser.extract_data()
        appointments[0]['name'] = profile['name']
        return json.dumps({"line_ids": profile['related_line_ids'], "data": appointments[0]})

@app.route("/check_user_by_ID_number/<string:ID_number>")
def check_user_by_ID_number(ID_number):
    if database.get_id_by_ID_number(ID_number) == '0':
        return "False"
    else:
        return "True"


@app.route("/get_user_profile_by_ID_number/<string:ID_number>")
def get_user_profile_by_ID_number(ID_number):
    return json.dumps(database.get_user_data_by_ID_number(ID_number))


@app.route("/register_line_id_to_profile/<string:set>")
def register_line_id_to_profile(set):
    data = json.loads(set)
    if database.register_line_id_by_ID_number(data['ID_number'], data['line_id']):
        return "True"
    else:
        return "False"


@app.route("/save_user_data/<string:user_data>")
def save_user_data(user_data):
    profile = json.loads(user_data)
    if database.save_user_data(profile):
        return "True"
    else:
        return "False"



if __name__ == "__main__":
    # init
    print('listening .....')

    # app run
    port = int(os.environ.get('PORT', 4000))
    app.run(host='0.0.0.0', port=port)

