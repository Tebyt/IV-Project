var data;

d3.json("../csv/dual_data.json", function (d) {
    data = d.data;
    viz_forum(data);
});

function viz_forum(data) {
    // Now manually set which forum to use,
    // Later will be defined by the forum selected
    var threads = data[1].threads; // use threads in forum 0

    // assign thread data to table rows
    var forum_rows = d3.select("body").append("div").append("table").attr("id", "forum_table").selectAll("tr").data(threads)
        .enter().append("tr");


    viz_forum_time_series(threads, forum_rows);

    // add your viz function here;
    // Now data has already been binding to rows, you only need to append a "td" for each of your viz
    // like: forum_rows.append("td")
    // viz_forum_number_of_users(threads, forum_rows);
    // viz_forum_number_of_posts(threads, forum_rows);
}


function viz_forum_time_series(threads, forum_rows) {
    var tooltipid = "#forum_time_series_tooltip";
    d3.select("body").append("div").attr("id", "forum_time_series_tooltip")
        .html('<p id="date"></p><p id="value"></p>')
        .style(
        {
            "background-color": "white",
            "border": "solid 1px black",
            "width": "150px",
            "display": "none",
            "position": "absolute"
        })

    var scale = 50; // Merge data to how many blocks

    var minDate = getMinDate(threads);
    var maxDate = getMaxDate(threads);

    threads = formatDate(threads);

    forum_rows.append("td").attr("id", function (d, i) {
        return "forum_graph" + i;
    });

    threads.forEach(function (thread) {
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
            target: "#forum_graph" + i,
            mouseover: function (d, i) {
                d3.event.preventDefault();
                if (d.value === 0) {
                    return;
                }
                var df = d3.time.format('%b %d, %Y');
                var date = df(d.date);
                var y_val = (d.value === 0) ? 'no data' : d.value;

                var tooltip = d3.select(tooltipid);
                tooltip.select("#date").text("date: " + date);
                tooltip.select("#value").text("#ofPosts: " + y_val);
                tooltip.style({
                    "display": "block",
                    "top": d3.event.y + 20 + "px",
                    "left": d3.event.x + 20 + "px"
                });
            },
            mouseout: function () {
                var tooltip = d3.select(tooltipid);
                tooltip.style("display", "none");
            }
        });
    }
}
// functions for viz_forum_time_series
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


// functions for viz_forum_number_of_users(threads, forum_rows);






// functions forviz_forum_number_of_posts(threads, forum_rows);