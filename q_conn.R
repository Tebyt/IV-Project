table_quote <- read.csv("csv/pm.csv",
                       colClasses = rep("integer", 4),
                       stringsAsFactors = FALSE);

table_user <- read.csv("csv/user.csv",
                      colClasses = c("character", "integer"),
                      stringsAsFactors = FALSE);
usernames <- table_user$username;
require(rjson);


# table_quote <- table_quote[order(table_quote$fromuser),];

fromusers <- table_quote$fromuser;
tousers <- table_quote$touser;
size <- length(fromusers);



# usernames = head(unique(fromusers), 200);
# matched <- logical(length(usernames));
# for (i in 1:size) {
#   match <- which(usernames == fromusers[i]);
#   if (length(match) == 0){
#     fromusers[i] = "FALSE";
#   } else {
#     matched[match] = TRUE;
#   }
#   
#   match <- which(usernames == tousers[i]);
#   if (length(match) == 0){
#     tousers[i] = "FALSE";
#   } else {
#     matched[match] = TRUE;
#   }
# }
# usernames <- usernames[matched];


for (i in 1:size) {
  match <- which(usernames == fromusers[i]);
  if (length(match) == 0){
    fromusers[i] = "FALSE";
  } 
  
  match <- which(usernames == tousers[i]);
  if (length(match) == 0){
    tousers[i] = "FALSE";
  } 
}



s <- fromusers[fromusers!="FALSE"&tousers!="FALSE"];
t <- tousers[fromusers!="FALSE"&tousers!="FALSE"];


# nodes <- data.frame("name"=usernames);
# links <- data.frame("source"=s, "target"=t, "weight"=rep(1,length(s)));

# nodes <- toJSON(unname(split(nodes, 1:nrow(nodes))))
# links <- toJSON(unname(split(links, 1:nrow(links))))
# finalString <- paste0("{","\"nodes\":",nodes,",", "\"links\":",links,"}");
# write(finalString, "Webpage/q_conn.json");

# write.csv(cons, file="csv/quote_con.csv", row.names=FALSE);
# write.csv(users, file="csv/user_con.csv", row.names=FALSE);
