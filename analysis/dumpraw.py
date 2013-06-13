import logging
import json
from common import engine

log = logging.getLogger(__name__)
table = engine.get_table('raw')

BATCH_SIZE = 50000


def dump_batches():
    if len(table) < BATCH_SIZE:
        log.info("Not enough entries remaining.")
        return False
    data, min_id = [], None
    log.info("Fetching %s raw tweets...", BATCH_SIZE)
    for row in table.find(_limit=BATCH_SIZE, order_by=['id']):
        if min_id is None:
            min_id = row['id']
        data.append(json.loads(row['json']))
        table.delete(id=row['id'])
    log.info("Saving file...")
    fh = open('dumps/raw_%s.json' % min_id, 'wb')
    json.dump(data, fh)
    fh.close()
    return True


if __name__ == '__main__':
    while True:
        if not dump_batches():
            break
