import json
import pickle

# {
#     'id': 從1開始,
#     'name': 病患姓名,
#     'birth': 生日,
#     'year': 出生年,
#     'month': 出生月,
#     'day': 出生日,
#     'ID_number': 身分證字號,
#     'related_line_ids': [家屬line id ==> 用 list 存]
# }


class Database:
    def __init__(self):
        self._path = './package/data/'
        self._user_data_files_path = self._path + 'profile'
        self._users_data = self._load_users_data()
        print('load: ' + str(self._users_data))


    def check_user_by_id(self, id):
        for user in self._users_data:
            if id in user.values():
                return True
        return False

    def get_id_by_ID_number(self, id_number):
        for user in self._users_data:
            if id_number in user.values():
                return user['id']
        return "0"

    def get_id_by_line_id(self, line_id):
        print(line_id)
        for user in self._users_data:
            print(user['related_line_ids'])
            if line_id in user['related_line_ids']:
                return user['id']
        return "0"

    def get_max_user_id(self):
        if self._users_data:
            return self._users_data[-1]["id"]
        else:
            return "0"

    def register_line_id_by_ID_number(self, ID_number, line_id):
        id = int(self.get_id_by_ID_number(ID_number))
        if id == 0:
            return False

        if line_id not in self._users_data[id-1]['related_line_ids']:
            self._users_data[id - 1]['related_line_ids'].append(line_id)
            self._store_users_data()
        return True

    def save_user_data(self, profile):
        if self._save_data_pre_process(profile):
            self._users_data.append(profile)
            self._store_users_data()
            return True
        else:
            return False


    def get_user_data_by_id(self, id):
        for user in self._users_data:
            if id == user['id']:
                return user
        return {}

    def get_user_data_by_ID_number(self, ID_number):
        for user in self._users_data:
            if ID_number == user['ID_number']:
                return user
        return {}

    def _save_data_pre_process(self, profile):
        if 'id' in profile:
            return False

        max_id = int(self.get_max_user_id())
        profile['id'] = str(max_id + 1)

        if 'related_line_ids' not in profile:
            profile['related_line_ids'] = []

        if 'year' not in profile:
            profile['year'] = profile['birth'][0:4]
            profile['month'] = profile['birth'][4:6]
            profile['day'] = profile['birth'][6:8]

        return True

    def _load_users_data(self):
        try:
            with open(self._user_data_files_path, 'rb') as f:
                data = pickle.load(f)
                return data
        except OSError:
            return []

    def _store_users_data(self):
        print('store: ' + str(self._users_data))
        with open(self._user_data_files_path, 'wb') as f:
            pickle.dump(self._users_data, f)