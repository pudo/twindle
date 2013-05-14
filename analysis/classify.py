from common import engine, threaded, tag_status
from pprint import pprint
import sqlalchemy.sql.expression as sql

def classify_tweets():
    status_tbl = engine['status'].table
    user_tbl = engine['user'].table
    engine.begin()
    q = status_tbl.join(user_tbl, user_tbl.c.id==status_tbl.c.user_id)
    q = sql.select([status_tbl, user_tbl], from_obj=q, use_labels=True)
    q = q.order_by(status_tbl.c.id.desc())
    for status in engine.query(q):
        if 'spd' in status['status_text']:
            print [status['status_text']]



if __name__ == '__main__':
    classify_tweets()