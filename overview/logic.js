/*

*/
function transform(){

}



function vizTimeline() {
	if (typeof forum == "undefined") {
		users = getFilteredUser(forum);
	} else {
		users = getUser();
	}

	// specifying the space to draw

	for (user in users) {
		var svg =vizSingleUser;
	}
}


/*
@xy = [{x:1, y:10 }, {x:2,y:5 }, ...]
@scaleX and @scaleY
*/
function produceTimelineSVG(xy, scalex, scaley){

}


