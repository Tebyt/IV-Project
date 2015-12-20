
# IV-Project

This is our reference for the interface. 

## Interface
The interface framework in overview/overview.html

## Files
### Preprocessing
* **data.sql** generates csv files
* **quote.R** extract quote connections from post.csv
* **transform.py** Transforms the csv files into json files for the dual view
* **/sql_preprocessing** SQL code to extract the csv files in /csv


### Data
* **post.csv** post information
* **quote.csv** quote connection
* **user.csv** user information including user reputation level and total posts
* **timeduration.sql-->timeduration.csv** the start and end date of the whole data set i.e. first post and end post. Dates are in the same format as from_unixtime()
* **postTimeSeries.sql-->postTimeSeries.csv** information to use in the svg for each user i.e. for each user, post number over some duration versus times, where duration can be month, week, day
* **threadInfo.sql-->threadInfo.csv** Information about each thread: threadid, thread title, total posts, total active users.  This should be used when displaying the SVGs for the threads on the dual view.
* **forumInfo.sql-->forumInfo.csv** Information on the forums: forum, forumid, number of threads, number of posts, number of active users, first post date, and last post date. This is for the forum dropdown.
* **userPostInfo.sql** user and their posts-->userPostInfo.csv


### Obtaining the json file, dual_data.json
1. Install python.
2. Open transform.py. If you want to limit the number of rows, set isLimit = True. Note if you want to limit the number of rows based on the the number of thread replies, run sql_preprocessing/postTimeSeries.sql with the appropriate number of thread replies.
3. In command line run: python transform.py
4. The json file is in csv/dual_data.json

Example format:
[{
	forum:[
		{
			users:	[ {userid:13, username:"bob", lv:12, posts:[{threadIndex, date}]} ],
			threads:[ {threadid:12, title:"credit hacks", posts:[{postid, posttitle, date, userid, userIndex}, ...]} ]
			forumid:5,
			forumtitle:"credit card",
			numberofthreads:4,
			numberofposts:33,
			numberofusers:12,
			first_post_date:unix time,
			last_post_date:unix time
		}
	]
}, ...]

## Data Format
There will be one **SINGLE** global variale containg all the data we need, it's format is as follow:


```
var data = {
	quote: {
		fromuser: String(), // name
		touser: String(), // name
		date: Int(),
		postid: Int(),
		threadid: Int(),
	},
	post: {
		username: String(),
		pagetext: String(), // post content
		postid: Int(),
		threadid: Int(),
		dateline: Int()
	}
}
		

```

## Functions
Don't access any global variable inside function (always pass in)

```
function displayNetwork(data, attr) {
attr specifies what attributes user wants the network graph to show as a circle
e.g. Most post user, Reputable user

The function will draw graph in <svg id = "network_viz">	
}
```


## Sub Visualization Prefix
We need to use prefix to name every element to prevent conflict when merging our works.
 
**\<circle id="barchart_circle" />**

When you use d3.select or css, only select element by ID

This will also be the prefix for your auxiliary functions

** function network_addCircle() {}**




## Local server
Since bracket.io server doesn't automatically load the changes in the code, run the local server instead.
1. Before running the server install nodejs: https://nodejs.org/en/download/ 

2. Run the terminal and navigate to project folder.

3. Run the following command:
    node server.js

4. Then, go to the browser and go to the url: http://localhost:4567 

