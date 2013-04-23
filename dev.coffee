
twitter = require './lib/twitter'

list =
  slug: 'bundestagsabgeordnete'
  owner_screen_name: 'zeitonline_pol'

getListMembers = (query, callback) ->
  twitter.client.get '/lists/members.json', query, (data) ->
    if data.next_cursor is 0
      return callback data.users
    query.cursor = data.next_cursor
    getListMembers query, (users) ->
      callback users.concat data.users

getListMembers list, (users) ->
  console.log users.length


