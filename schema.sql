
--- For Postgres, with love

DROP TABLE IF EXISTS "user";
CREATE TABLE "user" (
  id BIGINT UNIQUE NOT NULL,
  id_str VARCHAR(100) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  name VARCHAR(300) NULL,
  screen_name VARCHAR(100) NOT NULL,
  location VARCHAR(300),
  url VARCHAR(300),
  description VARCHAR(500),
  protected BOOLEAN,
  followers_count INTEGER,
  friends_count INTEGER,
  listed_count INTEGER,
  favourites_count INTEGER,
  utc_offset INTEGER,
  time_zone VARCHAR(200),
  geo_enabled BOOLEAN,
  verified BOOLEAN,
  statuses_count INTEGER,
  lang VARCHAR(3),
  contributors_enabled BOOLEAN,
  is_translator BOOLEAN,
  default_profile BOOLEAN,
  default_profile_image BOOLEAN
);

DROP TABLE IF EXISTS status;
CREATE TABLE status (
  id BIGINT UNIQUE NOT NULL,
  id_str VARCHAR(100) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  text VARCHAR(200) NOT NULL,
  source VARCHAR(200) NOT NULL,
  truncated BOOLEAN,
  in_reply_to_status_id BIGINT NULL,
  in_reply_to_status_id_str VARCHAR(100) NULL,
  in_reply_to_user_id BIGINT NULL,
  in_reply_to_user_id_str VARCHAR(100) NULL,
  in_reply_to_screen_name VARCHAR(200) NULL,
  user_id BIGINT NOT NULL,
  -- geo VARCHAR(200) NULL,
  -- geo VARCHAR(200) NULL,
  -- place
  -- contributors 
  retweet_count INTEGER,
  favorite_count INTEGER,
  favorited BOOLEAN,
  retweeted BOOLEAN,
  possibly_sensitive BOOLEAN,
  filter_level VARCHAR(200),
  lang VARCHAR(3)
);


ALTER TABLE "user" ALTER COLUMN lang TYPE VARCHAR(100);
ALTER TABLE "status" ALTER COLUMN lang TYPE VARCHAR(100);


