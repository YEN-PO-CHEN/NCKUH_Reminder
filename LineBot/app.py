
import os
import sys
import json
from flask import Flask, jsonify, request, abort, send_file
from dotenv import load_dotenv
from linebot import LineBotApi, WebhookParser
from linebot.exceptions import InvalidSignatureError
from linebot.models import MessageEvent, TextMessage, FlexSendMessage
from env_url import url
import requests

from fsm import TocMachine
from utils import send_text_message
load_dotenv()
USER_ID = {}
def createMachine():
    return TocMachine(
        states=["user",
                "Menu",
                "name","id","success",
                "search",
                ],
        transitions=[
            {"trigger" : "advance", "source" : "user", "dest" : "Menu", "conditions" : "is_going_to_Menu"},

            {"trigger" : "advance", "source" : "Menu", "dest" : "name", "conditions" : "is_going_to_name"},
            {"trigger" : "advance", "source" : "Menu", "dest" : "search", "conditions" : "is_going_to_search"},
            {"trigger" : "advance", "source" : "Menu", "dest" : "user", "conditions" : "is_going_to_user"},

            {"trigger" : "advance", "source" : "name", "dest" : "id", "conditions" : "is_going_to_id"},
            {"trigger": "go_back", "source": "id", "dest": "name"},

            {"trigger" : "advance", "source" : "id", "dest" : "success", "conditions" : "is_going_to_success"},
            {"trigger": "go_back", "source": "success", "dest": "id"},

            {"trigger" : "advance", "source" : ["search","success",'name','id'], "dest" : "Menu", "conditions"  : "is_going_to_Menu"},
        ],
        initial="user",
        auto_transitions=False,
    )


app = Flask(__name__, static_url_path="")


# get channel_secret and channel_access_token from your environment variable
channel_secret = os.getenv("LINE_CHANNEL_SECRET", None)
channel_access_token = os.getenv("LINE_CHANNEL_ACCESS_TOKEN", None)




if channel_secret is None:
    print("Specify LINE_CHANNEL_SECRET as environment variable.")
    sys.exit(1)
if channel_access_token is None:
    print("Specify LINE_CHANNEL_ACCESS_TOKEN as environment variable.")
    sys.exit(1)

line_bot_api = LineBotApi(channel_access_token)
parser = WebhookParser(channel_secret)


@app.route("/catch_id_and_json/<string:ID_number>")
def catch_id_and_json(ID_number):
    data = requests.get(url + '/remind_get_data/' + ID_number)
    print(data.text)
    rr = json.loads(data.text)
    message = json.load(open('assets/search.json','r',encoding='utf-8'))
    message['body'][ 'contents'][1]['text'] = rr['data']['name']
    message['body'][ 'contents'][2]['contents'][0]['contents'][1]['text'] = rr['data']['doctor_name']
    message['body'][ 'contents'][2]['contents'][1]['contents'][1]['text'] = rr['data']['type name']
    message['body'][ 'contents'][2]['contents'][3]['contents'][1]['text'] = rr['data']['date']
    message['body'][ 'contents'][2]['contents'][4]['contents'][1]['text'] = rr['data']['time range']
    message['body'][ 'contents'][2]['contents'][5]['contents'][1]['text'] = rr['data']['number']
    message['body'][ 'contents'][2]['contents'][6]['contents'][1]['text'] = rr['data']['location']
    message['body'][ 'contents'][2]['contents'][7]['contents'][1]['text'] = rr['data']['room']
    if len(rr['data']['else']) == 0:
        message['body'][ 'contents'][2]['contents'][8]['contents'][1]['text'] = '__'
    else:
        message['body'][ 'contents'][2]['contents'][8]['contents'][1]['text'] = rr['data']['else']
    line_bot_api = LineBotApi(channel_access_token)

    for id in rr['line_ids']:
        print("\n\nstart\n\n")
        line_bot_api.push_message(id, FlexSendMessage('profile',message))
        print("\n\nEnd")
    
    return "OK"




@app.route("/webhook", methods=["POST"])
def webhook_handler():
    signature = request.headers["X-Line-Signature"]
    # get request body as text
    body = request.get_data(as_text=True)
    app.logger.info(f"Request body: {body}")

    # parse webhook body
    try:
        events = parser.parse(body, signature)
    except InvalidSignatureError:
        abort(400)

    # if event is MessageEvent and message is TextMessage, then echo text
    for event in events:
        if not isinstance(event, MessageEvent):
            continue
        if not isinstance(event.message, TextMessage):
            continue
        if not isinstance(event.message.text, str):
            continue
        if event.source.user_id not in USER_ID:
            print(f"Create ! {event.source.user_id}")
            # record userID
            USER_ID[event.source.user_id] = createMachine()
        if event.message.text == "HELP":
            send_text_message(event.reply_token, "請輸入\"開始\"進入主選單")
            return "OK"
        response = USER_ID[event.source.user_id].advance(event)

        print("\n")
        print(f'{event.source.user_id}--->{USER_ID[event.source.user_id].state}')
        print("\n")
        
        if response == False:
            send_text_message(event.reply_token, "找不到指令\n還是你只是想找我聊天哩")
    return "OK"

if __name__ == "__main__":
    port = os.environ.get("PORT", 8000)
    app.run(host="0.0.0.0", port=port, debug=True)