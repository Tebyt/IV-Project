SELECT username, pagetext, postid, threadid, dateline, importpostid
FROM carderscc_01.post
ORDER BY threadid ASC, dateline ASC;

SELECT userid AS fromuser, pagetext, postid, threadid, dateline AS date, importpostid
FROM carderscc_01.post
WHERE userid != 0
ORDER BY threadid ASC, dateline ASC;

SELECT username, userid FROM carderscc_01.user
ORDER BY joindate ASC;


SELECT t3.* FROM
	(SELECT t1.* FROM
		(SELECT userid AS fromuser, receiverid AS touser, dateline AS date, postid
		FROM carderscc_01.thanks
		WHERE receiverid != 0
		) AS t1
	JOIN
		(SELECT userid FROM carderscc_01.user) AS t2
	ON t1.fromuser = t2.userid
	) AS t3
JOIN
	(SELECT userid FROM carderscc_01.user) AS t4
ON t3.touser = t4.userid
WHERE t3.fromuser != t3.touser
ORDER BY fromuser ASC, touser ASC;



# this query give us connection in pm
# notice that touserid = 0 does not have a name specified in touserarray so we couldn't fix

SELECT t4.* FROM
    (SELECT t2.* FROM
        (SELECT fromuserid AS fromuser, touserid AS touser, dateline AS date, pmtextid
        FROM	
            (SELECT fromuserid, 
                # touserarray is like 'a:1:{i:6153;s:5:"ZEL0S";}' 
                # where 6153 is touserid
                @beginIndex := INSTR(touserarray,'i:')+2,
                @length := INSTR(SUBSTRING(touserarray, @beginIndex),';')-1,
                CONVERT(SUBSTRING(touserarray, @beginIndex, @length), UNSIGNED INTEGER)
                    AS touserid,
                dateline,
                pmtextid
            FROM carderscc_01.pmtext) AS t1
        WHERE fromuserid > 1 AND touserid > 1 # exclude system messages
        ) AS t2
    JOIN
        (SELECT userid FROM carderscc_01.user) AS t3
    ON t2.fromuser = t3.userid
    ) AS t4
JOIN
    (SELECT userid FROM carderscc_01.user) AS t5
ON t4.touser = t5.userid
WHERE t4.fromuser != t4.touser
ORDER BY fromuser ASC, touser ASC;