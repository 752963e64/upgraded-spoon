# upgraded-spoon
This repo contain R&amp;D around latest redbean.

## workdirs

- ./shm_sqlite

```exploring session storage, limit and security handling```

- ./reverse_proxy

```exploring reverse proxy capabilities```

- ./local_git

```exploring local git repo aggregation in a web browser```

- ./web_static_analysis

```exploring web scraping from server```

- ./skeleton

```The starting frame from all your next proto```

- ./signed_cake_slice

```demo signed session with a cookie combo or 2 cake slices?```

- ./memory_test

```demo memory handling, why it's 100% useless to play object patterns...```

- ./repo_hosting

```
demo repo hosting... as all request are known by the package manager there is no need a fucking line of code :D
you get resources as is in bytestream... normal in tls, what else? :D
there is only one folder inside redbean... /usr the best code is nocoding at all :D
```
![Yay](https://cdn.bsky.app/img/feed_fullsize/plain/did:plc:tyss4afylclup42sekiy5wma/bafkreia2lw7dmrqle7mpj7n575d7unmlm67gnfrt5asdtf2buzmo4b2354@jpeg)
...

## redbean's memory

- memory belong to one connection(one thread)

global scope is "persistant" time that you don't 

fill it from thread cuz memory is accounted to 

thread and it is garbage collected even if used...

- all function hooks shares entire definitions

## Why it shows no activity...

Really I can't develop program in such way... the same memory initialised at each turn... Is kind of too much for me...

I understand it's an exploitation to perform something... but it's not ideal nor clever nor economic...

it's just a toy. It's a cool one when you are not that regarding like me. :D

It's just my own opinion... it's done perfectly overal... with just a little problem with memory handling...

Some ppl did devel whole circuitry as framework... that reinitialize at each requests...

I dunno what roam ppl to make such an attemp to make something with such constraint...

It's not really hard to move memory handling outside threading shit...

And from my personal training long ago... I 100% prefere muxing sockets than threading them.

THis tool is so well done that it would be very unfortunate to stand on this limitation... where everything restart with the cost of initialisation.

## My HTTP RFC?

1xx - Rare novelty response code.

2xx - All good

3xx - Somethings could be better

4xx - You did something wrong

5xx - Server did something wrong

## Q/A

- What's R&amp;D?

scraping to end with something else a chimera.

![spoon HoneyBadger](.rzh-ts.asc.png)

