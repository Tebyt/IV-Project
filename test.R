
examineID <- function(quote, id, table_post) {
  row = table_post[table_post$importpostid==as.numeric(id),];
  if (nrow(row) == 0) {
    "INVALID_ID";
  } else if (is.na(row$userid)){
    "NA_ID";
  } else {
    quote = sub("(\\[quote.*?\\])(.*)(\\[\\/quote\\])", "\\2",
        quote, ignore.case = TRUE)
    if (regexpr(quote, row$pagetext, fixed=TRUE) > 0) {
      row$userid;
    } else {
      row = table_post[table_post$postid==as.numeric(id),];
      if (nrow(row) == 0) {
        "INVALID_ID";
      } else if (is.na(row$userid)){
        "NA_ID";
      }
      "ID_NOT_MATCH_TEXT";
    }
  }
}

# 
# regexpr("(?'tag'\\[quote[^]]*\\])*(?'-tag'\\[\\/quote\\])",
#     "[QUOTE=brezel;22136]inet cafes ham meist blacklisted ip, brauchst auch im inet cafe nen nl socks[/QUOTE]", ignore.case = TRUE)
# 
# regexpr("(?'group'\w)",
#         "[QUOTE=brezel;22136]inet cafes ham meist blacklisted ip, brauchst auch im inet cafe nen nl socks[/QUOTE]", ignore.case = TRUE)
# 
# 
# 
# sub("(\\[quote[^]]*\\])(.*)(\\[\\/quote\\])", "\\2",
#     "[QUOTE=brezel;22136]inet cafes ham meist blacklisted ip, brauchst auch im inet cafe nen nl socks[/QUOTE]", ignore.case = TRUE)

# dealQuote <- function(quote, table_post) {
#   if (regexpr("^\\[QUOTE\\]\\[\\/QUOTE\\]$", quote, ignore.case=TRUE) == 1) {
#     quote = "No_Content";  #for test
#     # quote = "";
#   } else if ( regexpr("\\[QUOTE\\=\\w+\\;\\d+\\]", quote, ignore.case=TRUE) == 1) {
#     id = substring(quote,
#                 regexpr("\\;", quote, ignore.case=TRUE)+1,
#                 regexpr("\\]", quote, ignore.case=TRUE)-1);
#     quote = examineID(quote, id, table_post);
#   } else if ( regexpr("(\\[quote author\\=\\w+ link\\=topic\\=\\d+\\.)(msg\\d+)\\#\\2 date\\=\\d+\\]", 
#                       quote, ignore.case=TRUE) == 1 ) {
#     id = substring(quote,
#                 regexpr("msg", quote, ignore.case=TRUE)+3,
#                 regexpr("\\#", quote, ignore.case=TRUE)-1);
#     quote = examineID(quote, id, table_post);
#   }
#   quote;
# }

dealQuote<- function(quote, row_quote, table_post) {
  quote = sub("(\\[quote.*?\\])(.*)(\\[\\/quote\\])", "\\2",
              quote, ignore.case = TRUE);
  match = data.frame();
  for (row in 1:nrow(table_post)) {
    if (regexpr(quote, table_post[row, "pagetext"], fixed=TRUE) > 0 &&
        !is.na(table_post[row,"userid"]) &&
        table_post[row,"userid"] != row_quote$userid) {
      if (nrow(match) == 1) {
        return ("MULTI_MATCH_BY_TEXT");
      }
      match = rbind(match, table_post[row,]);
    }
  }
  if (nrow(match) == 1) {
    match[1,"userid"];
  } else {
    "NO_NATCH_BY_TEXT";
  }
}

callback <- function(row_quote, table_post) {
  x = row_quote$pagetext;
  result = "";
  depth = 0;
  quote = "";
  first = TRUE;
  while (TRUE) {
    quoteStart = regexpr("\\[QUOTE", x, ignore.case=TRUE);
    quoteEnd = regexpr("\\[\\/QUOTE\\]", x, ignore.case=TRUE);
    if (quoteStart < 0 && quoteEnd < 0) {
      break;
    } else if (quoteEnd < 0) {
      result = "UNMATCHED_QUOTE_TAGS";
      break;
    } else if (quoteStart < 0 || quoteEnd < quoteStart) {
      quote = paste(quote, substring(x, 1, quoteEnd+7), sep="");
      x = substring(x, quoteEnd+8);
      depth = depth - 1;
    } else {
      if (quote == "") {
        quote = substring(x, quoteStart, quoteStart);
      } else {
        quote = paste(quote, substring(x, 1, quoteStart));
      }
      x = substring(x, quoteStart+1);
      depth = depth + 1;
    }
    if (depth == 0) {
      quote = dealQuote(quote, row_quote, table_post);
      if (quote != "") {
        if (first) {
          result = quote;
          first = FALSE;
        } else {
          result = paste(result, quote, sep=",");
        }
      }
      quote = "";
    } else if (depth < 0) {
      result = "UNMATCHED_QUOTE_TAGS";
      break;
    }
  }
  cat(result);
  result;
}

test <- table_quote[c(1:100),];

for (row in 40:nrow(test)) {
  test[row,"quote"] <- callback(test[row,], table_post);
}
# test$quote <- apply(test, 1, callback, table_post);
# 
# test <- table_quote[table_quote$dateline=="1255019446",];
# table_post[table_post$importpostid==22136,];
# quote = "inet cafes ham meist blacklisted ip, brauchst auch im inet cafe nen nl socks";
# regexpr(quote, table_post[table_post$importpostid==22136,"pagetext"], fixed=TRUE)
# rbind(match, table_post[row,]);
