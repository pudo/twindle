from common import engine, normalize
from pprint import pprint
from datetime import datetime, timedelta
import sqlalchemy.sql.expression as sql
import requests
import re
import csv
from StringIO import StringIO

REGEX_SHEET = 'https://docs.google.com/spreadsheet/pub?key=0AplklDf0nYxWdEtCVEdfWG8tVk1pNHlKQktJUzJ1UkE&single=true&gid=0&output=csv'
PAGE_SIZE = 100000

tag_table = engine['tag']
offset_table = engine['tag_offset']


def dedup_tags():
    engine.query('''DELETE FROM tag USING tag t WHERE
        tag.status_id = t.status_id AND
        tag.tag = t.tag AND
        tag.category = t.category AND
        tag.regex = t.regex AND
        tag.id < t.id''')


def get_rules():
    res = requests.get(REGEX_SHEET)
    rules = {}
    for row in csv.DictReader(StringIO(res.content)):
        #pprint(row)
        rule = re.compile(row.get('Regex').decode('utf-8'), re.M)
        rules[rule] = {
            'category': row.get('Category').decode('utf-8'),
            'tag': row.get('Tag').decode('utf-8'),
            'regex': row.get('Regex').decode('utf-8')
        }
    return rules, regexen


def get_offsets(regexen):
    offsets = {}
    for regex in regexen:
        row = offset_table.find_one(regex=regex)
        status = 0 if row is None else row.status_id
        offsets[regex] = status
    return offsets


def handle_status(status, rules, offsets):
    for rule, data in rules.items():
        for field in ['status_text', 'user_name', 'user_screen_name']:
            if offsets.get(data.get('regex')) > status.get('status_id'):
                continue
            m = rule.search(normalize(status.get(field)))
            #print [field,data.get('regex'), m]
            if m is not None:
                #print [field, data.get('regex'), m]
                data['status_id'] = status['status_id']
                tag_table.insert(data)


def classify_tweets(rules):
    regexen = [d.get('regex') for (a, d) in rules.items()]
    offsets = get_offsets(regexen)
    delete_old_tags(regexen)
    status_tbl = engine['status'].table
    user_tbl = engine['user'].table
    max_id = 0
    q = status_tbl.join(user_tbl, user_tbl.c.id == status_tbl.c.user_id)
    fields = [status_tbl.c.id, status_tbl.c.text, user_tbl.c.id, user_tbl.c.name, user_tbl.c.screen_name]
    q = sql.select(fields, from_obj=q, use_labels=True)
    dt = datetime.utcnow() - timedelta(days=28)
    q = q.where(sql.and_(status_tbl.c.lang == 'de',
                         status_tbl.c.id >= min(offsets.values()),
                         status_tbl.c.created_at > dt))
    q = q.order_by(status_tbl.c.id.asc())
    
    offset = 0
    while True:
        engine.begin()
        lq = q.limit(PAGE_SIZE).offset(offset)
        offset += PAGE_SIZE
        print offset, limit
        has_records = False
        for i, status in enumerate(engine.query(lq)):
            has_records = True
            max_id = max(max_id, status.get('status_id'))
            handle_status(status, rules, offsets)
        if not has_records:
            break
        for regex in regexen:
            offset_table.upsert({'regex': regex, 'status_id': max_id}, ['regex'])
        engine.commit()
    dedup_tags()


def delete_old_tags(regexen):
    engine.begin()
    for row in tag_table.distinct('regex'):
        if row.get('regex') not in regexen:
            tag_table.delete(regex=row.get('regex'))
    engine.commit()


if __name__ == '__main__':
    rules = get_rules()
    classify_tweets(rules)
