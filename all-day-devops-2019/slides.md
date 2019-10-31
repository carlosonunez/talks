---
title: "SRE and BDD: The Ultimate Power Pair"
---

<!--- .slide: data-background="https://edge.bonnieplants.com/www/uploads/20180920001927/BONNIE_cucumbers_iStock-900811876_1800px.jpg" -->

### SRE and BDD: The Ultimate Power Pair
 
**Carlos Nunez**

*2019 October 21*

Note:
Hi! Thanks for coming to my talk! I'm glad that you're here, and I hope you're having a great day.
I'm going to be talking about the relationship between SRE and BDD.

These slides are up on GitHub! If you have any questions, hang around after the talk and I'll be
glad to answer them. I also have these slides and code samples on GitHub; links at the end.

---

# Hello, I'm Carlos

Note:
My name's Carlos Nunez. I've been a systems administrator and software engineer for over 10 years.
While I'm currently at a hip DevOps consultancy from New York called Contino, I've worked for many
companies: large, small, regulated and wild-west.

I love talking and doing all things DevOps. When I'm not doing that, I'm enjoying beer, my bike, my
wife, my gym or travels somewhere.

---

# Agenda

Note:
This is what I'd like to talk about today:

- What is `$F`Reliability Engineering, and why it matters
- What is Behavior Driven Development, and why it matters
- The relationship between `$F`RE and BDD
- An example of this relationship manifested.

---

# `$foo`Reliability Engineering

Notes:
Let's talk about Site Reliability Engineering, or, as I call it, `$foo` Reliability Engineering.

---

<img src="./assets/buttload-of-servers.png" height="30%" width="30%">

Notes:

- Spent a lot of time trying to find a cool sentence explaining what SRE is
  that _didn't_ come from Google.

- Had a _surprisingly_ rough time of it, so I started saving all of the sites that explained it
  well enough and created a quick word cloud with it.

- But I ran into this image that explained it really well with no words at all..MY FAVORITE

- Reliability Engineering is really what you get when you take code, systems and
  a lot of infrastructure and put it together. It's a bit more nuanced than that, though.

---

<img src="./assets/top-20-sre-words.png" height="100%">

Notes:

- ...hence the frequency map
- Here are the top 20 most frequent words I saw from reading Reddit posts, Quora
  articles and other things from the interwebs on SRE (excluding utterances)
- (Pages used and script that generated this in the GitHub repo)

---

<img src="./assets/top-20-sre-words-reliability.png" height="40%">

- `$f`RE is about reliability of a thing (hence `$foo`)
  - Site is popular because Google made it so, but even they have different
    RE for things like Cloud and CorpEng.

---

<img src="./assets/top-20-sre-words-reliability-def-overlay.png" height="40%">

Notes:

- Read the definition
- "Consistently performing well"...this is defined by customers of your thing!
- This is where SLAs, SLOs, SLIs, and error budgets come into play

---

<img src="./assets/top-20-sre-words-sre.png" height="40%">

- For some reason, there's a debate on SRE vs. DevOps
- It's more like SRE _is_ DevOps...because

---

<img src="./assets/top-20-sre-words-people.png" height="40%">

- DevOps is about bringing people together: from the Dev side and the Ops side

---

# Thanks! 👏🏾

**Blog**: https://blog.carlosnunez.me

**Commence Pitchfork Gathering Here**: http://twitter.carlosnunez.me
