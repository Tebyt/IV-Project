SELECT username, pagetext, postid, threadid, dateline, importpostid
FROM carderscc_01.post
ORDER BY threadid ASC, dateline ASC;

SELECT username FROM carderscc_01.user
ORDER BY joindate ASC;