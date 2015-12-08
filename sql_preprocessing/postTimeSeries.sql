/* postTimeSeries */
select user.userid, user.username, user.reputationlevelid as lv, 
forumpostthread.*
from carderscc_01.user 
inner join 
(
	select forum.title as forumtitle, postthread.*
	from
	(
		select thread.forumid, thread.title as threadtitle, thread.threadid,
			post.userid, post.postid, post.title as posttitle, (post.dateline) as dateposted, post.pagetext as posttext
		from
		carderscc_01.post
		inner join 
		carderscc_01.thread
		on post.threadid = thread.threadid
        where thread.replycount>9
		
	) as postthread
	inner join
	carderscc_01.forum
	on forum.forumid = postthread.forumid
)as forumpostthread
on user.userid = forumpostthread.userid
order by forumpostthread.forumid, forumpostthread.threadid, forumpostthread.dateposted
