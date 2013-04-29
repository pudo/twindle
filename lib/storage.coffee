util = require 'util'
pg = require 'pg'
config = require './config'

class Storage

  constructor: () ->
    @client = new pg.native.Client config.db_url
    @client.connect (err) ->
      if err?
        console.error err

  saveUser: (user) ->
    client = @client
    client.query 'SELECT id FROM "user" WHERE id = $1', [user.id], (err, result) ->
      if err?
        console.error err
        return
      if result.rowCount > 0
        console.log "Existing user #{ user.screen_name }"
        return
      client.query 'INSERT INTO "user" (id, id_str, created_at, name, screen_name,
        location, url, description, protected, followers_count, friends_count,
        listed_count, favourites_count, utc_offset, time_zone, geo_enabled, verified,
        statuses_count, lang, contributors_enabled, is_translator, default_profile,
        default_profile_image) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11,
        $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23)',
        [user.id, user.id_str, new Date(user.created_at), user.name, user.screen_name,
        user.location, user.url, user.description, user.protected, user.followers_count,
        user.friends_count, user.listed_count, user.favourites_count, user.utc_offset,
        user.time_zone, user.geo_enabled, user.verified, user.statuses_count, user.lang,
        user.contributors_enabled, user.is_translator, user.default_profile,
        user.default_profile_image], (err, result) ->
          if err?
            console.error err
          if result.rowCount == 1
            console.log "Saved user #{ user.screen_name }"

  saveStatus: (status) ->
    #console.log util.inspect status
    @saveUser status.user
    @client.query 'INSERT INTO "status" (id, id_str, created_at, text, source, truncated,
      in_reply_to_status_id, in_reply_to_status_id_str, in_reply_to_user_id,
      in_reply_to_user_id_str, in_reply_to_screen_name, user_id, retweet_count,
      favorite_count, favorited, retweeted, possibly_sensitive, filter_level, lang) 
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17,
      $18, $19)',
      [status.id, status.id_str, new Date(status.created_at), status.text, status.source,
      status.truncated, status.in_reply_to_status_id, status.in_reply_to_status_id_str,
      status.in_reply_to_user_id, status.in_reply_to_user_id_str, status.in_reply_to_screen_name,
      status.user.id, status.retweet_count, status.favorite_count, status.favorited,
      status.retweeted, status.possibly_sensitive, status.filter_level, status.lang],
      (err, result) ->
        if err?
          console.error err
        #console.log result

  generateStatistics: (callback) ->
    client = @client
    stats = 
      'system_status': 'ok'
    client.query 'SELECT COUNT(id) AS num FROM status', (err, res) ->
      stats.status_count = res.rows[0].num
      client.query 'SELECT COUNT(id) AS num FROM "user"', (err, res) ->
        stats.user_count = res.rows[0].num
        callback stats



exports.Storage = Storage
