--
-- PostgreSQL database dump
--

-- Dumped from database version 12.1
-- Dumped by pg_dump version 12.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: forms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.forms (form_name, form_data) FROM stdin;
sample	{"title":"Sample Form","scores":{"total_test":[0,1]},"questions":[{"type":"likert-radio","prompt":"Lorem ipsum dolor sit amet consectetur adipisicing elit?","props":{"type":"integer","defaultLabel":"neutral"}},{"type":"likert","prompt":"Lorem ipsum dolor sit amet consectetur adipisicing elit?"},{"type":"likert","prompt":"Lorem ipsum dolor sit amet consectetur adipisicing elit?","props":{"type":"string","labels":["STRONGLY disagree","disagree","neutral","agree","STRONGLY agree"]}},{"type":"checkbox","prompt":"Lorem ipsum dolor sit amet consectetur adipisicing elit?","props":{"options":["Option 1","Option 2","Option 3"]}},{"type":"long-text","prompt":"Lorem ipsum dolor sit amet consectetur adipisicing elit?"},{"type":"radio","prompt":"Lorem ipsum dolor sit amet consectetur adipisicing elit?","props":{"options":["Option 1","Option 2","Option 3"]}},{"type":"radio","prompt":"Lorem ipsum dolor sit amet consectetur adipisicing elit?","props":{"options":["Option 1","Option 2","Option 3"],"other":true}},{"type":"slider","prompt":"Lorem ipsum dolor sit amet consectetur adipisicing elit?"}]}
\.


--
-- Data for Name: user_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_types (user_type_id, user_type_name, user_type_form_name) FROM stdin;
1	patient	sample
2	clinician	sample
3	caregiver	sample
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (user_id, user_type_id, user_name, user_hash, user_salt, user_full_name, user_response_id) FROM stdin;
1	2	clin123	\\xdb4995fa624844e366cf50973f6521c75e03a19d2820ea3682920557ccf5725d	\\x3b7d04f9c07f3d8e0d57c02da68809b70cddef48cb1440306244bb8e11e6bd5a	Clin Clin	\N
2	1	pat123	\\xa0fec9775ed3eb0c42f5db895563ef88cf5216bbd388f1d1cb0805ccf4fe8199	\\x88aba7025bbc9eb86797fefa69f6df25f42c4b5a45c75aa6735f53c1d5cb3be2	Pat Pat	\N
3	3	care123	\\x042c598b85c304cc540e246cd3d780d029d62853a71cfa4c6bb27f8b53affcc8	\\xdfed428aa32f7ab7b2abdad65620ecfe4365a681f278ec4141ed5ffeed4e503b	Care Care	\N
\.


--
-- Data for Name: oversee_requests; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.oversee_requests (patient_id, caregiver_id) FROM stdin;
\.


--
-- Data for Name: oversees; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.oversees (patient_id, caregiver_id) FROM stdin;
2	3
\.


--
-- Data for Name: responds; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.responds (session_id, response_id) FROM stdin;
\.


--
-- Data for Name: responses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.responses (response_id, response_form_name, response_datetime, response_owner_id, response_data) FROM stdin;
\.


--
-- Data for Name: serve_requests; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.serve_requests (patient_id, clinician_id) FROM stdin;
\.


--
-- Data for Name: serves; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.serves (patient_id, clinician_id) FROM stdin;
1	3
\.


--
-- Data for Name: session_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.session_types (name, patient_form, clinician_form, caregiver_form, speech, display_name) FROM stdin;
room	sample	sample	sample	blah blah blah	Sample
auditorium_medium	sample	\N	\N	There is no easier way to kill an incredible protagonist than to match them up with a boring, one-dimensional antagonist. All too often, youΓÇÖll find a richly developed main character of a story having to overcome a villain whose entire motivation is something as simple as ΓÇ£I want powerΓÇ¥ or ΓÇ£I want to destroy everything.ΓÇ¥ Undeveloped and uninteresting villains such as these completely kill the climax of a story and make the entire time you spent getting there feeling like a waste. Therefore, a necessary skill for any storyteller to have is knowing how to create a believable and convincing villain to drive the conflict of their story. LetΓÇÖs find out what that entails.\nEvery villain needs the kind of backstory that makes you pause and think, ΓÇ£if I were in the same situation, I might have turned out the same way.ΓÇ¥ A relatable antagonist allows the audience to identify and sympathize with the villain, making them feel less crazy and more understandable. When this is combined with a hero who faced a parallel backstory but was able to overcome those same difficulties, it allows for a fantastic dynamic to arise between the characters as they each try to make the other understand their point of view.\nTo make the villain even more understandable, the audience needs to have a clear picture of not only how the villain became the way they are, but also why the villain is taking the action that they are. ItΓÇÖs the kind of character moment that allows the audience to realize that the villain sees themselves as the hero of their story. Combined with a good backstory, this creates the overall feel of a villain who is both relatable and sane, where the audience might even start to think that the villain has a point.\nIn order to further drive the conflict, the villain should share connections with the hero of the story, allowing their dynamic to blossom in their interactions. This can be a literal connection, such as having the characters grow up together before slowly drifting apart, or an emotional one, such as the characters sharing similar values but living their lives vastly different as a result. The connection can even be more subtle, like two characters who share similar gifts but use them in completely different ways. These kinds of links create a believable and immersive conflict for the hero to have to overcome, giving the reader the chance to understand why these two characters are fighting in the first place.\nOnce the character of the villain has been properly crafted, it is important to make sure their conflict with the hero carries weight. The stakes for their conflict need to feel heavy and important, so that the audience is carried into their struggle and rooting for the success of the hero. The stakes can be important to just the hero, like them having to overcome a childhood bully of theirs to finally succeed. The stakes can also be important to both the hero and those around them, such as when the hero must take on a villain that threatens the lives of the people they love. Regardless of the motivation for the conflict, the audience must feel that should the hero lose, a tremendous loss for all will be felt, especially the hero themselves.\nWhen that final struggle between the two commences, the villain and hero must face-off in a climactic battle that feels worth the wait. As such, the villain needs to be a worthy adversary for the hero to defeat; not too weak that thereΓÇÖs barely even a struggle, but not too powerful that it looks like the hero only succeeds with blind luck. This does not mean the hero and villain need to be equals; the villain can be someone who succeeds with brute strength, while the hero is physically weaker but is able to win by outsmarting the villain. If their conflict doesnΓÇÖt feel insurmountable or a walk in the park, the audience will feel like their final battle is a climactic and fitting end to their struggle.\nIn the end, this all mainly boils down to having a villain that is both developed as a character and intimidating as a threat. Someone who you understand on an emotional level, but you still canΓÇÖt wait to see how the hero eventually brings them down. With these tips, anyone can create an amazing and unforgettable villain.\n	Auditorium (Medium)
auditorium_long	sample	\N	\N	ΓÇ£Laughter is the best medicine.ΓÇ¥ Intuitively, itΓÇÖs an expression that makes sense; genuine laughter is an expression of joy, so it would make sense that to feel better, all we need is a good laugh. However, is that really the case? Is laughter really the best medicine for when weΓÇÖre feeling down? LetΓÇÖs explore this from a scientific perspective to try and narrow down what it is about laughing that makes it so good for us, and if it really is that great, how we can consistently make it happen.\nFrom a chemical perspective, laughter is an incredible medicine. Recent studies have found that laughter triggers the release of endorphinsΓÇöthe bodies own feel good chemicalΓÇöin the brain via our opioid receptors, causing our bodies to feel better from a chemical perspective, regardless of how we feel emotionally. The more opioid receptors someone has in their brain, the more places the endorphins have available to latch onto, increasing the ΓÇ£happinessΓÇ¥ impact of the chemical release. These endorphins have even been shown to temporarily relieve feelings of pain, allowing us to not only feel happier but also cope with any pain we are currently experiencing. Laughter is very similar to powerful narcotics in this sense, as many highly addictive drugs also bind to these receptors. In this way, genuine laughter is like having all the positives of a drug without any of the negative consequences.\nThe endorphin effect we just described also helps explain why one person laughing will cause everyone around them to laugh as well. Spreading laughter throughout a group of people will cause everyone to release endorphins together, creating a feeling of togetherness and comradery within the group. ItΓÇÖs why we laugh so hard at seeing someone else laugh; we see them and think ΓÇ£they look like theyΓÇÖre having a great time, I want to experience that kind of joy too!ΓÇ¥ We donΓÇÖt even have to know what the other person is laughing about; we just see them laughing and we want to get in on the joy. ItΓÇÖs why we find people who make us laugh so attractive, since their presence directly causes us to feel better from an emotional and chemical perspective.\nOn the note of attractiveness, a recent study showed that women laugh 126% more than men, while men seem to be causing laughter the most. Having someone who makes them laugh is consistently a top quality that women look for, and men will find women who laugh at their jokes more attractive than women who donΓÇÖt. So not only do we as a species love to laugh, we also love to make those around us laugh. Laughter is a social glue that binds us together, and we will often stick with the people who cause us the greatest feelings of joy. This is both in the form of someone else making us laugh, but also someone validating our efforts to make them feel better by laughing at our jokes.\nOnce we make someone laugh, however, the way that laugh can be expressed varies wildly. Some laughs are a pure expression of joy at something funny, but that is only one kind of laugh. There are awkward laughs, taunting laughs, sarcastic laughs, derisive laughs and so on. The process of having to decode which laugh we are hearing from someone else is not easy and can take years of practice to get right. Fortunately for us, trying to decode each kind of laugh activates different regions of the brain each time, causing a major increase in overall brain connectivity. Every single time we hear a laugh, the regions of our brain come together to figure out exactly what message is trying to be conveyed by that laugh. A more interconnected brain helps keep people sharp and quick in their old age, so hearing laughs when weΓÇÖre young helps keep us healthy when weΓÇÖre old.  \nThere are more benefits to laughing than just releasing endorphins and getting those around us to like us. Laughter has been shown to release the neurotransmitter serotonin, the same brain chemical that most anti-depressants try to release to help people with their depression. The reason anti-depressants target serotonin in the first place is because serotonin is often known as the ΓÇ£happiness chemicalΓÇ¥-the release of it within the body promotes feelings of happiness and wellbeing. Serotonin plays a large role in maintaining mood balance, which is why low levels of it have been linked to depression. As a result, using laughter as an easy way to release serotoninΓÇöcombined with the release of endorphinsΓÇöhelp make a person happier overall. It isnΓÇÖt clear how long the serotonin hangs around for upon release, but there is no doubt that laughing causes a major release of serotonin, for at least a short period of time.\nLaughter has more physical benefits than just the release of serotonin and endorphins. Research has also shown that laughter has an anti-inflammatory effect that protects blood vessels and heart muscles from cardiovascular disease. Furthermore, laughter increases blood flow and the overall function of blood vessels. This seems to be because laughter lowers the levels of stress within the body, and high levels of stress tend to be a cause for heart disease in people. Regardless of the exact cause, there is a strong correlation between a regular amount of laughter and a healthy heart.\nThe health benefits of laughter just go on and on. Laughter has been shown to relax the body due to how it releases stress, leaving muscles relaxed for up to 45 minutes. Laughter boosts the functioning ability of the immune system, since it increases the production of immune cells and antibodies within the blood. Laughter boosts our mood, eases our stress, and helps us move on from our negative emotions. So now that we know how amazing making both ourselves and those around us is for our own wellbeing, what can we do to make sure weΓÇÖre consistently causing this amazing feeling?\nIf we really want to be good people, we need to know how to make other people laugh. WeΓÇÖve already shown that people will feel comradery and attraction for those that make them laugh, and we can all personally relate to the feeling of someone making us laugh after a terrible day. To make this happen, however, we need a good sense of what makes people laugh in the first place. To do this, we need to have a good general sense of those around us to know what they find boring and what they find boring. Once we know them well enough to know that type of humor they enjoy, we can use one of following eight kinds of conversational humor to make them laugh:\nType one: physical/slapstick comedy. Here, the humor is all in the physical act being done; think of it like a mime acting out a show. Type two: self-deprecating humor. This is where we make ourselves the butt of the joke to make those around us laugh and feel better about ourselves. Type three: surrealist comedy. This kind of comedy works because we find things that are totally illogical and ridiculous to be funny, which is exactly what this is going for. Type four: wordplay. Here the aim is to twist words around to create humorous results; basically, puns. Type five: topical. The goal here is to take a current event and make a joke out of it, to make people feel better about it or to make the experience easier to handle. Type six: observational. Like topical humor, this is where you make jokes about the things right in front of you. This requires quick thinking on your feet, but the results are worth it when you get it right. Type seven: bodily humor. These are jokes about functions of the human body, which tend to come off as immature, but with the right audience they can be real winners. Lastly, type eight: dark humor. This humor relies on making jokes out of dark and depressing underlying themes, to make them easier to cope with. Again, this one is heavily dependent on whoΓÇÖs around.\nWith all this in mind, we also need to focus on making ourselves laugh. Once we know what we find funny, we can be sure to seek it out at least once a day. That can be through TV, movies, books, or talking to someone that consistently makes us laugh. Whatever the medium, we need to make sure to keep the things that make us laugh close to us, so whenever we feel stressed, we have just what we need.\nArmed with this knowledge, we can go out and make the world a happier place, both for ourselves and those around us, solely through the power of laughter. Who knew a joke would be so beneficial to our health?	Auditorium (Long)
auditorium_very_long	sample	\N	\N	Every single one of us strives to be happy. Through every choice made in deciding what we do, who we see and how we spend our time, we choose the things that we think will make us happy. However, people can often be wrong about what will make them happy. They might think they know the right things to choose for their own mental health, but they donΓÇÖt. A recent but powerful example of this trend is the rise of social media. Though the use of platforms such as Instagram, Facebook, and Twitter continue to be as strong as ever, growing evidence suggests these platforms can be detrimental to the mental health of their most frequent users.\nWhen people in the eighth, tenth and twelfth grade were asked about their general levels of happiness and how they spend their free time, a strong correlation was found between activities that didnΓÇÖt require a screen and a higher level of happiness, chief amongst those screen-related activities being the heavy use of social media. However, itΓÇÖs not that unhappy people seek out social media, but that social media lead to a decline in happiness for those using it. In an experiment done on 1000 people in Denmark, people who were randomly assigned to give up Facebook for a week ended that time happier and less depressed than those who didnΓÇÖt. In another study done on young adults required to give up Facebook for their jobs, the study found that those who went without Facebook reported themselves as happier than those who didnΓÇÖt. Furthermore, research suggests that an increase in screen time leads to a general decrease in happiness, driving home the negative link between a personΓÇÖs wellbeing and their use of social media.\nWith all this in mind, the question is why? Why does heavy social media use lead to such an increase in unhappiness amongst its users? To tackle this question, we need to begin with a psychological perspective on the impact of social media on our psyche. Dr. Tim Bono, a psychologist at Washington University, recently shared six reasons on what he believes it is about social media that makes us all so unhappy.\nEven before the rise of social media, one of the most mentally damaging activities we could partake in was the act of social comparison; comparing our lives and success to someone elseΓÇÖs. This used to be harder to do, as we could only really compare ourselves to those who were close to us, whose lives we knew well enough to not feel too terrible about the results of that social comparison. However, in the age of social media, it is easier than ever to compare our lives to almost anyone. All we have to do is follow someone on one (or multiple) platforms, and weΓÇÖll constantly see an outpouring of the life they want to portray online. Since everyone active on social media knows that the general populace only sees what they want them to see, people post mainly about the highlights in their life without any of the daily lowlights. As a result, not only does social media force us to constantly compare our lives to both friends and strangers, but it forces us to do against an unrealistic portrayal of what those peopleΓÇÖs lives are like. This leads to more negative comparisons than positive ones, making us feel like our lives arenΓÇÖt successful or happy enough. To help mitigate the impact of this social comparison, Dr. Bono suggests taking time out of our day to focus on the good things happening in our lives. Taking time to be grateful on the things going well in our lives directly mitigates the impact of social comparison, as it is much harder to feel negatively about a comparison when weΓÇÖre already happy and content with where our lives are currently at.\nSometimes, however, the problem isnΓÇÖt so much what we see on these platforms as much as it is that weΓÇÖre stuck on them in the first place. Social media is designed to be addictive; to keep us there for as long as possible to bring in ad revenue for the parent company. Despite knowing that we might be spending too much time on social media, we canΓÇÖt help but feel compelled to open it up again and again when we feel bored with nothing better to do. The same neurochemistry that leads to people gambling despite knowing theyΓÇÖre probably going to lose is the same neurochemistry that leads us going back on social media despite knowing what we see might make us angry, upset, or both. Part of what makes these platforms so addicting is the uncertainty factor of not knowing how the next post we see will make us feel. This morbid curiosity encourages us to keep scrolling, to find out if the resulting post will make us happy, upset, cringe, laugh or cry. Therefore, these platforms are designed to have infinite scrolling-weΓÇÖll never reach the ΓÇ£endΓÇ¥ of our feed because there is no set end. There is infinite content to keep us locked onto the platform for as long as possible. In order to counteract this, Dr. Bono recommends treating this addiction like we would any other; we need to cut ourselves off from the source. Putting the phone or computer in an inconvenient place, installing apps that monitor how much time is spent on social media to lock us out of it when weΓÇÖve been on for too long, or forcing us to only use social media by manually logging in each time. These extra little barriers to being online will make it easier to be cut off until we can get into a healthy routine of time management on these platforms.\nOne of the key reasons to not overuse social media is that it doesnΓÇÖt allow the platform to replace your in-person connections. Human beings are naturally social creatures, and one of the biggest factors in predicting someoneΓÇÖs happiness is the strength of their connections to those around them. However, if the connection is only at a superficial level where someone is our ΓÇ£friendΓÇ¥ online but has no bond with us beyond seeing and interacting with our posts, that isnΓÇÖt enough of a human connection to be a real friendship. It will not satiate the innate social desire we all possess, and in fact will lead to the opposite feeling; it will make us feel like we have many virtual friends and followers without having anyone to rely on, leading to an intense feeling of loneliness. Furthermore, even with those who we do consider our actual friends, we will slowly replace our time spent in person with a connection purely held in place by social media, distancing ourselves from who we feel close to. Then, even when we do see those people in person, too much time is spent making sure to document the experience for social media without having any actual conversation of substance. The solution to this problem, as Dr. Bono explains, is simply to force ourselves out of this trap. Instead of relying on social media to keep us in touch with our friends, we need to force ourselves to talk to them, either on the phone or in person. One real friend means more than a hundred pseudo-friends to our wellbeing.\nFurther driving home the importance of real human interactions is making sure to keep social media out of our time with our friends. If we spend our time with our friends directing our energy towards capturing the perfect snapshots for social media, we miss out on getting to really enjoy those incredible moments we have together. Not only does this negatively impact the time we spend with our friends, but even when we do things alone, it diminishes our enjoyment of those experiences because our entire memory of the event is through a phone screen. As a result of these behaviors, we remember these events less fondly than we wouldΓÇÖve if we had put social media aside and just focused on being there in the moment, allowing our memory to catch what it needed to make the experience truly unforgettable. To make sure we are all truly living in, and enjoying, the moment to the fullest, Dr. Bono recommends setting a limit on the number of pictures we take at a given event. It Is wonderful that weΓÇÖre able to capture high definition snapshots of our lives, but this must be done in moderation, so we still leave ourselves time to really revel in what weΓÇÖre doing, and who weΓÇÖre doing it with.\nOnce weΓÇÖve taken these snapshots of our lives, we want to keep checking how other people are reacting to them-how many people have liked our posts, how many people have commented on our posts, were their comments positive or negative, and so on. This creates a vicious system of relying on social media to validate our experiences; if people arenΓÇÖt interacting with our posts, it makes us feel like we donΓÇÖt have many friends who care about the things we are doing or saying, increasing our feelings of isolation and loneliness. We want the kind of post that gets hundreds of likes and positive comments, and when we donΓÇÖt get it, it makes us feel terrible; our entire self-worth becomes wrapped up in how people see us online. This is not only damaging for our mental health, but our physical one as well. We become so antsy to check on not only our own posts, but the posts of everyone we know, to see how their posts do in comparison to ours. This interwoven pattern of social comparison, addiction and self-worth is disastrous for our health, and one of the chief health problems it causes is a lack of sleep. Since we need to constantly keep checking how everything is doing, we canΓÇÖt put our devices away to go to sleep, and even when we do, the stress of our posts can be so intense that it keeps us from being able to fall asleep. WeΓÇÖre too worried in how our posts are doing to gain the peace of mind to be able to fall asleep; thereΓÇÖs too much anxiety and panic rolling around in our heads. On the flip side, when we see other peopleΓÇÖs posts doing well in comparison to ours, the jealousy and lack of self-worth it makes us feel can again lead to difficulty in falling asleep. To address this issue, Dr. Bono says that if you are the kind of person who would always check their phone before bed, donΓÇÖt keep your phone near where you sleep. Cut yourself off when you want to go to sleep so youΓÇÖre able to fall asleep at night. Try reading a book or a magazine to take your mind off the pressures of social media; often, it has the opposite of a calming impact when we want to sleep.\nThe physical impact of social media doesnΓÇÖt stop with our sleep, however. One of the most glaring impacts its had is on our attention span; many of us simply donΓÇÖt know what to do with ourselves if we canΓÇÖt reach for any device to check some form of social media. This is because social media is meant to give us this instantaneous form of entertainment and information that once we grow accustomed to, we simply cannot live without. It has become increasingly difficult to ignore any notification from any social media on our devices because we simply need to know now; it canΓÇÖt possibly wait another minute. If we have no ability to resist the instant gratification of social media, we have no ability to maintain attention on the proper tasks throughout the day either. Simply put, social media kills our impulse control. In order to fight this, Dr. Bono suggests meditation might be an effective way to get our need for immediate gratification under control. Taking the time every day to focus solely on our breathing and mental wellbeing forces us to devote all our energy to one task, allowing us to gain back control over our impulse desires. With meditation, we become better at recognizing distracting thoughts, allowing us to quickly quell them and get back to the task at hand.\nSocial media has done an incredible job at bringing people together from all over the world. However, like with everything, it is only good at moderation. By recognizing the negative impacts of social media and how we can tackle each one, we can learn to let social media make us happy again.	Auditorium (Very Long)
auditorium_short	sample	\N	\N	Which came first, the chicken or the egg? ItΓÇÖs a riddle that has confounded people for years because of the inherent scientific question it presents; you need two chickens to lay a chicken egg, seeming to imply the chicken came first, but chickens can only hatch from the egg of a chicken.\nSince the question is scientific in nature, the answer can be found scientifically as well. The very first chicken to exist would have been the result of a genetic mutation taking place in the zygote of two proto-chickens. In other words, two almost-chickens would have to create an offspring that genetically mutated into what we now know to be a chicken. That offspring would be laid in an egg, and hatch into the very first chicken. As a result, the science clearly shows that the egg did indeed come first.	Auditorium (Short)
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sessions (session_owner_id, session_datetime, session_duration, session_id, type_name) FROM stdin;
2	2020-02-29 03:17:27.533606	\N	1	room
\.


--
-- Data for Name: session_files; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.session_files (session_id, type, name) FROM stdin;
\.


--
-- Name: UserTypes_user_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."UserTypes_user_type_id_seq"', 3, true);


--
-- Name: Users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Users_user_id_seq"', 3, true);


--
-- Name: responses_response_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.responses_response_id_seq', 1, false);


--
-- Name: sessions_session_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sessions_session_id_seq', 1, true);


--
-- PostgreSQL database dump complete
--

