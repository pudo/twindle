from common import engine, threaded, tag_status, dedup_tags
from pprint import pprint
import sqlalchemy.sql.expression as sql
import requests, re, csv
from StringIO import StringIO

REGEX_SHEET = 'https://docs.google.com/spreadsheet/pub?key=0AplklDf0nYxWdEtCVEdfWG8tVk1pNHlKQktJUzJ1UkE&single=true&gid=0&output=csv'


def get_rules():
    res = requests.get(REGEX_SHEET)
    rules = {}
    for row in csv.DictReader(StringIO(res.content)):
        pprint(row)
        rule = re.compile(row.get('Regex').decode('utf-8'), re.M)
        rules[(row.get('Field'), rule)] = (row.get('Category').decode('utf-8'), 
                                           row.get('Tag').decode('utf-8'))
    return rules


def classify_tweets():
    rules = get_rules()
    status_tbl = engine['status'].table
    user_tbl = engine['user'].table
    #engine.begin()
    q = status_tbl.join(user_tbl, user_tbl.c.id == status_tbl.c.user_id)
    q = sql.select([status_tbl, user_tbl], from_obj=q, use_labels=True)
    q = q.where(user_tbl.c.lang == 'de')
    q = q.order_by(status_tbl.c.id.desc())
    for i, status in enumerate(engine.query(q)):
        for (field, rule), (category, tag) in rules.items():
            m = rule.search(unicode(status.get(field)).lower())
            if m is not None:
                tag_status(status, category, tag)
        if i % 1000 == 0:
            print 'Processed: ', i
        #engine.commit()
    dedup_tags()


if __name__ == '__main__':
    classify_tweets()
