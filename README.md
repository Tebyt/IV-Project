# IV-Project

This is our reference for the interface. 

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
* **forumInfo.sql-->forumInfo.csv** Information on the forums: forum, forumid, number of threads, number of posts, number of active users, admin. This is for the forum dropdown.
 
### Obtaining the json file, dual_data.json
1. Install python.
2. Open transform.py. If you want to limit the number of rows, set isLimit = True. Note if you want to limit the number of rows based on the the number of thread replies, run sql_preprocessing/postTimeSeries.sql with the appropriate number of thread replies.
3. In command line run: python transform.py
4. The json file is in csv/dual_data.json

Example format:
[{
	forum:[
		{
			users:	[ {userid:13, username:"bob", lv:12} ],
			threads:[ {threadid:12, title:"credit hacks", posts:[{postid, posttitle, date, userid}, ...]} ]
			forumid:5,
			forumtitle:"credit card",
			numberofthreads:4,
			numberofposts:33,
			activeusers:12
		}
	]
}, ...]

Side Note: Note that the list of users do not contain a list of posts; the data will simply be too much, and grabbing such information is faster via javascript as opposed as stored in json. To top that, the json file also stores the post's texts, which is itself takes up large portions of the data.

### How to change the limit of the least number of replies a thread must have
1. There is a file called sql_preprocessing/postTimeSeries.sql. Open that in mysql and edit line number 17, where it says 4 to what ever reply limit you want. If you want at least 10 replies, then change it to 9. 

2. Run the query and then export the file and save it over csv/postTimeSeries.csv. 

3. Then run transform.py again. csv/dual_data.json should be updated to contain only threads that the least number of replies i.e. the one specified earlier. And keep your eye out for the file size when you commit files to github!! (If too big, then don't commit those csv!)

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



* **network_ ** for network overview


## Local server
Since bracket.io server doesn't automatically load the changes in the code, run the local server instead.
1. Before running the server install nodejs: https://nodejs.org/en/download/ 
2. Run the terminal and navigate to project folder.
3. Run the following command:
    node server.js
4. Then, go to the browser and go to the url: http://localhost:4567 

