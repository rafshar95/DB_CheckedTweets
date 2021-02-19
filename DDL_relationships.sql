USE CheckedTweets;

CREATE TABLE EvidenceFrom(
	user_id Integer NOT NULL,
    ev_id Integer NOT NULL,
    PRIMARY KEY(user_id, ev_id),
    FOREIGN KEY (user_id) references User (user_id) ON DELETE CASCADE,
    FOREIGN KEY (ev_id) references Evidence (ev_id) ON DELETE CASCADE
);

CREATE TABLE VerificationUsing( 
	ver_id Integer NOT NULL, -- how to enforce verification total participation?
    ev_id Integer NOT NULL,
    PRIMARY KEY(ver_id, ev_id),
    FOREIGN KEY (ver_id) references Verification (ver_id) ON DELETE CASCADE,
    FOREIGN KEY (ev_id) references Evidence (ev_id) ON DELETE CASCADE
);

CREATE TABLE About(
	tweet_id VARCHAR(20) NOT NULL,
    ev_id Integer NOT NULL,  -- how to enforce Evidence total participation?
    PRIMARY KEY(tweet_id, ev_id),
    FOREIGN KEY (tweet_id) references Tweet (tweet_id) ON DELETE CASCADE,
    FOREIGN KEY (ev_id) references Evidence (ev_id) ON DELETE CASCADE
);
