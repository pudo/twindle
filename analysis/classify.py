from common import engine, threaded, tag_status
from pprint import pprint
import sqlalchemy.sql.expression as sql
import requests, re, csv
from StringIO import StringIO

REGEX_SHEET = 'https://docs.google.com/spreadsheet/pub?key=0AplklDf0nYxWdFhfSXNDdUtpVVkybjNKRDhTdUNzc3c&single=true&gid=1&output=csv'

def get_rules():
    res = requests.get(REGEX_SHEET)
    rules = {}
    for row in csv.DictReader(StringIO(res.content)):
        rule = re.compile(row.get('Regex'), re.I | re.M)
        rules[(row.get('Field'), rule)] = row.get('Tag')
    return rules


def classify_tweets():
    rules = get_rules()
    status_tbl = engine['status'].table
    user_tbl = engine['user'].table
    #engine.begin()
    q = status_tbl.join(user_tbl, user_tbl.c.id == status_tbl.c.user_id)
    q = sql.select([status_tbl, user_tbl], from_obj=q, use_labels=True)
    q = q.order_by(status_tbl.c.id.desc())
    for i, status in enumerate(engine.query(q)):
        for (field, rule), tag in rules.items():
            m = rule.match(status.get(field))
            if m is not None:
                tag_status(status, tag)
        if i % 1000 == 0:
            print 'Processed: ', i
        #engine.commit()


if __name__ == '__main__':
    classify_tweets()
