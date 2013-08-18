from common import engine, normalize
from pprint import pprint
from datetime import datetime, timedelta
import sqlalchemy.sql.expression as sql
from sqlalchemy import text
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


def classify_tweets(rules):
    regexen = [d.get('regex') for (a, d) in rules.items()]
    offsets = get_offsets(regexen)
    delete_old_tags(regexen)

    q = text("""
        INSERT INTO tag (category, tag, status_id, classified_at, regex) 
        SELECT :category, :tag, s.id, NOW(), :regex
            FROM status s
            LEFT JOIN tag_offset tgo ON tgo.regex = :regex
            LEFT JOIN "user" u ON s.user_id = u.id
            WHERE
                (s.id > tgo.status_id OR tgo.status_id IS NULL) AND
                (s.text ~* :regex
                 OR u.name ~* :regex
                 OR u.screen_name ~* :regex)
                AND s.lang = 'de'
                AND s.created_at > NOW() - INTERVAL '28 days'
        """)

    offsets_q = text("""
        INSERT INTO tag_offset (regex, status_id)
            SELECT :regex, t.status_id
                FROM tag t
                WHERE t.regex = :regex 
                ORDER BY t.status_id DESC
                LIMIT 1
        """)

    for rule in rules.values():
        print rule
        engine.begin()
        engine.query(q, **rule)
        offset_table.delete(regex=rule['regex'])
        engine.query(offsets_q, regex=rule['regex'])
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
