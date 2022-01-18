from itsdangerous import encoding
from transitions import Machine
from linebot.models import ImageSendMessage, ImageCarouselColumn, URITemplateAction, MessageTemplateAction, TemplateSendMessage,ImageCarouselTemplate,FlexSendMessage
import json
from utils import send_text_message, send_button_message_NoneURL, send_Multi_Image, send_Flex_message, CountDay,send_button_message_URL
import requests
from env_url import url

database_url = url + '/'

class TocMachine(Machine):
    def __init__(self, **machine_configs):
        self.machine = Machine(model=self, **machine_configs)

    def is_going_to_Menu(self,event):
        # return event.message.text
        return event.message.text == "開始" or event.message.text == 'EXIT'

    def on_enter_Menu(self, event):
        actions=[
            MessageTemplateAction(label='綁定',text='綁定'),
            MessageTemplateAction(label='查詢最近的預約時間',text='查詢最近的預約時間')]
        send_button_message_NoneURL(
            reply_token = event.reply_token,
            title='主選單',
            text='請選擇功能',
            btn = actions,
            )

    def is_going_to_name(self,event):
        return event.message.text == "綁定"

    def on_enter_name(self,event):
        actions=[MessageTemplateAction(label='回到主畫面',text='EXIT')]
        send_button_message_NoneURL(
            reply_token = event.reply_token,
            title='請輸入患者名字',
            text='患者全名',
            btn = actions,
            )
    def is_going_to_id(self,event):
        return event.message.text != 'EXIT'
    def on_enter_id(self,event):
        self.name = event.message.text
        self.linebotID = event.source.user_id
        actions=[MessageTemplateAction(label='回到主畫面',text='EXIT')]
        send_button_message_NoneURL(
            reply_token = event.reply_token,
            title='請輸入患者身分證字號',
            text='A123456789',
            btn = actions,
            )
    def is_going_to_success(self,event):
        return event.message.text != 'EXIT'
    def on_enter_success(self,event):
        self.ID = event.message.text
        data = {"ID_number":event.message.text,"line_id":event.source.user_id}
        data = json.dumps(data)
        rr = requests.get(f"{database_url}/register_line_id_to_profile/{data}")
        rr = rr.text
        print("\n\n\n\n\n\n",rr)
        if rr == "False":
            actions=[MessageTemplateAction(label='回到主畫面',text='EXIT')]
            send_button_message_NoneURL(
            reply_token = event.reply_token,
            title='綁定失敗',
            text='連結失敗！',
            btn = actions,
            )
        else:
            actions=[MessageTemplateAction(label='回到主畫面',text='EXIT')]
            send_button_message_NoneURL(
            reply_token = event.reply_token,
            title='綁定成功',
            text='連結成功！',
            btn = actions,
            )
    def is_going_to_search(self,event):
        return event.message.text == "查詢最近的預約時間"
    def on_enter_search(self,event):
        # request json
        rr = requests.get(f"{database_url}/get_return_list_by_line_id/{event.source.user_id}")
        # print("\n\n\n\n\n\n")
        # print(type(rr.content))
        # print(rr.content)
        # print("\n\n\n\n\n\n")
        rr = json.loads(rr.text)
        print(rr)
        if rr['status'] == False:
            actions=[MessageTemplateAction(label='回到主畫面',text='EXIT')]
            send_button_message_NoneURL(
            reply_token = event.reply_token,
            title='查無資料',
            text='請重新註冊',
            btn = actions,
            )
        else:
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
            send_Flex_message(event.reply_token,message)

