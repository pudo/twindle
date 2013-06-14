from common import engine
from pprint import pprint
import sqlalchemy.sql.expression as sql
import requests
import re
import csv
from StringIO import StringIO

REGEX_SHEET = 'https://docs.google.com/spreadsheet/pub?key=0AplklDf0nYxWdEtCVEdfWG8tVk1pNHlKQktJUzJ1UkE&single=true&gid=0&output=csv'

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
        rules[(row.get('Field'), rule)] = {
            'category': row.get('Category').decode('utf-8'),
            'tag': row.get('Tag').decode('utf-8'),
            'regex': row.get('Regex').decode('utf-8')
        }
    regexen = [d.get('regex') for (a, d) in rules.items()]
    return rules, regexen


def get_offsets(regexen):
    offsets = {}
    for regex in regexen:
        row = offset_table.find_one(regex=regex)
        status = 0 if row is None else row.status_id
        offsets[regex] = status
    return offsets


def classify_tweets():
    rules, regexen = get_rules()
    offsets = get_offsets(regexen)
    delete_old_tags(regexen)
    status_tbl = engine['status'].table
    user_tbl = engine['user'].table
    engine.begin()
    max_id = 0
    q = status_tbl.join(user_tbl, user_tbl.c.id == status_tbl.c.user_id)
    q = sql.select([status_tbl, user_tbl], from_obj=q, use_labels=True)
    q = q.where(sql.and_(status_tbl.c.lang == 'de',
                         status_tbl.c.id >= min(offsets.values())))
    q = q.order_by(status_tbl.c.id.desc())
    for i, status in enumerate(engine.query(q)):
        max_id = max(max_id, status.get('status_id'))
        for (field, rule), data in rules.items():
            if offsets.get(data.get('regex')) > status.get('status_id'):
                continue
            m = rule.search(unicode(status.get(field)).lower())
            #print [field,data.get('regex'), m]
            if m is not None:
                #print [field, data.get('regex'), m]
                data['status_id'] = status['status_id']
                tag_table.insert(data)
        if i % 1000 == 0:
            print 'Processed: ', i
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
    classify_tweets()
