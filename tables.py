# -*- coding: utf-8 -*-
u"""Работа с динамическими таблицами для хранения данных админки."""

import time

import yt.wrapper as yt
import yt.yson as yson

USER_GROUPS_SCHEMA = [
    {"name": "user_group_id", "type": "string", 'sort_order': 'ascending'},
    {"name": "filters", "type": "any"},
]


CAMPAIGN_GROUPS_SCHEMA = [
    {"name": "campaign_group_id", "type": "string", 'sort_order': 'ascending'},
    {"name": "campaign_list", "type": "any"},
]


EXPERIMENTS_SCHEMA = [
    {"name": "experiment_id", "type": "string", 'sort_order': 'ascending'},
    {"name": "user_group_ids", "type": "any"},
    {"name": "campaign_group_ids", "type": "any"},
]


WORK_PATH = '//home/edadeal/analytics/exp_admin'


def create_table(table, schema):
    u"""Создание динамической таблицы."""
    sorted_schema = yson.YsonList(schema)
    sorted_schema.attributes['unique_keys'] = True

    yt.create(
        'table',
        '{}/{}'.format(WORK_PATH, table),
        ignore_existing=True,
        recursive=True,
        attributes={'schema': sorted_schema, 'external': False, 'dynamic': True}
    )


def update_record(table, **kwargs):
    u"""Обновление записи в динамической таблице."""
    yt.insert_rows(
        table,
        [{k: v for k, v in kwargs.items()}],
        update=True
    )


def read_record(table, **kwargs):
    u"""Чтение записи из динамической таблицы."""
    record = list(yt.lookup_rows(
        '{}/{}'.format(WORK_PATH, table),
        [{k: v for k, v in kwargs.items()}]
    ))

    return record


def init():
    u"""Подключить таблицы."""
    for table in ('user_groups', 'campaign_groups', 'experiments'):
        full_path = '{}/{}'.format(WORK_PATH, table)
        yt.mount_table(full_path)
        while yt.get('{}/@tablets/0/state'.format(full_path)) != 'mounted':
            time.sleep(0.1)
