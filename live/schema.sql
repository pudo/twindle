#	Question -> (event_id, id, question_text, answer_pos, answer_neg)
#	Vote -> (question_id, status_id, timestamp, tag)

DROP TABLE IF EXISTS "question";
CREATE TABLE "question" (
  id BIGINT UNIQUE NOT NULL,
  event_id INTEGER NOT NULL,
  question_text VARCHAR(140) NOT NULL,
  answer_pos VARCHAR(100) NULL,
  answer_neg VARCHAR(100) NULL
);

DROP TABLE IF EXISTS "vote";
CREATE TABLE "vote" (
  id BIGINT UNIQUE NOT NULL,
  question_id INTEGER NOT NULL,
  status_id BIGINT NOT NULL,
  voted_at TIMESTAMPTZ,	 
  tag VARCHAR(100) NOT NULL
);

