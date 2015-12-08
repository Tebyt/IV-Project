"forums": [
    {
        users: [{
            userid: Integer,
            lv: Integer,
            posts: [{
                postid: Integer,
                threadindex: Integer, // the index related to the below threads data field (0...length(threads))
                date: Integer
            }]
        }],
        threads: [{
            threadid: Integer,
            title: String,
            posts: [{
                postid: Integer,
                date: Integer,
                userindex: Integer // the index related to the above users data field (0... length(users))
            }]
            number_of_users // distinct users that have participated in a thread
        }]
        forumid: Integer,
        forumtitle: String,
        first_post_date: Integer,
        last_post_date: Integer,
    }

]

omit user who has not post: 
create table user
select distinct(post.userid) from
    post left join user
where user is not null 

filter user who has less than n post

filter thread which has less than n post

filter 

count userid in post to filter user (only select userid with count > n)



count threadid in post to filter threadid (only select thread with count > n)
    right join with thread to filter thread 

count forumid in thread to filter forumid (only select forum with thread > n)
    right join with forum to filter forum
    
    
