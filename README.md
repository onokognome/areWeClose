# areWeClose?
Problem solution for probem from a potential employer. Essentaily the problem is finding the 'distance' between chains of friends in a social network.

First of all, this is an algorithm problem and a coding problem. I usually have better success handling them as separate items rather than jumping in and coding - especially algorithms like this.
At it's core, this is a graph search problem. It needs to be turned into a functional program - which is great because the recursive solution to the graph search algorithm should map nicely to the code.

I made an effort to remember the algorithm first - and then check against Dijkstra's solution and I did well. Basically, I'm treating each node in the graph as a record containing two things: a user id and a list of the user id's of the user's friends. In Ocaml it looks like this:

`type user_friends { id : int; friends : int list }`

Next, since the graph is not 'rooted', any User can be a 'root node'. Also, I don't want to have the 'friends' field be a 'user_friends list', just an 'id list'. So there needs to be someplace to put the user_friends records so they can be found. A hashtable will do the job nicely. in Ocaml, it looks like this:

`Hashtbl.create user_hash 100`

This creates 100 initial entries - which is plenty.

The solution to the problem is recursive. Here's the important points:
- Every User has a list of friends with at least one entry.
- The friendship relation is reflexive. This is important so from this we know that that length of the chain from UserA to UserB is the same length as the chain from UserB to UserA (think about UserA and UserB not being friends and at some point one of their mutual friends become friends. Now there is a bidirectional chain from UserA to UserB and will be the same length for both users. Any subsequent chain created will be likewise.
- The friendship graph contains cycles. So recursing over the graph naively will not terminate. Some mechanism for detecting that we've already explored a path of the graph is necessary. Dijkstra 'marked' the paths/nodes that had been explored. Since we want to avoid imparitive solutions, we'll have to do something else. We'll keep a 'marked list' containing the Users we've already check for friendship relationships. We are going to do a breadth-first search, so we know that once we've check a Users's friend list, and don't find the friendship we're looking for, we don't have to check that User again (if a friendship chain exists, it must be through that or another User's friends).
- Should a User be their own friend? Since the friendship graph is reflexive, every User is naturally their own friend with a chain length of 2. For this problem, we'll let it slide; but in reality, that's probably not a good idea. But it is easily fixed by checking the input to the chain_length function.

Arguably, any doubts about the above points should be check/proven before coding so the debugging of algorithm errors and coding errors can be done separately. One lucky thing about functional programming is that the algorithm can be closely reflected in the program and it becomes more readily apparent which type of error one is likely encountering.

The Ocaml program makes generous use of the `List.fold_left` function to maintain a state accumuator to drive the mutiple recursions that are needed to sove the problem. The state accumulator is:

`(marked_lst : int list; depth : int; is_found : bool)`

The 'marked_lst' is the list of userId's that we've already check for friends. The 'depth' is the depth of the breadth-first search at a give point. It will become the chain length between friends. 'is_found' is true if we've found the match we're looking for. 

We recurse from an initial UserA to the friends of UserA looking for UserB. The 'next_depth' function builds the next level of recursion by evaluating all the User records for the Users at the current level - finding their friends. It then removes any of those friends that are in the marked_lst. This prevents cycles.

Hopefully the rest of the code can be understood with its comments to see how this works. The test cases considered were:
- no chain of friends between UserA and UserB (tested)
- UserA and UserB are friends (tested)
- find shortest chain when mutilple chains of different length exist (tested)
- non-existing users (coded but not tested)
- large networks of users (not tested)
- bad friend graphs (somewhat coded but not tested. should be pretty protected against this. but probably return wrong results sometimes).

For a production solution, this should probably be multi-threaded and a DHT used. This solution could morph this way naturally. Also, the user.id type could be abstracted, a module/functor pair could be created to handle different environments.

I should probably mention map/reduce. In a distributed envioronment, it's probably the right framework. And I suppose a lazy solution could build the entire friendship graph 'forcing' to find a UserB match at each depth, but haven't completely thought through it.

Hope I didn't make mistakes!

dsm

