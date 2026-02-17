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

from django.db import models
import uuid

def generate_uuid_str():
    # UUIDを生成し、その文字列表現を返す
    return str(uuid.uuid4())

class FdwSample(models.Model):
    id = models.CharField(max_length=50, primary_key=True, default=generate_uuid_str, editable=False)
    num = models.IntegerField(unique=True)
    tim = models.TimeField()

    class Meta:
        managed = True # Djangoがテーブルを作成・変更しないように設定
        db_table = 'fdw_sample' # データベース内のテーブル名を指定

    def __str__(self):
        return f"FdwSample(id={self.id}, num={self.num}, tim={self.tim.strftime('%H:%M:%S')})"
