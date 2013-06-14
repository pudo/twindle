import logging
import json
from common import engine

log = logging.getLogger(__name__)
raw_table = engine.get_table('raw')
#status_table = engine.get_table('raw_dumped')

BATCH_SIZE = 10000


def dump_batches():
    if len(raw_table) < BATCH_SIZE:
        log.info("Not enough entries remaining.")
        return False
    data, min_id, max_id = [], None, 0
    log.info("Fetching %s raw tweets...", BATCH_SIZE)
    engine.begin()
    for row in list(raw_table.find(_limit=BATCH_SIZE, order_by=['id'])):
        if min_id is None:
            min_id = row['id']
        data.append(json.loads(row['json']))
        raw_table.delete(id=row['id'])
    log.info("Saving file...")
    fh = open('dumps/raw_%s.json' % min_id, 'wb')
    json.dump(data, fh)
    fh.close()
    engine.commit()
    return True


if __name__ == '__main__':
    while True:
        if not dump_batches():
            break
