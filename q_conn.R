table_quote <- read.csv("csv/quote.csv",
                       colClasses = c(rep("character", 2), rep("integer", 3)),
                       stringsAsFactors = FALSE);

usernames <- read.csv("csv/user.csv",
                      colClasses = c("character"),
                      stringsAsFactors = FALSE);
usernames <- usernames$username;
josn <- toJSON(unname(split(table_quote, 1:nrow(table_quote))));


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
  } else {
    fromusers[i] = match;
  }
  
  match <- which(usernames == tousers[i]);
  if (length(match) == 0){
    tousers[i] = "FALSE";
  } else {
    tousers[i] = match;
  }
}



s <- as.numeric(fromusers[fromusers!="FALSE"&tousers!="FALSE"]);
t <- as.numeric(tousers[fromusers!="FALSE"&tousers!="FALSE"]);


nodes <- data.frame("name"=usernames);
links <- data.frame("source"=s, "target"=t, "weight"=rep(1,length(links)));
library(rjson)
nodes <- toJSON(unname(split(nodes, 1:nrow(nodes))))
links <- toJSON(unname(split(links, 1:nrow(links))))
finalString <- paste0("{","\"nodes\":",nodes,",", "\"links\":",links,"}");
write(finalString, "Webpage/q_conn.json");
# write.csv(cons, file="csv/quote_con.csv", row.names=FALSE);
# write.csv(users, file="csv/user_con.csv", row.names=FALSE);
