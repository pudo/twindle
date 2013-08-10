

What are we collecting?

	* Real-time info on a particular hashtag (or set of hashtags)
	* Comparisons of tags grouped by topic (e.g. #merkel+, #merkel-)


Schema


	Question -> (event_id, id, question_text, answer_pos, answer_neg)
	Vote -> (question_id, status_id, timestamp, tag)



Open Questions

	* Does Twitter match + and - in hashtags?
