# Every post is bound to a distinct threadid

SELECT threadid, count(DISTINCT importthreadid) as count FROM carderscc_01.post
where importthreadid != 0
GROUP BY threadid
ORDER BY count DESC;

SELECT count(*) from carderscc_01.post
where threadid = 0;

# the post table has rows with userid being 0 while a username is presented
# so we use the user table to fetch the userid connected with that username
DROP TABLE fixed_post;
CREATE TABLE fixed_post
		SELECT userid, pagetext, dateline, importpostid, postid, threadid
		FROM carderscc_01.post
		WHERE userid != 0
	UNION
		SELECT userid, pagetext, dateline, importpostid, postid, threadid
		FROM
			(SELECT username, pagetext, dateline, importpostid, postid, threadid
			FROM carderscc_01.post
			WHERE userid = 0) AS t1
		LEFT JOIN
			(SELECT username, userid
			FROM carderscc_01.user) AS t2 
		ON t1.username = t2.username
        WHERE userid IS NOT NULL;
        

# this query return 0 row, which shows that now all the posts are associated with a userid
SELECT * FROM fixed_post
WHERE userid = 0;


# this query gives us post assoicated with quote
SELECT * FROM fixed_post #42063
WHERE pagetext REGEXP 'QUOTE' AND userid IS NOT NULL;

# this query return 0 row, 
# which shows that when the receiverid in table thanks differ from those from table fixed_post,
# those ids are invalid 
# (since they couldn't be find in table user)
# so we could use userid in talbe post to fill in the receiverid in talbe thanks
SELECT * FROM
	(SELECT t1.receiverid FROM
			(SELECT * FROM carderscc_01.thanks) AS t1
		JOIN
			(SELECT * FROM fixed_post) AS t2
		ON t1.postid = t2.postid
	WHERE t1.receiverid != t2.userid) AS t3
JOIN 
	(SELECT * FROM carderscc_01.user) AS t4
ON t3.receiverid = t4.userid;


# this query give us connection in thanks
SELECT t1.userid AS fromuser, t2.userid AS touser, t1.dateline AS date, t2.postid
From
		(SELECT * FROM carderscc_01.thanks) AS t1
	inner join
		(select * from fixed_post) AS t2
	ON t1.postid = t2.postid
ORDER BY date ASC;


# this query returns 0 row
# which shows that we can't fix the userid in table pmtext using username
# and we guess that fromuserid 0 and 1 is associated with admin
SELECT * FROM carderscc_01.pmtext
where (fromuserid = 0 OR fromuserid = 1) AND (fromusername != '' AND fromusername != 'admin');


# this query return a count equal to the size of table pmtext
# which shows that every touserarray is associated with one and only one touser
# touserarray is like 'a:1:{i:5291;s:4:"udam";}'
SELECT count(*) FROM carderscc_01.pmtext
where touserarray REGEXP 'i\\:{1}';


# these two queries does not return NULL value on userid
# which shows that all ids in thanks table has a correspponding id in user tables
SELECT t1.userid FROM
		(SELECT userid FROM carderscc_01.thanks WHERE receiverid != 0) AS t1
	LEFT JOIN
		(SELECT userid FROM carderscc_01.user) AS t2
	ON t1.userid = t2.userid;

SELECT t1.receiverid FROM
		(SELECT receiverid FROM carderscc_01.thanks WHERE receiverid != 0) AS t1
	LEFT JOIN
		(SELECT userid FROM carderscc_01.user) AS t2
	ON t1.receiverid = t2.userid;
