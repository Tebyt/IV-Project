SELECT from_unixtime(max(lastpost)), from_unixtime(min(dateline)) FROM
(select *, (lastpost-dateline)/3600/24 as diff from carderscc_01.thread
having diff = 0
Order by diff DESC) AS t1;

SELECT * FROM carderscc_01.user
where length(username) < 10;

SELECT * FROM carderscc_01.post
WHERE threadid = 13540;