import re
from pprint import pprint
from lxml import etree
from common import normalize
from classify import classify_tweets

def load_searches():
    doc = etree.parse('http://www.spiegel.de/xml/xml-61163.xml')
    searches = {}
    for search_el in doc.findall('.//search'):
        terms = search_el.findall('.//term')
        terms = sorted([normalize(t.text) for t in terms])
        terms = '|'.join(terms)
        terms = terms.replace('-', '\-').replace(' ', '.*')
        terms = "(%s)" % terms
        rex = re.compile(terms)
        searches[rex] = {
            'category': search_el.get('type'),
            'tag': search_el.get('name'),
            'regex': terms
            }
    return searches


if __name__ == '__main__':
    rules = load_searches()
    classify_tweets(rules)

