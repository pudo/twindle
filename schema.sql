
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

---

ALTER TABLE "user" ALTER COLUMN lang TYPE VARCHAR(100);
ALTER TABLE "status" ALTER COLUMN lang TYPE VARCHAR(100);

---

ALTER TABLE "user" ADD COLUMN profile_background_color VARCHAR(100);
ALTER TABLE "user" ADD COLUMN profile_background_image_url VARCHAR(1000);
ALTER TABLE "user" ADD COLUMN profile_background_image_url_https VARCHAR(1000);
ALTER TABLE "user" ADD COLUMN profile_background_tile BOOLEAN;
ALTER TABLE "user" ADD COLUMN profile_image_url VARCHAR(1000);
ALTER TABLE "user" ADD COLUMN profile_image_url_https VARCHAR(1000);
ALTER TABLE "user" ADD COLUMN profile_banner_url VARCHAR(1000);
ALTER TABLE "user" ADD COLUMN profile_link_color VARCHAR(100);
ALTER TABLE "user" ADD COLUMN profile_sidebar_border_color VARCHAR(100);
ALTER TABLE "user" ADD COLUMN profile_sidebar_fill_color VARCHAR(100);
ALTER TABLE "user" ADD COLUMN profile_text_color VARCHAR(100);
ALTER TABLE "user" ADD COLUMN profile_use_background_image VARCHAR(100);

ALTER TABLE "status" ADD COLUMN geo_latitude FLOAT;
ALTER TABLE "status" ADD COLUMN geo_longitude FLOAT;
ALTER TABLE "status" ADD COLUMN place_full_name VARCHAR(2000);
ALTER TABLE "status" ADD COLUMN place_country VARCHAR(1000);
ALTER TABLE "status" ADD COLUMN place_id VARCHAR(2000);


CREATE TABLE urls (
  status_id BIGINT NOT NULL,
  url VARCHAR(2000) NOT NULL,
  expanded_url VARCHAR(2000),
  display_url VARCHAR(2000),
  index_begin INTEGER,
  index_end INTEGER
);

CREATE TABLE user_mention (
  status_id BIGINT NOT NULL,
  screen_name VARCHAR(2000) NOT NULL,
  name VARCHAR(2000),
  id BIGINT,
  id_str VARCHAR(2000),
  index_begin INTEGER,
  index_end INTEGER
);

CREATE TABLE hashtags (
  status_id BIGINT NOT NULL,
  text VARCHAR(2000) NOT NULL,
  index_begin INTEGER,
  index_end INTEGER
);

CREATE TABLE raw (
  id BIGINT NOT NULL,
  json TEXT
);

DROP TABLE IF EXISTS tag;
CREATE TABLE tag (
  id SERIAL PRIMARY KEY,
  status_id BIGINT NOT NULL,
  tag VARCHAR(200) NOT NULL,
  category VARCHAR(200) NOT NULL,
  classified_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);


ALTER TABLE "status" ADD COLUMN retweeted_status_id BIGINT;

CREATE INDEX status_id ON status (id);
CREATE INDEX user_id ON "user" (id);
CREATE INDEX status_user_id ON status (user_id);
CREATE INDEX status_created_at ON status (created_at);
CREATE INDEX user_mention_status_id ON user_mention (status_id);
CREATE INDEX hashtags_status_id ON hashtags (status_id);
CREATE INDEX urls_status_id ON urls (status_id);
CREATE INDEX raw_id ON raw (id);

ALTER TABLE "tag" ADD COLUMN regex VARCHAR(2000);

DROP TABLE IF EXISTS tag_offset;
CREATE TABLE tag_offset (
  status_id BIGINT NOT NULL,
  regex VARCHAR(2000) NOT NULL
);

CREATE TABLE locations (
  location VARCHAR(2000) NOT NULL
);


DROP TABLE IF EXISTS "vote";
CREATE TABLE "vote" (
  id SERIAL PRIMARY KEY,
  status_id BIGINT UNIQUE NOT NULL,
  event VARCHAR(100),
  tag VARCHAR(100),
  sentiment INTEGER,
  created_at TIMESTAMPTZ
);
