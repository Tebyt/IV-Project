/* threadInfo  */
select thread.*, count(post.userid) as activeusers
from 
(
	select thread.threadid, thread.title as threadtitle, 
		thread.replycount+1 as totposts
	from 
	carderscc_01.thread 
) as thread
left outer join
carderscc_01.post
on thread.threadid = post.threadid
where thread.totposts>10
group by post.threadid
order by thread.threadid, post.userid

