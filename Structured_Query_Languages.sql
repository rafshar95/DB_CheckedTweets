/*
Query 1: Find the text of all tweets that were posted by the tweeter with the handle ‘patgotweet’.
*/

SELECT tweet_text FROM Tweet A, Tweeter B WHERE A.tweeter_id = B.tweeter_id AND B.handle= 'patgotweet';

/*
Query 2:List the distinct domains of expertise for checkers who have verified tweets that have the hashtag “COVID19”.  (Note: The hashtag value is all in capital letters.) 
*/

SELECT DISTINCT E.domain FROM Expertise E, Verification V, Hashtags H WHERE H.hashtag = 'COVID19' AND V.user_id = E.user_id AND V.tweet_id = H.Tweet_id;

/*
Query 3: List the handles of Tweeters who have posted a tweet that has been verified by a Checker who started as a checker after the date “2020-01-31 03:41:49”.
*/

SELECT DISTINCT Tr.handle FROM Tweeter Tr, Tweet T, Verification V, Checker C WHERE C.checker_since > '2020-01-31 03:41:49' AND C.user_id=V.user_id AND V.tweet_id=T.tweet_id AND T.tweeter_id = Tr.tweeter_id;

/*
Query 4: For verified tweets that contain the hashtag "COVID19", find the associated evidence URLs, verification comments, and checkers' first and last names (Again: “COVID19” is in all caps.)
*/

SELECT DISTINCT Ev.URL, V.comment, U.name_first, U.name_last FROM User U, Verification V, Evidence Ev, Hashtags Ht, VerifiedUsing VU WHERE Ht.hashtag='COVID19' AND Ht.tweet_id = V.tweet_id  AND V.ver_id = VU.ver_id AND EV.ev_id = VU.ev_id AND U.user_id=V.User_id;

/*
Query 5: Find the user IDs, first names, and last names of checkers that have all the domains of expertise from the user with ID = 68. (Note: Your answer will include the “ID = 68” checker as well, of course.)
*/

SELECT U.user_id, U.name_first, U.name_last FROM User U WHERE NOT EXISTS (SELECT E.domain        FROM Expertise E                   WHERE E.user_id = 68                    AND NOT EXISTS(SELECT E2.domain      FROM Expertise E2                     WHERE E2.domain = E.domain                     AND E2.user_id = U.user_id                   )                   ) ;

/*
Query 6: List the phone numbers of checkers who have verified the tweet with the id “1321211561046933514” and who are experts in “Infectious Diseases” (Note the use of the word “and” instead of “or” from the previous assignment!)
*/

SELECT DISTINCT P.kind, P.number FROM Phone P WHERE P.user_id IN (SELECT E.user_id      FROM Expertise E      WHERE E.domain='Infectious Diseases')   AND P.user_id IN (SELECT V.user_id      FROM Verification V      WHERE V.tweet_id='1321211561046933514');

/*
Query 7: Find tweet ids and the number of replies for each tweet that has one or more replies. List only the top five tweets that have the highest number of replies.
*/

SELECT T1.tweet_id, count(*) FROM Tweet T1, Tweet T2 WHERE T2.replied_to_tweet=T1.tweet_id GROUP BY T1.tweet_id Having count(*)>0 ORDER BY count(*) DESC LIMIT 5;

/*
Query 8: For tweets that have two or more reactions (replies and/or quotes), print their tweet id along with their number of replies and number of quotes. (Note that for such tweets, the sum of replies and quotes should be 2 or more). Order the result by the number of reactions in largest-first order.
*/

SELECT T1.tweet_id, (SELECT count(*) FROM Tweet T2 WHERE T2.replied_to_tweet=T1.tweet_id) AS rep_cnt,   (SELECT count(*) FROM Tweet T3 WHERE T3.quoted_tweet=T1.tweet_id) AS qt_cnt FROM Tweet T1 WHERE (SELECT count(*) FROM Tweet T2 WHERE T2.replied_to_tweet=T1.tweet_id) +  (SELECT count(*) FROM Tweet T3 WHERE T3.quoted_tweet=T1.tweet_id) >=2 ORDER BY rep_cnt+qt_cnt DESC;
