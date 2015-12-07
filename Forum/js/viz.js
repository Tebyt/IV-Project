var data;
d3.json("../csv/dual_data.json", function (d) {
    data = d.data;
    vizThreads(3);

})
var scale = 50; // Merge data to how many blocks
var div = "#table";  // The table to show




//function getUserData(forum) {
//    return data[forum].users;
//}
//
//
//function vizUsers(forum) {
//    var users = getUserData(forum);
//    minDate = min(users.)
//    var xScale = d3.time.scale()
//        .domain([new Date(dataset[0][0].time), d3.time.day.offset(new Date(dataset[0][dataset[0].length - 1].time), 8)])
//        .rangeRound([0, w - padding.left - padding.right]);
//
//}
function getThreadData(forum) {
    return data[forum].threads;
}

function getMinDate(threads) {
    var minDate = threads[0].posts[0].date;
    threads.forEach(function(thread) {
       thread.posts.forEach(function(post) {
          if (post.date < minDate) {
              minDate = post.date;
          } 
       })
    })
    return new Date(new Date(minDate*1000).setHours(0,0,0,0));
}

function getMaxDate(threads) {
    var maxDate = threads[0].posts[0].date;
    threads.forEach(function(thread) {
       thread.posts.forEach(function(post) {
          if (post.date > maxDate) {
              maxDate = post.date;
          } 
       })
    })
    return new Date(new Date(maxDate*1000).setHours(0,0,0,0));
}


function rescale(posts, minDate, maxDate, scale) {
    if(scale == 0) {
        divider = 1;
    } else {
        divider = (maxDate - minDate) / scale;
    }
    posts = posts.map(function (d) {
        return {
            "date": new Date(new Date(Math.round((d.date - minDate)/divider)*divider + minDate.getTime()).setHours(0,0,0,0))
        }
    })
    posts = posts.map(function(d) {
        return {
            "date": d.date < minDate? minDate : d.date > maxDate? maxDate: d.date
        }
    })
    posts = posts.reduce(function(prev, next) {
        var matched = false;
        prev.forEach(function (d) {
            if (d.date.getTime() == next.date.getTime()) {
                ++d.value;
                matched = true;
                return;
            }
        })
        if (matched) {
            return prev;
        }
        prev.push({
            "date": next.date,
            "value": 1
        })
        return prev;
    }, []);
    posts.push({
        "date": new Date(maxDate),
        "value": 0
    })
    return posts;
}

function formatDate(threads) {
    threads.forEach(function(thread) {
        thread.posts.forEach(function(post) {
            post.date = new Date(new Date(post.date*1000).setHours(0,0,0,0));
        })
    })
    return threads;
}

function vizThreads(forum) {
    var threads = getThreadData(forum);

    var minDate = getMinDate(threads);
    var maxDate = getMaxDate(threads);

    threads = formatDate(threads);

    var selection = d3.select(div).selectAll("tr").data(threads);
    selection.enter().append("tr").append("td").attr("id", function(d, i) {return "forum_graph" + i;});

    threads.forEach(function(thread) {
        thread.posts = rescale(thread.posts, minDate, maxDate, scale);
    })
    for (var i = 0; i < threads.length; ++i) {

        //MG.data_graphic({
        //    title: "Few Observations",
        //    description: "We sometimes have only a few observations. By setting missing_is_zero: true, missing values for a time-series will be interpreted as zeros. In this example, we've overridden the rollover callback to show 'no data' for missing observations and have set the min_x and max_x options in order to expand the date range.",
        //    data: threads[i].posts,
        //    //interpolate: 'basic',
        //    missing_is_zero: true,
        //    width: 600,
        //    height: 200,
        //    right: 40,
        //    min_x: minDate,
        //    max_x: maxDate,
        //    target: "#forum_graph"+i,
        //    mouseover: function(d, i) {
        //        var df = d3.time.format('%b %d, %Y');
        //        var date = df(d.date);
        //        var y_val = (d.value === 0) ? 'no data' : d.value;
        //
        //        d3.select('#missing-y svg .mg-active-datapoint')
        //            .text(date +  '   ' + y_val);
        //    }
        //});
        MG.data_graphic({
            data: threads[i].posts,
            //interpolate: 'basic',
            show_tooltips: false,
            missing_is_zero: true,
            width: 130,
            height: 50,
            //full_width: true,
            //full_height: true,
            right: 0,
            top: 0,
            left: 0,
            bottom: 0,
            x_axis: false,
            y_axis: false,
            area: false,
            //y_rug: true,
            axes_not_compact: false,
            //y_extended_ticks: true,
            //yax_count: 0,
            min_x: minDate,
            max_x: maxDate,
            target: "#forum_graph"+i,
            mouseover: function(d, i) {
                d3.event.preventDefault();
                if (d.value === 0) {
                    return;
                }
                var df = d3.time.format('%b %d, %Y');
                var date = df(d.date);
                var y_val = (d.value === 0) ? 'no data' : d.value;

                var tooltip = d3.select("#tooltip");
                tooltip.select("#date").text("date: " + date);
                tooltip.select("#value").text("#ofPosts: " + y_val);
                tooltip.style({
                    "display": "block",
                    "top": d3.event.y + 50 + "px",
                    "left": d3.event.x + 50 + "px"
                });
            },
            mouseout: function() {
                var tooltip = d3.select("#tooltip");
                tooltip.style("display", "none");
            }
        });
    }



    //var timeSeries = rescale(curThread.posts, minDate, maxDate, 50);

    //MG.data_graphic({
    //    title: "Over A Large Span of Days",
    //    data: timeSeries,
    //    target: '#test',
    //    width: 600,
    //    height: 200
    //});
//    var xScale = d3.time.scale()
//        .domain([minDate, maxDate])
//        .range([10, 590]);
//
//    var yScale = d3.scale.linear()
//        .domain([0,
//            d3.max(dataset, function(d) {
//                return d3.max(d, function(d) {
//                    return d.y0 + d.y;
//                });
//            })
//        ])
//        .range([h-padding.bottom-padding.top,0]);
//
//    var xAxis = d3.svg.axis()
//        .scale(xScale)
//        .orient("bottom")
//        .ticks(d3.time.days,1);
//
//    var yAxis = d3.svg.axis()
//        .scale(yScale)
//        .orient("left")
//        .ticks(10);




}