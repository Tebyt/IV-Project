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