/* postTimeSeries*/
select user.userid, user.username, 
forumpostthread.*
from carderscc_01.user 
inner join 
(
	select forum.title as forumtitle, postthread.*
	from
	(
		select thread.forumid, thread.title as threadtitle, thread.threadid,
			post.userid, post.postid, post.title as posttitle, from_unixtime(post.dateline) as dateposted, post.pagetext as posttext
		from
		carderscc_01.post
		inner join 
		carderscc_01.thread
		on post.threadid = thread.threadid
        where thread.replycount>4
 
	) as postthread
	inner join
	carderscc_01.forum
	on forum.forumid = postthread.forumid
)as forumpostthread
on user.userid = forumpostthread.userid
