import requests
from common import engine, threaded
from pprint import pprint
import re

COORD_RE = re.compile(r".*(-?\d{1,3}.{1,10})[,/](-?\d{1,3}.{1,10})")
SERVICE = 'http://open.mapquestapi.com/nominatim/v1/search'


def nominatim(location):
    res = requests.get(SERVICE, params={
        'format': 'json',
        'limit': 1,
        'q': location,
        'addressdetails': 1,
    })
    data = res.json()
    if not len(data):
        return {}
    data = data[0]
    addr = data.get('address')
    return {
        'importance': data.get('importance'),
        'lat': data.get('lat'),
        'lon': data.get('lon'),
        'city': addr.get('city'),
        'country': addr.get('country'),
        'country_code': addr.get('country_code'),
        'state': addr.get('state'),
    }


def geocode_location(location):
    locations = engine['locations']
    location = location.get('loc')
    rec = {'location': location}
    m = COORD_RE.match(location)
    print [location, m]
    if m is not None:
        try:
            rec['lat'] = float(m.group(1))
            rec['lon'] = float(m.group(2))
            locations.upsert(rec, ['location'])
            return
        except:
            pass
    nom = nominatim(location)
    rec.update(nom)
    locations.upsert(rec, ['location'])


def geocode_locations():
    q = """SELECT DISTINCT TRIM(LOWER(u.location)) AS loc FROM "user" u
        LEFT OUTER JOIN locations lx ON lx.location = TRIM(LOWER(u.location))
        WHERE u.location IS NOT NULL AND lx.location IS NULL;"""
    locations = list(engine.query(q))
    print q, ' --> ', len(locations)
    threaded(locations, geocode_location)

if __name__ == '__main__':
    geocode_locations()
