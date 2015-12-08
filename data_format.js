"forums": [
    {
        users: [{
            username: String,
            number_of_posts: Integer,
            number_of_threads: Integer, // distinct threads
            first_post_date: Integer,
            last_post_date: Integer,
            posts: [{
                postid: Integer,
                threadindex: Integer, // the index related to the below threads data field (0...length(threads))
                date: Integer
            }],
        }],
        threads: [{
            title: String,
            number_of_users: Integer, // distinct users that have participated in a thread
            number_of_posts: Integer,
            first_post_date: Integer,
            last_post_date: Integer,
            posts: [{
                postid: Integer,
                date: Integer,
                userindex: Integer // the index related to the above users data field (0... length(users))
            }],
        }],
        forumtitle: String,
        first_post_date: Integer,
        last_post_date: Integer,
        number_of_users: Integer,
        number_of_threads: Integer
    }
]


// ignore below, too tired to think of
//
//omit user who has not post: 
//create table user
//select distinct(post.userid) from
//    post left join user
//where user is not null 
//
//filter user who has less than n post
//
//filter thread which has less than n post
//
//filter 
//
//count userid in post to filter user (only select userid with count > n)
//
//
//
//count threadid in post to filter threadid (only select thread with count > n)
//    right join with thread to filter thread 
//
//count forumid in thread to filter forumid (only select forum with thread > n)
//    right join with forum to filter forum
    
    
