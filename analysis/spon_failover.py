import re
from pprint import pprint
from lxml import etree
from common import normalize, tweepy_api
from classifydb import classify_tweets
import time
from random import shuffle
from kombu import Connection, Exchange, Queue

exchange_name = 'twindle2'
exchange = Exchange(exchange_name, 'fanout', durable=True, auto_delete=False)
queue = Queue(exchange_name+'live', exchange=exchange, routing_key='status')
conn = Connection('amqp://guest:guest@localhost:5672')
producer = conn.Producer(serializer='json')

def load_searches():
    doc = etree.parse('http://www.spiegel.de/xml/xml-61163.xml')
    searches = {}
    els = list(doc.findall('.//search'))
    shuffle(els)
    for search_el in els:
        if 'inaktiv' in search_el.get('type', ''):
            continue
        terms = search_el.findall('.//term')
        terms_ = []
        for term in terms:
            terms_.append(term.text.lower().strip())
            yield term.text.lower().strip()

def run_search(tweepy, term):
    max_id = 0
    seen = []
    term = '(%s) AND lang:de' % term
    while True:
        res = tweepy.search(q=term, max_id=max_id, count=100, result_type='recent')
        for status in res:
            producer.publish(status.json, exchange=exchange, routing_key='status') #, declare=[queue])
            print "Queue %s (%s)" % (status.id, [term])
        if len(res) < 10:
            return
        max_id = min([t.id for t in res])
        if max_id < 371737650497343500:
            return
        time.sleep(6)


def run_searches():
    tweepy = tweepy_api()
    for term in load_searches():
        try:
            run_search(tweepy, term)
        except Exception, e:
            print e
            time.sleep(60)


if __name__ == '__main__':
    run_searches()
