/* forumInfo: forum, forumid, number of threads, number of posts, number of active users, admin*/
select forumagg.forumid, forumagg.forumtitle, forumagg.numberofthreads,
	forumagg.numberofposts, usercounts.activeusers
from
(
	select forum.forumid, forum.title_clean as forumtitle, 
		count(threadagg.threadid) as numberofthreads, 
		sum(totpostsinthread) as numberofposts
	from
	(
		select thread.forumid, thread.threadid, 
			thread.replycount+1 as totpostsinthread
		from 
		carderscc_01.thread 
		where thread.replycount>4

	)as threadagg
	 right join
	 carderscc_01.forum
	 on forum.forumid = threadagg.forumid
	 group by forum.forumid
)as forumagg
inner join
(
	select threadusersagg.forumid,  count(threadusersagg.userid) as activeusers
	from (
		select distinct thread.forumid, thread.threadid, post.userid
		from carderscc_01.thread 
		left outer join
		carderscc_01.post
		on thread.threadid = post.threadid
		where thread.replycount>4

	)as threadusersagg
	group by threadusersagg.forumid
)as usercounts
on forumagg.forumid = usercounts.forumid
