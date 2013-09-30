import json
import logging
from common import engine
from dataset.freeze.format.fjson import JSONEncoder
from datetime import datetime, timedelta
import sqlalchemy.sql.expression as sql

log = logging.getLogger(__name__)
raw_tbl = engine.get_table('raw').table
hashtags_tbl = engine.get_table('hashtags').table
#status_table = engine.get_table('raw_dumped')

def dump_hashtag(tag):
    data = []

    status_tbl = engine['status'].table
    user_tbl = engine['user'].table
    q = status_tbl.join(user_tbl, user_tbl.c.id == status_tbl.c.user_id)
    q = q.join(hashtags_tbl, status_tbl.c.id == hashtags_tbl.c.status_id)
    q = sql.select([status_tbl, user_tbl], from_obj=q, use_labels=True)
    q = q.where(hashtags_tbl.c.text.ilike(tag))
    q = q.order_by(hashtags_tbl.c.status_id.asc())
    
    statuses = []
    for row in engine.query(q):
        data.append(row)
        #data.append(json.loads(row['raw_json']))
    #for json_file in os.listdir('dumps'):
    #    print json_file, len(statuses), len(data)
    #    #min_id = int(json_file.split('.', 1)[0].split('_', 1)[-1])
    #    fh = open('dumps/%s' % json_file, 'rb')
    #    ss = json.load(fh)
    #    for s in ss:
    #        if s.get('id') in statuses:
    #            data.append(s)
    
    log.info("Saving file...")
    fh = open('dump_%s.json' % tag, 'wb')
    print len(data)
    json.dump(data, fh, cls=JSONEncoder)
    fh.close()
    return True


if __name__ == '__main__':
    dump_hashtag('tatort')
