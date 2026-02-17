# Copyright 2026 Project Tsurugi.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Django は Django 自身が管理する認証やセッションなどの管理テーブルを
# settings.py の DATABASES['default'] のデータベースに作成します。
# Tsurugi FDW の外部テーブルは PostgreSQL(Django) の管理テーブルと共存
# できないため、データベースルーターを登録します。

class TsurugiRouter:
    """
    A router to control all database operations on models in the my_app application.
    """
    route_app_labels = {'my_app'} # my_app アプリケーションのモデルをルーティング対象とする

    def db_for_read(self, model, **hints):
        """
        Attempts to read my_app models go to tsurugi_connection.
        """
        if model._meta.app_label in self.route_app_labels:
            return 'tsurugi_connection'
        return None

    def db_for_write(self, model, **hints):
        """
        Attempts to write my_app models go to tsurugi_connection.
        """
        if model._meta.app_label in self.route_app_labels:
            return 'tsurugi_connection'
        return None

    def allow_relation(self, obj1, obj2, **hints):
        """
        Allow relations if both objects are in the 'tsurugi_connection' database.
        """
        if obj1._meta.app_label in self.route_app_labels or \
           obj2._meta.app_label in self.route_app_labels:
            return True # my_app モデル間のリレーションは許可
        return None

    def allow_migrate(self, db, app_label, model_name=None, **hints):
        """
        Make sure the my_app app only appears in the 'tsurugi_connection' database.
        And other apps do not appear in 'tsurugi_connection'.
        """
        if app_label in self.route_app_labels:
            return db == 'tsurugi_connection' # my_app のマイグレーションは 'tsurugi_connection' のみ
        elif db == 'tsurugi_connection':
            return False # 他のアプリは 'tsurugi_connection' ではマイグレートしない
        return None # それ以外はデフォルトの動作 (default DB)
