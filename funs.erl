-module(funs).
-export([listen/0, add/2, cat/2, fac/1]).

listen() ->
  rebar:start().

add(A, B) ->
  A + B.
  
cat(A, B) ->
  A ++ B.
  
fac(N) ->
  fac(1, N).
  
fac(Memo, 0) ->
  Memo;
fac(Memo, N) ->
  fac(Memo * N, N - 1).