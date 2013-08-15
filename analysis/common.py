import dataset
import os
from Queue import Queue
from threading import Thread
import logging
import tweepy
from unicodedata import normalize as ucnorm, category

log = logging.getLogger(__name__)


def tweepy_api():
    auth = tweepy.OAuthHandler(os.environ.get('CONSUMER_KEY'), os.environ.get('CONSUMER_SECRET'))
    auth.set_access_token(os.environ.get('ACCESS_TOKEN'), os.environ.get('ACCESS_SECRET'))
    return tweepy.API(auth)


def normalize(text):
    if not isinstance(text, unicode):
        text = unicode(text)
    decomposed = ucnorm('NFKD', text)
    filtered = []
    for char in decomposed:
        cat = category(char)
        if char == "'" or cat.startswith('M') or cat.startswith('S'):
            continue
        elif cat.startswith('L') or cat.startswith('N'):
            filtered.append(char)
        else:
            filtered.append(' ')
    text = u''.join(filtered)
    while '  ' in text:
        text = text.replace('  ', ' ')
    return ucnorm('NFKC', text).strip().lower()


def unthreaded(items, func):
    """ Debug placeholder. """
    for item in items:
        func(item)


def threaded(items, func, num_threads=5, max_queue=200):
    def queue_consumer():
        while True:
            item = queue.get(True)
            try:
                func(item)
            except Exception, e:
                log.exception(e)
            queue.task_done()

    queue = Queue(maxsize=max_queue)

    for i in range(num_threads):
        t = Thread(target=queue_consumer)
        t.daemon = True
        t.start()

    for item in items:
        queue.put(item, True)
    queue.join()


def get_engine():
    db_url = os.environ.get('DB_URL', 'postgresql://localhost/twitter')
    db_url = db_url.replace('tcp://', 'postgresql://')
    return dataset.connect(db_url)

engine = get_engine()
