# require("data.table");
# 
# table_post <- read.csv("csv/post.csv",
#                        colClasses = c(rep("character", 2), rep("numeric", 4)),
#                        stringsAsFactors = FALSE,
#                        na.strings = "NULL");
# 
# table_post <- data.table(table_post);


# table_quote2 <- read.csv("csv/quote2.csv",
#                          header = TRUE,
#                        colClasses = c(rep("character", 2), rep("numeric", 4),"character"),
#                        stringsAsFactors = FALSE);
# 
# 
# table_quote2 <- fread("csv/quote.csv");

startTag <- "\\[quote.*?\\]";
endTag <- "\\[\\/quote\\]";

extractQuotes <- function(pagetext, startTag, endTag) {
  result <- character();
  depth <- 0;
  quote <- "";
  while (TRUE) {
    quoteStart <- regexpr(startTag, pagetext, ignore.case=TRUE);
    quoteEnd <- regexpr(endTag, pagetext, ignore.case=TRUE);
    if (quoteStart < 0 && quoteEnd < 0) {
      if (length(result) == 0) {
        result <- append(result, "NO_QUOTE");
      }
      break;
    } else if (quoteStart < 0 || quoteEnd < quoteStart) {
      quote <- paste0(quote, substring(pagetext, 1, quoteEnd+7));
      pagetext <- substring(pagetext, quoteEnd+8);
      depth <- depth - 1;
    } else {
      if (quote == "") {
        quote <- substring(pagetext, quoteStart, quoteStart);
      } else {
        quote <- paste0(quote, substring(pagetext, 1, quoteStart));
      }
      pagetext <- substring(pagetext, quoteStart+1);
      depth <- depth + 1;
    }
    if (depth == 0) {
      result <- append(result, quote);
      quote = "";
    } else if (depth < 0) {
      result <- append(result, "UNMATCHED_QUOTE_TAGS");
      break;
    }
  }
  result;
}

findMatch <- function(quote, post, curRow) {
  threadid <- post[curRow, "threadid"];
  beginRow <- curRow + 1;
  if (quote == "")
    return ("INVALID_QUOTE");
  matched_user <-"";
  matched <- FALSE;
  for (row in beginRow:1) {
    if (post[row, "threadid"] != threadid) {
      if (!matched) {
        return ("NO_MATCH");
      }
      else {
        return (matched_user);
      }
    }
    if (regexpr(quote, post[row, "pagetext"], fixed=TRUE) > 0) {
      if (matched) {
        return ("MULTI_MATCH");
      }
      matched_user <- post[row, "username"];
      matched <- TRUE;
    }
  }
  return ("NO_MATCH");
}

getUsernameByID <- function(quote, post, row, startTag, endTag) {
  if (regexpr("\\[QUOTE\\=\\w+\\;\\d+\\]", quote, ignore.case=TRUE) == 1) {
    id <- substring(quote,
                    regexpr("\\;", quote, ignore.case=TRUE)+1,
                    regexpr("\\]", quote, ignore.case=TRUE)-1);
  } else if (regexpr("(\\[quote author\\=\\w+ link\\=topic\\=\\d+\\.)(msg\\d+)\\#\\2 date\\=\\d+\\]", 
                     quote, ignore.case=TRUE) == 1 ) {
    id <- substring(quote,
                    regexpr("msg", quote, ignore.case=TRUE)+3,
                    regexpr("\\#", quote, ignore.case=TRUE)-1);
  } else {
    return ("");
  }
  quote <- sub(paste0(startTag, "(.*)", endTag), "\\1", quote, ignore.case = TRUE);
  return (examineID(id, quote, post, row));
}

examineID <- function(id, quote, post, row) {
  toExamine <- table_post[table_post$importpostid==as.numeric(id),];
  if (nrow(toExamine) != 0) {
    if (regexpr(quote, toExamine$pagetext, fixed=TRUE) > 0) {
      return (toExamine$username);
    }
  }
  
  toExamine <- table_post[table_post$postid==as.numeric(id),];
  if (nrow(toExamine) != 0) {
    if (regexpr(quote, toExamine$pagetext, fixed=TRUE) > 0) {
      return (toExamine$username);
    }
  }
  
  return ("");
}
# 
# dealUnmatchedQuoteTags <- function(post, row, startTag) {
#   while (startTag)
# }

buildQuote <- function(post, startTag, endTag) {
  progress <- 0;
  startTime <- proc.time()[3];
  
  col_quote <- character(nrow(post));
  pagetexts <- post$pagetext;
  for (row in 2:nrow(post)) {
    pagetext <- pagetexts[row];
    quotes <- extractQuotes(pagetext, startTag, endTag);
    result <- "";
    for (quote in quotes) {
      if (quote == "NO_QUOTE") {
        break;
      } else {
        if (quote == "UNMATCHED_QUOTE_TAGS") {
          #         username <- getUsernameByID(pagetext, post, row, startTag, endTag);
          #         if (username != "") {
          #           result <- paste0(result, "{", username, "}");
          #         } else {
          result <- paste0(result, "{UNMATCHED_QUOTE_TAGS}");
          # }
          break;
        }
        username <- getUsernameByID(quote, post, row, startTag, endTag);
        if (username != "") {
          result <- paste0(result, "{", username, "}");
          next;
        }
        quote <- sub(paste0(startTag, "(.*)", endTag), "\\1", quote, ignore.case <- TRUE);
        cur_match <- findMatch(quote, post, row);
        result <- paste0(result, "{", cur_match, "}");
      }
    }
    col_quote[row] <- result;
    
    if (row / nrow(post) > progress) {
      progress = progress + 0.001;
      cat("\014")
      cat("Current Progress: ", progress*100, "%");
      cat("\n");
      cat("Time Estimate: ", (proc.time()[3]-startTime)/progress*(1-progress)/60, "mins");
    }
  }
  cat("\014")
  cat("Finished");
  post$quote = col_quote;
  return (post);
}

# table_test <- table_post[1:50000, ];
# table_test <- buildQuote(table_test, startTag, endTag);
# 
# ttt <- table_test[table_test$quote == "UNMATCHED_QUOTE_TAGS",];

# fileName <- "prof_test.txt";
# table_test <- table_post[1:10000, ];
# Rprof(fileName);
# table_test <- buildQuote(table_test, startTag, endTag);
# Rprof(NULL);
# fileName <- "prof_test.txt";
# summaryRprof(fileName)$by.total[1:20,];

# table_quote <- table_post;
# table_quote$quote <- "{NO_QUOTE}";
table_quote = buildQuote(table_post, startTag, endTag);

# ind <- sapply(table_quote$quote, regexpr, pattern="{NO_MATCH}", fixed=TRUE);
# tmp <- table_quote[ind,];
# 
tmp = table_quote[table_quote$quote!="",];
# 
# 
# # invalid = table_quote$quote=="{INVALID_QUOTE}";
# # has_imp = lapply(table_quote$pagetext, regexpr, pattern="\\[quote.*\\=\\w", ignore.case=TRUE)>0;
# # ind = which(invalid&has_imp %in% TRUE);
# # tmp = table_quote[ind,];
# table_quote[16918, "quote"] = "{turk58}";
# table_quote = table_quote[table_quote$quote!="{INVALID_QUOTE}", ]
# 
# invalid = table_quote$quote=="{UNMATCHED_QUOTE_TAGS}";
# has_imp = lapply(table_quote$pagetext, regexpr, pattern="\\[quote.*\\=\\w", ignore.case=TRUE)>0;
# ind = which(invalid&has_imp %in% TRUE);
# tmp = table_quote[ind,];
# tmp = table_quote[invalid, ];
# tmp2 <- tmp[sapply(tmp$pagetext, regexpr, pattern="quote.*quote", ignore.case=TRUE)>0, ];
# 
# 
# tmp = table_quote[sapply(table_quote$quote, regexpr, pattern="NO_MATCH")>0, ]
# # tmp = table_quote[sapply(table_quote$quote, regexpr, pattern="NO_QUOTE", fixed=TRUE)>0, ]
# 
# # 
# write.csv(table_quote, "csv/quote.csv");
# 
# 
# 
