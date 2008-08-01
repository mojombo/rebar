-module(rebar).
-export([start/0, handle/1]).

start() ->
  {ok, LSock} = gen_tcp:listen(5500, [binary, {packet, 0}, {active, false}]),
  loop(LSock).
    
loop(LSock) ->
  {ok, Sock} = gen_tcp:accept(LSock),
  spawn(rebar, handle, [Sock]),  
  loop(LSock).
  
handle(Sock) ->
  % read the request from the socket
  {ok, Bin} = gen_tcp:recv(Sock, 0),
  {ok, Json} = json:decode_string(binary_to_list(Bin)),
  
  % pull the request apart
  {Method, Params, Id} = parse(Json),
  [Module, Function] = string:tokens(Method, ":"),
  
  % call the function
  io:format("~p:~p(~p)~n", [Module, Function, Params]),
  Return = apply(list_to_atom(Module), list_to_atom(Function), tuple_to_list(Params)),
  
  % send the response
  gen_tcp:send(Sock, json:encode(json:obj_from_list([{"result", Return}, {"error", null}, {"id", Id}]))),
  ok = gen_tcp:close(Sock).
  
parse(Json) ->
  {json_object, Body} = Json,
  {value, {"method", Method}} = lists:keysearch("method", 1, Body),
  {value, {"params", Params}} = lists:keysearch("params", 1, Body),
  {value, {"id", Id}} = lists:keysearch("id", 1, Body),
  {Method, Params, Id}.