SELECT username, pagetext, postid, threadid, dateline, importpostid
FROM carderscc_01.post
ORDER BY threadid ASC, dateline ASC;

SELECT username, pagetext, postid, threadid, dateline, importpostid
FROM carderscc_01.post
WHERE pagetext REGEXP 'QUOTE'
ORDER BY threadid ASC, dateline ASC;