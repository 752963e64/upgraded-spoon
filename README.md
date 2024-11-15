# upgraded-spoon
This repo contain an applicative firewall made up stored session(cookie) around the latest redbean.

## To every serious project needs serious definitions.
This project aim to be a reference in session handling with the latest redbean.

Technically we have many options to achieve the same goal.

I will dive into strategies & methods to hopefully achieve the goal.

One of those is set to be the best...

let's hack...

### All the paths goes to roma

- SHM locking and sqlite3

- SHM locking and SHM JSON

- SHM locking and SHM lua table

- FIFO PIPE

- unpolled sock maybe

- file ondisk? :D tmpfs maybe? :)

### And the last idea that decimates all the previous one a like it's useless...

I'll just hardcode cookie handling from the inner with C, no need struggle that much finally...

## Q/A

- What's an applicative firewall?

An applicative firewall handles an entrypoint to let say an userland where anything that happens is authenticated...

This reduces undefined behavior in your applicable limits...

