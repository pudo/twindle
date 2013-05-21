import argparse
from tweepy import Cursor
from common import engine, tweepy_api

api = tweepy_api()

parser = argparse.ArgumentParser(description='Process some integers.')
parser.add_argument('list', metavar='USER/LIST', type=unicode,
                    help='a twitter list to be loaded')


def main():
    args = parser.parse_args()
    list_user, list_name = args.list.split('/', 1)
    table = engine['lists']
    table.delete(list_user=list_user, list_name=list_name)
    for result_set in Cursor(api.list_members, list_user, list_name).pages():
        for user in result_set:
            print user.id, user.screen_name
            data = {'user_id': user.id, 'screen_name': user.screen_name,
                    'list_user': list_user, 'list_name': list_name}
            table.insert(data)


if __name__ == '__main__':
    main()
