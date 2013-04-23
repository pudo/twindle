
twitter = require './lib/twitter'

list = 
  slug: 'bundestagsabgeordnete'
  owner_screen_name: 'zeitonline_pol'

getListMembers = (query, callback) ->
  console.log query
  twitter.client.get '/lists/members.json', query, (data) ->
    #console.log data
    #console.log data.users.length
    if not data.next_cursor?
      return callback data.users or []
    query.cursor = data.next_cursor
    getListMembers query, (users) ->
      users.extend data.users
      callback users

getListMembers list, (users) ->
  console.log users.length
